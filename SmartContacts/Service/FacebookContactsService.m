//
// Created by Arefeen on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "Objection.h"
#import "FacebookContactsService.h"


@implementation FacebookContactsService {
    void (^onResultBlock)(NSError *, id);
}

objection_register_singleton(FacebookContactsService)

- (void)loginByUserName:(NSString *)userName password:(NSString *)password andDo:(void(^)(NSError *, id))onResult {
    onResultBlock = onResult;

    //TODO
    onResult(nil, nil);
}

- (void)fetchContactsByUserName:(NSString *)userName password:(NSString *)password {
    //TODO
}

@end