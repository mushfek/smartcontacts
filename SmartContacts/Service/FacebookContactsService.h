//
// Created by Arefeen on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FacebookContactsService : NSObject

- (void)loginAndDo:(void(^)(NSError *, id))onResult;

- (void)fetchContactsAndDo:(void (^)(NSError *, id))onResult;

@end
