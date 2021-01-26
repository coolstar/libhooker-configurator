//
//  CoreServices.h
//  libhooker configurator
//
//  Created by CoolStar on 1/25/21.
//  Copyright © 2021 coolstar. All rights reserved.
//

#import <CoreServices/CoreServices.h>

#ifndef CoreServices_h
#define CoreServices_h

@interface LSApplicationProxy : NSObject
- (nullable NSURL *)bundleURL;
- (nullable NSString *)localizedName;
- (nullable NSString *)applicationIdentifier;
- (nullable NSString *)_boundApplicationIdentifier;
- (nullable NSString *)LHIdentifier;
@end

@interface LSApplicationWorkspace : NSObject
+ (nonnull instancetype)defaultWorkspace;
- (nonnull NSArray<LSApplicationProxy *> *)allInstalledApplications;
@end

#endif /* CoreServices_h */
