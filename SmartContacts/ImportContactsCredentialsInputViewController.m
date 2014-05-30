//
// Created by Sharafat Ibn Mollah Mosharraf on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "ImportContactsCredentialsInputViewController.h"
#import "CustomUITextField.h"
#import "GoogleContactsService.h"
#import "ObjectionExtension.h"
#import "NSObject+NSObjectExtension.h"
#import "FacebookContactsService.h"


@implementation ImportContactsCredentialsInputViewController {
    GoogleContactsService *_googleContactsService;
    FacebookContactsService *_facebookContactsService;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    _googleContactsService = objection_inject(GoogleContactsService)
    _facebookContactsService = objection_inject(FacebookContactsService)
}

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
    if ([self validateForm]) {
        [self loginGooglePlus];
    }
}

- (BOOL)validateForm {
    //TODO
    return YES;
}

- (void)loginGooglePlus {
    if ([self.googlePlusEmailInput.text isNotEmpty]) {
        [_googleContactsService loginByUserName:self.googlePlusEmailInput.text
                                       password:self.googlePlusPasswordInput.text
                                          andDo:^(NSError *error, id resultObject) {
            if (error) {
                if ([error code] == 403) {
                    //TODO: Show error in text field
                } else if ([error code] == -1009) {
                    //TODO: show alert msg to connect to internet
                } else {
                    //TODO: show alert msg with unknown error and log to console.
                }
                NSLog(@"%@", error);

            } else {
                [self loginFacebook];
            }
        }];
    } else {
        [self loginFacebook];
    }
}

- (void)loginFacebook {
    if ([self.facebookEmailInput.text isNotEmpty]) {
        [_facebookContactsService loginByUserName:self.facebookEmailInput.text
                                       password:self.facebookPasswordInput.text
                                          andDo:^(NSError *error, id resultObject) {
            if (error) {
                //TODO: Show error in text field
                NSLog(@"%@", error);
            } else {
                [self prepareForMovingToContactImportView];
            }
        }];
    } else {
        [self prepareForMovingToContactImportView];
    }
}

- (void) prepareForMovingToContactImportView {
    NSLog(@"All OK!");
    [self saveCredentials];
    [self performSegueWithIdentifier:@"importContacts" sender:self];
}

- (void)saveCredentials {
    //TODO
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [(CustomUITextField *) textField shouldReturn];
}

@end
