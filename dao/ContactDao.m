//
// Created by Mushfek on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "ContactDao.h"
#import "Objection.h"
#import "AppDelegate.h"
#import "Contact.h"

@interface ContactDao() {
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, strong) NSMutableArray *contactList;

@end

@implementation ContactDao

objection_register_singleton(ContactDao)

- (instancetype)init {
    self = [super init];
    if (self) {
        managedObjectContext = get_managed_object_context();
        _contactList = [[NSMutableArray alloc] init];
    }

    return self;
}

- (NSUInteger)contactCount {
    return [self.contactList count];
}

- (Contact *)contactAtIndex:(NSUInteger)index {
    return [self.contactList objectAtIndex:index];
}

- (void)addContact:(Contact *)contact {

    Contact *newContact = [[Contact alloc] init];
    newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact"
                                                   inManagedObjectContext:managedObjectContext];
    [_contactList addObject:newContact];

    [newContact setValue:[NSNumber numberWithUnsignedInteger:contact.contactId] forKey:@"contactId"];
    [newContact setValue:contact.firstName forKey:@"firstName"];
    [newContact setValue:contact.lastName forKey:@"lastName"];
    [newContact setValue:contact.photo forKey:@"photo"];
    [newContact setValue:contact.notes forKey:@"notes"];

    [newContact setValue:contact.phones forKey:@"phones"];
    [newContact setValue:contact.addresses forKey:@"addresses"];
    [newContact setValue:contact.organizations forKey:@"organizations"];
    [newContact setValue:contact.mails forKey:@"mails"];
    [newContact setValue:contact.ims forKey:@"ims"];
    [newContact setValue:contact.socialProfiles forKey:@"socialProfiles"];
    [newContact setValue:contact.urls forKey:@"urls"];

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error saving card: %@", error.description);
    }
}

- (Contact *)getContactById:(Contact *)contact {
    return (Contact *) [self getManagedContact:contact];
}

- (id)getManagedContact:(Contact *)contact {
    NSError *error = NULL;
    NSMutableArray *contactByIdFetchResults;

    NSFetchRequest *cardByIdFetchRequest = [[NSFetchRequest alloc] init];
    [cardByIdFetchRequest setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:managedObjectContext]];
    [cardByIdFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"contactId == %@", contact.contactId]];
    contactByIdFetchResults = [[managedObjectContext executeFetchRequest:cardByIdFetchRequest error:&error] mutableCopy];

    if (!contactByIdFetchResults) {
        NSLog(@"Error fetching contactByContactId: %@", error.description);
        return nil;
    } else if ([contactByIdFetchResults count] == 0) {
        NSLog(@"No contact found by contactId: %u", contact.contactId);
        return nil;
    }

    return [contactByIdFetchResults objectAtIndex:0];
}

@end
