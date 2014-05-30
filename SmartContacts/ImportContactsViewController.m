//
// Created by Sharafat Ibn Mollah Mosharraf on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "ImportContactsViewController.h"


@implementation ImportContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (void)configureView {
    int rowIdentifier = 2;

    [self importPhoneContacts];

    if ([self shouldImportFacebookContacts]) {
        [self importFacebookContactsWithRowIdentifier:rowIdentifier];
        rowIdentifier++;
    }

    if ([self shouldImportGoogleContacts]) {
        [self importGoogleContactsWithRowIdentifier:rowIdentifier];
    }

    //TODO: When all contacts have been imported:
    [self performSegueWithIdentifier:@"showContactsList" sender:self];
}

- (BOOL)shouldImportFacebookContacts {
    //TODO
    return YES;
}

- (BOOL)shouldImportGoogleContacts {
    //TODO
    return YES;
}

- (void)importPhoneContacts {
    [self showLoadingIndicator:self.loadingImage1];

    //Import Contacts and then:
    [self showIndicator:self.statusImage1 forStatus:TRUE andHide:self.loadingImage1];
    self.importingContactsLabel1.text = @"Imported phone contacts.";
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

    //Import Contacts and then:
    BOOL status = FALSE;
    [self showIndicator:statusImage forStatus:status andHide:loadingImage];
    importingContactsLabel.text = status ? @"Imported Facebook contacts." : @"Failed importing Facebook Contacts!";
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

    //Import Contacts and then:
    BOOL status = TRUE;
    [self showIndicator:statusImage forStatus:status andHide:loadingImage];
    importingContactsLabel.text = status ? @"Imported Google Plus contacts." : @"Failed importing Google Plus Contacts!";
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
