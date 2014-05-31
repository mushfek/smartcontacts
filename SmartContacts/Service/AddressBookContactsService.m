//
// Created by Mushfek on 5/31/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "AddressBookContactsService.h"
#import "Objection.h"
#import "Contact.h"
#import "Mail.h"
#import "Im.h"
#import "SocialProfile.h"
#import "Phone.h"
#import "Address.h"


@implementation AddressBookContactsService

objection_register_singleton(AddressBookContactsService)

- (NSMutableArray *)fetchContactsFromAddressBook {
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);

    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);

        NSMutableArray *contactList = [[NSMutableArray alloc] init];
        for(int i = 0; i < numberOfPeople; i++) {
            ABRecordRef singleContact = CFArrayGetValueAtIndex( allPeople, i );

            NSString *firstName = (__bridge_transfer NSString *) ABRecordCopyValue(singleContact, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString *) ABRecordCopyValue(singleContact, kABPersonLastNameProperty);

            Contact *contact = [[Contact alloc] init];
            [contact setFirstName:firstName];
            [contact setLastName:lastName];

            //emails
            ABMultiValueRef emails = ABRecordCopyValue(singleContact, kABPersonEmailProperty);
            for (int j = 0; j < ABMultiValueGetCount(emails); j++) {
                NSString *email = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(emails, j);

                Mail *mail = [[Mail alloc] init];
                [mail setMailAddress:email];

                if (j == 0) {
                    [mail setType:@"home"];
                    [contact.mails setByAddingObject:mail];
                } else if (j == 1) {
                    [mail setType:@"office"];
                    [contact.mails setByAddingObject:mail];
                } else {
                    [mail setType:@"other"];
                    [contact.mails setByAddingObject:mail];
                }
            }

            //instant messengers
            ABMultiValueRef instantMessengers = ABRecordCopyValue(singleContact, kABPersonInstantMessageProperty);
            for (int k = 0; k < ABMultiValueGetCount(instantMessengers); k++) {
                CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(instantMessengers, k);

                Im *im = [[Im alloc] init];
                NSDictionary *nsdict = (__bridge NSDictionary *) dict;
                [im setImId:[nsdict valueForKey:@"username"]];
                [im setType:[nsdict valueForKey:@"service"]];

                [contact.ims setByAddingObject:im];
            }

            //social
            ABMultiValueRef socials = ABRecordCopyValue(singleContact, kABPersonSocialProfileProperty);
            for (int l = 0; l < ABMultiValueGetCount(socials); l++) {
                CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(socials, l);

                SocialProfile *socialProfile = [[SocialProfile alloc] init];
                NSDictionary *nsdict = (__bridge NSDictionary *) dict;
                [socialProfile setId:[nsdict valueForKey:@"twitterUserName"]];
                [socialProfile setType:@"twitter"];

                nsdict = (__bridge NSDictionary *) dict;
                [socialProfile setId:[nsdict valueForKey:@"facebookUserName"]];
                [socialProfile setType:@"facebook"];

                [contact.socialProfiles setByAddingObject:socialProfile];
            }

            //phone
            ABMultiValueRef phones = ABRecordCopyValue(singleContact, kABPersonPhoneProperty);
            for (int m = 0; m < ABMultiValueGetCount(phones); m++) {
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, m);
                CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, m);
                NSString *phoneLabel = (__bridge NSString *) ABAddressBookCopyLocalizedLabel(locLabel);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;

                Phone *phone = [[Phone alloc] init];
                [phone setType:phoneLabel];
                [phone setPhoneNumber:phoneNumber];

                [contact.phones setByAddingObject:phone];
            }

            //addresses
            ABMultiValueRef addresses = ABRecordCopyValue(singleContact, kABPersonAddressProperty);
            for (int n = 0; n < ABMultiValueGetCount(addresses); n++) {
                CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(addresses, n);
                Address *address = [[Address alloc] init];

                [address setType:@"home"];
                [address setStreet:(NSString *) CFDictionaryGetValue(dict, kABPersonAddressStateKey)];
                [address setCity:(NSString *) CFDictionaryGetValue(dict, kABPersonAddressCityKey)];
                [address setState:(NSString *) CFDictionaryGetValue(dict, kABPersonAddressStateKey)];
                [address setZipCode:(NSString *) CFDictionaryGetValue(dict, kABPersonAddressZIPKey)];

                [contact.addresses setByAddingObject:address];
            }
        }

        return contactList;
    } else {
        NSLog(@"Error: Couldn't fetch addressbook contacts due to privacy settings!");
    }

    return nil;
}

@end