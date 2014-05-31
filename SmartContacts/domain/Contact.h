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

@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *organization;
@property (nonatomic, copy) NSString *mail;
@property (nonatomic, copy) NSString *im;
@property (nonatomic, copy) NSString *socialProfile;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSMutableSet *phones;
@property (nonatomic, copy) NSMutableSet *addresses;
@property (nonatomic, copy) NSMutableSet *organizations;
@property (nonatomic, copy) NSMutableSet *mails;
@property (nonatomic, copy) NSMutableSet *ims;
@property (nonatomic, copy) NSMutableSet *socialProfiles;
@property (nonatomic, copy) NSMutableSet *urls;

@end
