//
// Created by Mushfek on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Mail;


@interface Contact : NSObject

@property (nonatomic, assign) NSUInteger contactId;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, retain) NSData *photo;
@property (nonatomic, copy) NSString *notes;

@property (nonatomic, copy) NSSet *phones;
@property (nonatomic, copy) NSSet *addresses;
@property (nonatomic, copy) NSSet *organizations;
@property (nonatomic, copy) NSSet *mails;
@property (nonatomic, copy) NSSet *ims;
@property (nonatomic, copy) NSSet *socialProfiles;
@property (nonatomic, copy) NSSet *urls;

@end