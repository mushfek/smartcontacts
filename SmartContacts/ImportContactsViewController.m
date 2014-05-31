//
// Created by Sharafat Ibn Mollah Mosharraf on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "ImportContactsViewController.h"
#import "GoogleContactsService.h"
#import "ObjectionExtension.h"
#import "FacebookContactsService.h"
#import "ContactDao.h"
#import "Contact.h"
#import "NSObject+NSObjectExtension.h"
#import "AddressBookContactsService.h"

#define Semaphore int

@implementation ImportContactsViewController {
    NSString *googlePlusEmailId;
    NSString *googlePlusPassword;
    BOOL shouldImportFacebookFriends;
    GoogleContactsService *_googleContactsService;
    FacebookContactsService *_facebookContactsService;
    AddressBookContactsService *_addressBookContactsService;
    ContactDao *_contactDao;
    Semaphore noOfTasksWaitingToBeCompleted;
    BOOL anyErrorOccurredWhileImporting;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    _googleContactsService = objection_inject(GoogleContactsService)
    _facebookContactsService = objection_inject(FacebookContactsService)
    _addressBookContactsService = objection_inject(AddressBookContactsService)

    _contactDao = objection_inject(ContactDao)
}

- (void)setGooglePlusEmailId:(NSString *)email andPassword:(NSString *)password
andIfFacebookFriendsShouldBeImported:(BOOL)importFacebookFriends {
    googlePlusEmailId = email;
    googlePlusPassword = password;
    shouldImportFacebookFriends = importFacebookFriends;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (void)configureView {
    anyErrorOccurredWhileImporting = NO;
    noOfTasksWaitingToBeCompleted = 0;
    int rowIdentifier = 2;

    [self importPhoneContacts];
    noOfTasksWaitingToBeCompleted++;

    if ([self shouldImportFacebookContacts]) {
        [self importFacebookContactsWithRowIdentifier:rowIdentifier];
        rowIdentifier++;
        noOfTasksWaitingToBeCompleted++;
    }

    if ([self shouldImportGoogleContacts]) {
        [self importGoogleContactsWithRowIdentifier:rowIdentifier];
        noOfTasksWaitingToBeCompleted++;
    }
}

- (BOOL)shouldImportFacebookContacts {
    return shouldImportFacebookFriends;
}

- (BOOL)shouldImportGoogleContacts {
    return [googlePlusEmailId isNotEmpty];
}

- (void)importPhoneContacts {
    [self showLoadingIndicator:self.loadingImage1];

    NSMutableArray *addressBookContacts = [_addressBookContactsService fetchContactsFromAddressBook];
    for (int i = 0; i < [addressBookContacts count]; i++) {
        Contact *newContact = [addressBookContacts objectAtIndex:i];
        [_contactDao addContact:newContact];
    }

    [self showIndicator:self.statusImage1 forStatus:TRUE andHide:self.loadingImage1];
    self.importingContactsLabel1.text = @"Imported phone contacts.";

    [self doIfNoTasksAreWaiting];
}

- (void)doIfNoTasksAreWaiting {
    noOfTasksWaitingToBeCompleted--;
    if (noOfTasksWaitingToBeCompleted == 0 && !anyErrorOccurredWhileImporting) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            sleep(5);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"showContactsList" sender:self];
            });
        });
    }
}

- (void)importFacebookContactsWithRowIdentifier:(int)rowIdentifier {
    UIActivityIndicatorView *loadingImage = nil;
    UILabel *importingContactsLabel = nil;
    UIImageView *statusImage = nil;

    [self setLoadingImage:&loadingImage
andImportingContactsLabel:&importingContactsLabel
           andStatusImage:&statusImage
         forRowIndetifier:rowIdentifier];

    [self showLoadingIndicator:loadingImage];
    importingContactsLabel.hidden = NO;

    [_facebookContactsService fetchContactsAndDo:^(NSError *error, id friendList) {
        BOOL statusSuccess = error == nil;
        if (statusSuccess) {
            for (NSString *friendId in [(NSDictionary *) friendList allKeys]) {
                NSDictionary *friendDetails = [friendList valueForKey:friendId];
                Contact *contact = [[Contact alloc] init];
                contact.firstName = [friendDetails valueForKey:@"firstName"];
                contact.lastName = [friendDetails valueForKey:@"lastName"];
                contact.photo = [friendDetails valueForKey:@"photo"];

                NSLog(@"Import from FaceBook: firstName=%@, lastName=%@, hasPhoto=%d",
                        contact.firstName, contact.lastName, contact.photo != nil);

                [_contactDao addContact:contact];
            }

            [self showIndicator:statusImage forStatus:statusSuccess andHide:loadingImage];
            importingContactsLabel.text = @"Imported Facebook contacts.";
        } else {
            [self showIndicator:statusImage forStatus:statusSuccess andHide:loadingImage];
            importingContactsLabel.text = @"Failed importing Facebook Contacts!";
            anyErrorOccurredWhileImporting = TRUE;
        }

        [self doIfNoTasksAreWaiting];
    }];
}

- (void)  setLoadingImage:(UIActivityIndicatorView **)loadingImage
andImportingContactsLabel:(UILabel **)importingContactsLabel
           andStatusImage:(UIImageView **)statusImage
         forRowIndetifier:(int)rowIdentifier {

    switch (rowIdentifier) {
        case 2:
            *loadingImage = self.loadingImage2;
            *importingContactsLabel = self.importingContactsLabel2;
            *statusImage = self.statusImage2;
            break;
        case 3:
            *loadingImage = self.loadingImage3;
            *importingContactsLabel = self.importingContactsLabel3;
            *statusImage = self.statusImage3;
            break;
        default:
            break;
    }
}

- (void)importGoogleContactsWithRowIdentifier:(int)rowIdentifier {
    UIActivityIndicatorView *loadingImage = nil;
    UILabel *importingContactsLabel = nil;
    UIImageView *statusImage = nil;

    [self setLoadingImage:&loadingImage
andImportingContactsLabel:&importingContactsLabel
           andStatusImage:&statusImage
         forRowIndetifier:rowIdentifier];

    [self showLoadingIndicator:loadingImage];
    importingContactsLabel.hidden = NO;

    [_googleContactsService fetchContactsByUserName:googlePlusEmailId
                                           password:googlePlusPassword
                                              andDo:^(NSError *error, id objectReturned) {
        BOOL statusSuccess = error == nil;
        importingContactsLabel.text = statusSuccess ? @"Imported Google Plus contacts." : @"Failed importing Google Plus Contacts!";
        [self showIndicator:statusImage forStatus:statusSuccess andHide:loadingImage];
        anyErrorOccurredWhileImporting = error != nil;

        [self doIfNoTasksAreWaiting];
    }];
}

- (void)showLoadingIndicator:(UIActivityIndicatorView *)activityIndicatorView {
    activityIndicatorView.hidden = NO;
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicatorView startAnimating];
}

- (void)showIndicator:(UIImageView *)imageView forStatus:(BOOL)status andHide:(UIActivityIndicatorView *)loadingIndicator {
    loadingIndicator.hidden = YES;
    [loadingIndicator stopAnimating];
    imageView.hidden = NO;
    imageView.image = [UIImage imageNamed:(status ? @"Success" : @"Failure")];
}

@end
