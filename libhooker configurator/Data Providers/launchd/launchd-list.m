//
//  launchd-list.c
//  libhooker configurator
//
//  Created by CoolStar on 1/25/21.
//  Copyright © 2021 coolstar. All rights reserved.
//

#include "launchd-list.h"
#include <xpc/xpc.h>

//launchd functions (Thanks J)
extern int xpc_pipe_routine (xpc_object_t xpc_pipe, xpc_object_t inDict, xpc_object_t *reply);
extern char *xpc_strerror (int);

#define ROUTINE_DUMP_PROCESS    0x2c4
#define ROUTINE_LIST        0x32f    // 815

#define HANDLE_SYSTEM 0

// os_alloc_once_table:
//
// Ripped this from XNU's libsystem
#define OS_ALLOC_ONCE_KEY_MAX    100

struct _os_alloc_once_s {
    long once;
    void *ptr;
};

extern struct _os_alloc_once_s _os_alloc_once_table[];

// XPC sets up global variables using os_alloc_once. By reverse engineering
// you can determine the values. The only one we actually need is the fourth
// one, which is used as an argument to xpc_pipe_routine

struct xpc_global_data {
    uint64_t    a;
    uint64_t    xpc_flags;
    mach_port_t    task_bootstrap_port;  /* 0x10 */
#ifndef _64
    uint32_t    padding;
#endif
    xpc_object_t    xpc_bootstrap_pipe;   /* 0x18 */
    // and there's more, but you'll have to wait for MOXiI 2 for those...
    // ...
};

static xpc_object_t xpc_bootstrap_pipe(void) {
    struct xpc_global_data *xpc_gd = _os_alloc_once_table[1].ptr;
    return xpc_gd->xpc_bootstrap_pipe;
}

NSData *programPrefix = nil;
NSData *lineBreak = nil;

NSString *lookupService(const char *label){
    if (!programPrefix){
        programPrefix = [@"\tprogram = " dataUsingEncoding:NSUTF8StringEncoding];
    }
    if (!lineBreak){
        lineBreak = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    int fds[2];
    if (pipe(fds)){
        return nil;
    }
    fcntl(fds[0], F_SETFL, O_NONBLOCK);
    
    xpc_object_t dict = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_uint64(dict, "handle", 0);
    xpc_dictionary_set_string(dict, "name", label);
    xpc_dictionary_set_uint64(dict, "routine", ROUTINE_DUMP_PROCESS);
    xpc_dictionary_set_uint64(dict, "subsystem", 2); // subsystem (2)
    xpc_dictionary_set_uint64(dict, "type", 1);
    xpc_dictionary_set_fd(dict, "fd", fds[1]);
    
    xpc_object_t outDict = NULL;
    int rc = xpc_pipe_routine(xpc_bootstrap_pipe(), dict, &outDict);
    if (rc == 0){
        int err = (int)xpc_dictionary_get_int64(outDict, "error");
        if (err){
            printf("Error: %d\n", err);
        }
    }
    close(fds[1]);
    NSMutableData *data = [NSMutableData data];
    
    ssize_t bytes;
    
    char buffer[1024];
    while ((bytes = read(fds[0], buffer, 1024)) > 0){
        [data appendData:[NSData dataWithBytes:buffer length:bytes]];
    }
    close(fds[0]);
    
    NSRange prefixRange = [data rangeOfData:programPrefix options:0 range:NSMakeRange(0, data.length)];
    if (prefixRange.location == NSNotFound){
        return nil;
    }
    NSRange breakRange = [data rangeOfData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(prefixRange.location, data.length - prefixRange.location)];
    if (breakRange.location == NSNotFound){
        return nil;
    }
    
    NSData *subdata = [data subdataWithRange:NSMakeRange(prefixRange.location + prefixRange.length, breakRange.location - (prefixRange.location + prefixRange.length))];
    NSString *rawData = [[NSString alloc] initWithData:subdata encoding:NSUTF8StringEncoding];
    return rawData;
}

NSArray<NSArray <NSString *> *> *cachedLaunchdList = nil;
NSArray<NSArray <NSString *> *> *launchdList(void){
    if (cachedLaunchdList){
        return cachedLaunchdList;
    }
    NSMutableArray *launchdArray = [NSMutableArray array];
    
    xpc_object_t dict = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_uint64(dict, "subsystem", 3); // subsystem (3)
    xpc_dictionary_set_uint64(dict, "handle", HANDLE_SYSTEM);
    xpc_dictionary_set_uint64(dict, "routine", ROUTINE_LIST);
    xpc_dictionary_set_uint64(dict, "type", 1); // set to 1
    xpc_dictionary_set_bool(dict, "legacy", 1); // mandatory
    
    xpc_object_t outDict = NULL;
    int rc = xpc_pipe_routine(xpc_bootstrap_pipe(), dict, &outDict);
    if (rc == 0){
        uint64_t err = xpc_dictionary_get_int64(outDict, "error");
        if (!err){
            //We actually got a reply!
            xpc_object_t svcs = xpc_dictionary_get_value(outDict, "services");
            if (!svcs){
                NSLog(@"No services returned for list");
                return nil;
            }
            
            xpc_type_t svcsType = xpc_get_type(svcs);
            if (svcsType != XPC_TYPE_DICTIONARY){
                NSLog(@"Error: services returned for list aren't a dictionary!");
                return nil;
            }
            
            xpc_dictionary_apply(svcs, ^bool(const char * _Nonnull label, xpc_object_t  _Nonnull value) {
                if (strncmp(label, "UIKitApplication:", 17) == 0){
                    return 1;
                }
                if (strcmp(label, "jailbreakd") == 0){
                    return 1;
                }
                if (strcmp(label, "amfidebilitate") == 0){
                    return 1;
                }
                
                NSString *path = lookupService(label);
                if (!path){
                    return 1;
                }
                [launchdArray addObject:@[[path lastPathComponent],path]];
                return 1;
            });
        }
    } else {
        NSLog(@"Unable to get launchd: %d", rc);
    }
    
    cachedLaunchdList = [NSArray arrayWithArray:launchdArray];
    return cachedLaunchdList;
}
