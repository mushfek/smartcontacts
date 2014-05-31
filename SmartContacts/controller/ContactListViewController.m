//
//  ContactListViewController.m
//  SmartContacts
//
//  Created by Sharafat Ibn Mollah Mosharraf on 5/30/14.
//  Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "ContactListViewController.h"

#import "ContactDetailsViewController.h"
#import "ContactDao.h"
#import "ObjectionExtension.h"
#import "Contact.h"
#import "Phone.h"
#import "ContactListTableViewCell.h"
#import "NSString+NSStringExtension.h"
#import "Mail.h"
#import "Url.h"

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
    [self configureView];
}

- (void)configureView {
    [contactDao retrieveContactList];
    contacts = [contactDao getContactList];

    //Add left swap recognizer
    UISwipeGestureRecognizer *swipeRecognizer =
            [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onCellSwipedLeft:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:swipeRecognizer];

    //Add right swap recognizer
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onCellSwipedRight:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:swipeRecognizer];
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
            (ContactListTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

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
    } else if (contact.phone != nil) {
        cell.contactSubtitleLabel.text = contact.phone;
    } else {
        cell.contactSubtitleLabel.text = @"";
    }

    UIImage *image = [UIImage imageWithData:contact.photo];
    [cell.contactPhoto setImage:image];

    return cell;
}

- (void)onCellSwipedLeft:(UIGestureRecognizer *)swipeRecognizer {
    CGPoint point = [swipeRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [(UITableView *) self.view indexPathForRowAtPoint:point];
    if (indexPath != nil) {
        Contact *contact = nil;
        if (self.tableView == self.searchDisplayController.searchResultsTableView) {
            contact = [searchResult objectAtIndex:(NSUInteger) indexPath.row];
        } else {
            contact = [contacts objectAtIndex:(NSUInteger) indexPath.row];
        }
//        if ([contact.phones count] > 0) {   //Send SMS if mobile number exists
//            Phone *phone = (Phone *) [contact.phones anyObject];
        if (contact.phone != nil) {
            MFMessageComposeViewController *smsComposeViewController = [[MFMessageComposeViewController alloc] init];
            smsComposeViewController.recipients = @[contact.phone];
            smsComposeViewController.messageComposeDelegate = self;

            [self presentViewController:smsComposeViewController animated:YES completion:nil];
//        } else if ([contact.urls count] > 0) {    //start browsing if website exists
//            Url *url = (Url *) [contact.urls anyObject];
        } else if (contact.url != nil) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:contact.url]];
        } else {
            NSLog(@"Couldn't perform any action on left swipe.");
        }
    }
}

- (void)onCellSwipedRight:(UIGestureRecognizer *)swipeRecognizer {
    CGPoint point = [swipeRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [(UITableView *) self.view indexPathForRowAtPoint:point];
    if (indexPath != nil) {
        Contact *contact = nil;
        if (self.tableView == self.searchDisplayController.searchResultsTableView) {
            contact = [searchResult objectAtIndex:(NSUInteger) indexPath.row];
        } else {
            contact = [contacts objectAtIndex:(NSUInteger) indexPath.row];
        }

//        if ([contact.phones count] > 0) {   //Call if mobile number exists
//            Phone *phone = (Phone *) [contact.phones anyObject];
        if (contact.phone != nil) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:concat(@"telprompt://", contact.phone)]];
//        } else if ([contact.mails count] > 0) {    //start mailing if email exists
//            Mail *email = (Mail *) [contact.mails anyObject];
        } else if (contact.mail != nil) {
            MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
            [mailComposeViewController setToRecipients:@[contact.mail]];
            mailComposeViewController.mailComposeDelegate = self;

            [self presentViewController:mailComposeViewController animated:YES completion:nil];
        } else {
            NSLog(@"Couldn't perform any action on right swipe.");
        }
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {

    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {

    [self dismissViewControllerAnimated:YES completion:nil];
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

        Contact *contact = nil;
        if (self.tableView == self.searchDisplayController.searchResultsTableView) {
            contact = [searchResult objectAtIndex:(NSUInteger) indexPath.row];
        } else {
            contact = [contacts objectAtIndex:(NSUInteger) indexPath.row];
        }

        [(ContactDetailsViewController *)[segue destinationViewController] setDetailItem:contact];
    }
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"firstName contains[c] %@", searchText];
    searchResult = [contacts filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL) searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                       objectAtIndex:(NSUInteger) [self.searchDisplayController.searchBar
                                               selectedScopeButtonIndex]]];

    return YES;
}


@end
