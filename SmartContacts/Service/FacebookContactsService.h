//
// Created by Arefeen on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FacebookContactsService : NSObject

- (void)loginByUserName:(NSString *)userName password:(NSString *)password andDo:(void(^)(NSError *, id))onResult;

- (void)fetchContactsByUserName:(NSString *)userName password:(NSString *)password;

@end