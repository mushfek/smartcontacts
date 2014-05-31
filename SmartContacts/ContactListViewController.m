//
//  ContactListViewController.m
//  SmartContacts
//
//  Created by Sharafat Ibn Mollah Mosharraf on 5/30/14.
//  Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "ContactListViewController.h"

#import "ContactDetailsViewController.h"
#import "ContactDao.h"
#import "ObjectionExtension.h"
#import "Contact.h"
#import "Phone.h"
#import "ContactListTableViewCell.h"
#import "NSString+NSStringExtension.h"

@interface ContactListViewController () {
    ContactDao *contactDao;
}
@end

@implementation ContactListViewController

NSArray *contacts;
NSArray *searchResult;

- (void)awakeFromNib {
    contactDao = objection_inject(ContactDao);
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [contactDao retrieveContactList];
    contacts = [contactDao getContactList];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                          target:self
                                                          action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [(UITableView *) self.view reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResult count];

    } else {
        return [contacts count];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)insertNewObject:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject =
            [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];

    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];

    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 71;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    ContactListTableViewCell *cell =
            (ContactListTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[ContactListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:CellIdentifier];
    }

    Contact *contact = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        contact = [searchResult objectAtIndex:(NSUInteger) indexPath.row];
    } else {
        contact = [contacts objectAtIndex:(NSUInteger) indexPath.row];
    }

    NSString *fullName;
    if (contact.firstName != nil) {
        fullName = contact.firstName;
        if (contact.lastName != nil) {
            fullName = concat(fullName, @" ", contact.lastName);
        }
    } else {
        if (contact.lastName != nil) {
            fullName = contact.lastName;
        }
    }

    cell.contactNameLabel.text = fullName;

    if ([contact.phones count] > 0) {
        NSArray *phoneNumbers = [contact.phones allObjects];
        Phone *phone = [phoneNumbers objectAtIndex:0];

        NSString *phoneString;
        if (phone.type != nil) {
            phoneString = phone.type;
            if (phone.phoneNumber != nil) {
                phoneString = concat(phoneString, @" (", phone.phoneNumber, @")");
            }
            cell.contactSubtitleLabel.text = phoneString;
        } else {
            if (phone.phoneNumber != nil) {
                cell.contactSubtitleLabel.text = phone.phoneNumber;
            } else {
                cell.contactSubtitleLabel.text = @"";
            }
        }
    } else {
        cell.contactSubtitleLabel.text = @"";
    }

    UIImage *image = [UIImage imageWithData:contact.photo];
    [cell.contactPhoto setImage:image];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
            forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];

        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    [fetchRequest setFetchBatchSize:20];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController =
            [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                managedObjectContext:self.managedObjectContext
                                                  sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
                    didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"firstName contains[c] %@", searchText];
    searchResult = [contacts filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
        shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                       objectAtIndex:(NSUInteger) [self.searchDisplayController.searchBar
                                                                                      selectedScopeButtonIndex]]];

    return YES;
}

@end
