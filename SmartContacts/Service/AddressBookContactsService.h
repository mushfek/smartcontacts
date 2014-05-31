//
// Created by Mushfek on 5/31/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AddressBookContactsService : NSObject

- (void)fetchContactsFromAddressBookAndDo:(void (^)(NSError *, id))onResult;

@end
