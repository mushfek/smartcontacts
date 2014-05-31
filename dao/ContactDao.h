//
// Created by Mushfek on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Contact;

@interface ContactDao : NSObject

- (NSUInteger)contactCount;

- (Contact *)contactAtIndex:(NSUInteger)index;

- (void)addContact:(Contact *)contact;

- (Contact *)getContactById:(Contact *)contact;

- (void)retrieveContactList;

@end
