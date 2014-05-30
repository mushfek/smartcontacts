//
// Created by Arefeen on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "GoogleContactsService.h"
#import "GData/GDataContacts.h"
#import "Objection.h"


@implementation GoogleContactsService {
    void (^onResultBlock)(NSError *, id);
}

objection_register_singleton(GoogleContactsService)

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

- (void)fetchContactsByUserName:(NSString *)userName password:(NSString *)password {
    GDataServiceGoogleContact *service = [[GDataServiceGoogleContact alloc] init];
    [service setUserCredentialsWithUsername:userName password:password];
    [service fetchContactFeedForUsername:userName
                                delegate:self
                       didFinishSelector:@selector(ticket:finishedWithContactFeed:error:)];
}

- (void)ticket:(GDataServiceTicket *)ticket finishedWithContactFeed:(GDataFeedContact *)feed error:(NSError *)error {
//    This helps to see the name of the contact along with emails
    NSArray *feedEntries = [feed entries];
    for(NSUInteger i = 0; i < [feedEntries count]; i = (i + 1) ) {
        GDataName * contactName = [[feedEntries objectAtIndex:i] name];

        NSLog(@"Give: %@, Family: %@, Full: %@", contactName.givenName.stringValue
                , contactName.familyName.stringValue, contactName.fullName.stringValue);

        NSArray *emailAddresses = [[feedEntries objectAtIndex:i] emailAddresses];
        for (NSUInteger j = 0; j < [emailAddresses count]; j = (j + 1)) {
            NSLog(@"   Email: %@", [[emailAddresses objectAtIndex:j] address]);
        }
    }
}

@end