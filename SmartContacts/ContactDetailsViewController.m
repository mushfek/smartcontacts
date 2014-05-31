//
//  ContactDetailsViewController.m
//  SmartContacts
//
//  Created by Sharafat Ibn Mollah Mosharraf on 5/30/14.
//  Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "ContactDetailsViewController.h"
#import "Contact.h"
#import "NSString+NSStringExtension.h"
#import "GDataEntryContent.h"

@interface ContactDetailsViewController ()
- (void)configureView;
@end

@implementation ContactDetailsViewController

- (void)configureView {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    [self assignContactInformation];
}

- (void)assignContactInformation {
    self.contactPhoto.image = [UIImage imageWithData:self.detailItem.photo];

    NSString *contactFullName;
    if (self.detailItem.firstName != nil) {
        contactFullName = self.detailItem.firstName;
        if (self.detailItem.lastName != nil) {
            contactFullName = concat(contactFullName, @" ", self.detailItem.lastName);
        }
    } else {
        contactFullName = self.detailItem.lastName;
    }
    self.contactName.text = contactFullName;

    self.contactPhone.text = [[self.detailItem.phones anyObject] stringValue];
    self.contactEmailAddress.text = [[self.detailItem.mails anyObject] stringValue];
    self.contactAddress.text = [[self.detailItem.addresses anyObject] stringValue];
    self.contactIms.text = [[self.detailItem.ims anyObject] stringValue];
    self.contactOrganization.text = [[self.detailItem.organizations anyObject] stringValue];
    self.contactSocialProfile.text = [[self.detailItem.socialProfiles anyObject] stringValue];
    self.contactUrl.text = [[self.detailItem.urls anyObject] stringValue];
}
- (IBAction)editButtonPressed:(id)sender {
}

@end
