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

@end