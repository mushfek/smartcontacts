//
// Created by Sharafat Ibn Mollah Mosharraf on 5/22/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

//The concat macro has been collected from:
//http://stackoverflow.com/questions/510269/how-do-i-concatenate-strings#answer-16862414
#define concat(...) [@[__VA_ARGS__] componentsJoinedByString:@""]

@interface NSString (NSStringExtension)

+ (NSString *)concat:(NSString *)string, ...;

@end
