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
