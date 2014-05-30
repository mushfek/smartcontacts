//
// Created by Sharafat Ibn Mollah Mosharraf on 5/22/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "NSObject+NSObjectExtension.h"

@implementation NSObject (NSObjectExtension)

- (BOOL)isNotEmpty {
    return !(self == nil
            || [self isKindOfClass:[NSNull class]]
            || ([self respondsToSelector:@selector(length)] && [(NSData *) self length] == 0)
            || ([self respondsToSelector:@selector(count)] && [(NSArray *) self count] == 0));

};

@end
