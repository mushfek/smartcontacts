//
// Created by Arefeen on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "GoogleContactsService.h"
#import "GData/GDataContacts.h"
#import "Objection.h"
#import "Contact.h"
#import "Mail.h"
#import "ContactDao.h"

@interface GoogleContactsService ()

@property(nonatomic, strong) ContactDao *contactDao;

@end

@implementation GoogleContactsService {
    void (^onResultBlock)(NSError *, id);
}

objection_register_singleton(GoogleContactsService)

objection_requires(@"contactDao")

- (void)loginByUserName:(NSString *)userName password:(NSString *)password andDo:(void(^)(NSError *, id))onResult {
    onResultBlock = onResult;

    GDataServiceGoogleContact *service = [[GDataServiceGoogleContact alloc] init];
    [service setUserCredentialsWithUsername:userName password:password];

    [service fetchContactFeedForUsername:userName
                                              delegate:self
                                     didFinishSelector:@selector(ticket:feed:error:)];
}

- (void)ticket:(GDataServiceTicket *)ticket feed:(GDataFeedContact *)feed error:(NSError *)error {
    onResultBlock(error, nil);
}

- (void)fetchContactsByUserName:(NSString *)userName password:(NSString *)password andDo:(void(^)(NSError *, id))onResult {
    onResultBlock = onResult;

    GDataServiceGoogleContact *service = [[GDataServiceGoogleContact alloc] init];
    [service setUserCredentialsWithUsername:userName password:password];
    [service fetchContactFeedForUsername:userName
                                delegate:self
                       didFinishSelector:@selector(ticket:finishedWithContactFeed:error:)];
}

- (void)ticket:(GDataServiceTicket *)ticket finishedWithContactFeed:(GDataFeedContact *)feed
         error:(NSError *)error {
    if (error == nil) {
        Contact *contact;
        GDataName * contactName;
        NSUInteger counter = 11000;

        NSArray *feedEntries = [feed entries];
        for(NSUInteger i = 0; i < [feedEntries count]; i = (i + 1) ) {
            contactName = [[feedEntries objectAtIndex:i] name];

            if (contactName.givenName.stringValue == nil
                    && contactName.familyName.stringValue == nil) {
                continue;
            }

            contact = [Contact alloc];
            [contact setContactId:counter];
            counter += 1;
            [contact setFirstName:contactName.givenName.stringValue];
            [contact setLastName:contactName.familyName.stringValue];

            [contact setNotes:nil];
            [contact setPhones:nil];
            [contact setOrganizations:nil];
            [contact setMails:nil];
            [contact setIms:nil];
            [contact setSocialProfiles:nil];
            [contact setUrls:nil];

            NSSet *emails = [[NSSet alloc] init];
            Mail *email;

            NSArray *emailAddresses = [[feedEntries objectAtIndex:i] emailAddresses];
            for (NSUInteger j = 0; j < [emailAddresses count]; j = (j + 1)) {
                email = [Mail alloc];
                [email setMailAddress:[[emailAddresses objectAtIndex:j] address]];
                [email setType:@"Other"];
                [emails setByAddingObject:email];
            }

            [contact setAddresses:emails];
            [_contactDao addContact:contact];
        }

        onResultBlock(nil, nil);
    } else {
        onResultBlock(error, nil);
    }
}

@end
