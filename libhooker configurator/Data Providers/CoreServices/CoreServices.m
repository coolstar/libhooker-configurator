//
//  CoreServices.m
//  libhooker configurator
//
//  Created by CoolStar on 1/25/21.
//  Copyright © 2021 coolstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreServices.h"

@implementation LSApplicationProxy (libhooker)
- (NSString *)LHIdentifier {
    if ([self respondsToSelector:@selector(_boundApplicationIdentifier)])
        return [self _boundApplicationIdentifier];
    return [self applicationIdentifier];
}
@end
