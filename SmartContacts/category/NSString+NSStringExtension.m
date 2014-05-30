//
// Created by Sharafat Ibn Mollah Mosharraf on 5/22/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "NSString+NSStringExtension.h"


@implementation NSString (NSStringExtension)

/**
* Collected From:
* http://stackoverflow.com/questions/4804674/how-to-create-variable-argument-methods-in-objective-c#answer-22014174
*/
+ (NSString *)concat:(NSString *)string, ... {
    NSMutableString *concatenatedString = [NSMutableString string];
    [concatenatedString appendString:string];

    va_list args;
    va_start(args, string);

    NSString *arg = nil;
    while ((arg = va_arg(args, NSString*))) {
        [concatenatedString appendString:arg];
    }

    va_end(args);

    return concatenatedString;
}

@end
