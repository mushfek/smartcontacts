//
// Created by Sharafat Ibn Mollah Mosharraf on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "ImportContactsCredentialsInputViewController.h"
#import "CustomUITextField.h"


@implementation ImportContactsCredentialsInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupGestureToHideKeyboard];
}

- (void)setupGestureToHideKeyboard {
    UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapScroll.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tapScroll];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)skipImportingContacts:(id)sender {
    [[[UIAlertView alloc]
            initWithTitle:@"Skipping Contact Import"
                  message:@"You can import contacts from your social networks later from Settings -> Import Contacts."
                 delegate:self
        cancelButtonTitle:nil
        otherButtonTitles:@"OK", nil]
            show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self performSegueWithIdentifier:@"skipToContactList" sender:self];
}

- (IBAction)importContacts:(id)sender {
    if ([self validateForm] && [self login]) {
        [self saveCredentials];
        [self performSegueWithIdentifier:@"importContacts" sender:self];
    }
}

- (BOOL)validateForm {
    //TODO
    return YES;
}

- (BOOL)login {
    //TODO
    return YES;
}

- (void)saveCredentials {
    //TODO
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [(CustomUITextField *) textField shouldReturn];
}

@end
