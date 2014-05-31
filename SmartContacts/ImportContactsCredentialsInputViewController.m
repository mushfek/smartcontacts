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
#import "CMPopTipView.h"
#import "NSString+FormInputValidation.h"
#import "ImportContactsViewController.h"
#import "MBProgressHUD.h"
#import "AddressBookContactsService.h"


@implementation ImportContactsCredentialsInputViewController {
    GoogleContactsService *_googleContactsService;
    FacebookContactsService *_facebookContactsService;
    MBProgressHUD *_mbProgressHUD;
    AddressBookContactsService *_addressBookContactsService;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    _googleContactsService = objection_inject(GoogleContactsService)
    _facebookContactsService = objection_inject(FacebookContactsService)
    _addressBookContactsService = objection_inject(AddressBookContactsService)
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
            initWithTitle:@"Skipping Contact Import!"
                  message:@"Are you sure you want to skip?"
                 delegate:self
        cancelButtonTitle:nil
        otherButtonTitles:@"Skip Contact Import", nil]
            show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self performSegueWithIdentifier:@"skipToContactList" sender:self];
}

- (IBAction)importContacts:(id)sender {
    if ([self validateForm]) {
        _mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        if ([self.googlePlusEmailInput.text isNotEmpty]) {
            [self loginGooglePlus];
        } else {
            [self loginFacebook];
        }
    }
}

- (BOOL)validateForm {
    [self clearValidationsFromTextFields];

    if (![self.importFacebookFriendsSwitch isOn]
            && ![self.googlePlusEmailInput.text isNotEmpty] && ![self.googlePlusPasswordInput.text isNotEmpty]) {
        self.googlePlusEmailInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];
        self.googlePlusPasswordInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];

        [[[UIAlertView alloc]
                initWithTitle:@"Nothing to Import!"
                      message:@"To import contacts, do at least any of the following:\n- Provide Google+ credentials\n- Turn on Import Facebook Contacts"
                     delegate:nil
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil]
                show];

        return FALSE;
    }

    CustomUITextField *firstTextFieldToShowErrorPopup;

    if ([self.googlePlusEmailInput.text isNotEmpty] && ![self.googlePlusEmailInput.text isValidEmailAddressString]) {
        self.googlePlusEmailInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];
        self.googlePlusEmailInput.popTipView = [self createPopTipViewWithMessage:@"Invalid Email ID"];
        self.googlePlusEmailInput.controllerUiView = self.view;

        firstTextFieldToShowErrorPopup = self.googlePlusEmailInput;
    }

    if ([self.googlePlusEmailInput.text isNotEmpty] && ![self.googlePlusPasswordInput.text isNotEmpty]) {
        self.googlePlusPasswordInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];
        self.googlePlusPasswordInput.popTipView = [self createPopTipViewWithMessage:@"Password is required"];
        self.googlePlusPasswordInput.controllerUiView = self.view;

        if (firstTextFieldToShowErrorPopup == nil) {
            firstTextFieldToShowErrorPopup = self.googlePlusPasswordInput;
        }
    } else if (![self.googlePlusEmailInput.text isNotEmpty] && [self.googlePlusPasswordInput.text isNotEmpty]
            && firstTextFieldToShowErrorPopup != self.googlePlusEmailInput) {
        self.googlePlusEmailInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];
        self.googlePlusEmailInput.popTipView = [self createPopTipViewWithMessage:@"Email ID is required"];
        self.googlePlusEmailInput.controllerUiView = self.view;

        if (firstTextFieldToShowErrorPopup == nil) {
            firstTextFieldToShowErrorPopup = self.googlePlusEmailInput;
        }
    }

    if (firstTextFieldToShowErrorPopup != nil) {
        [firstTextFieldToShowErrorPopup showPopTipView];

        return FALSE;
    }

    return TRUE;
}

- (void)clearValidationsFromTextFields {
    [self.googlePlusEmailInput clearValidation];
    [self.googlePlusPasswordInput clearValidation];
}

- (void)loginGooglePlus {
    _mbProgressHUD.labelText = @"Authenticating Google Plus Account...";
    [_googleContactsService loginByUserName:self.googlePlusEmailInput.text
                                   password:self.googlePlusPasswordInput.text
                                      andDo:^(NSError *error, id resultObject) {
        if (error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([error code] == 403) {
                self.googlePlusPasswordInput.text = @"";
                self.googlePlusEmailInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];
                self.googlePlusEmailInput.popTipView = [self createPopTipViewWithMessage:@"Incorrect Email/Password"];
                self.googlePlusEmailInput.controllerUiView = self.view;
                [self.googlePlusEmailInput showPopTipView];
            } else if ([error code] == -1009) {
                //TODO: show alert msg to connect to internet
            } else {
                [[[UIAlertView alloc]
                        initWithTitle:@"Unexpected Error"
                              message:@"An error occurred while loggin in to Google Plus."
                             delegate:self
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil]
                        show];
            }
        } else {
            [self loginFacebook];
        }
    }];
}

- (void)loginFacebook {
    if ([self.importFacebookFriendsSwitch isOn]) {
        _mbProgressHUD.labelText = @"Authenticating Facebook Account...";
        [_facebookContactsService loginAndDo:^(NSError *error, id resultObject) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error) {
                NSLog(@"%@", error);
                [[[UIAlertView alloc]
                        initWithTitle:@"Unexpected Error"
                              message:@"Failed authenticating with Facebook."
                             delegate:self
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil]
                        show];
            } else {
                [self prepareForMovingToContactImportView];
            }
        }];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self prepareForMovingToContactImportView];
    }
}

- (void)prepareForMovingToContactImportView {
    NSLog(@"All OK!");
    [self saveCredentials];
    [self performSegueWithIdentifier:@"importContacts" sender:self];
}

- (void)saveCredentials {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"Credentials.plist"]];

    NSMutableDictionary *plistDict;
    if ([fileManager fileExistsAtPath:path]) {
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    } else {
        NSError *error = nil;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Credentials" ofType:@"plist"];
        [fileManager copyItemAtPath:filePath toPath:path error:&error];
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    }

    NSLog(@"Google Plus Email ID %@", [plistDict valueForKey:@"googlePlusEmailId"]);
    [plistDict setObject:self.googlePlusEmailInput.text forKey:@"googlePlusEmailId"];
    [plistDict setObject:self.googlePlusPasswordInput.text forKey:@"googlePlusPassword"];

    [plistDict writeToFile:path atomically:YES];
}

- (CMPopTipView *)createPopTipViewWithMessage:(NSString *)message {
    CMPopTipView *popTipView = [[CMPopTipView alloc] initWithMessage:message];
    popTipView.textColor = [UIColor colorWithRed:(CGFloat) (169 / 255.0)
                                           green:(CGFloat) (68 / 255.0)
                                            blue:(CGFloat) (66 / 255.0)
                                           alpha:1];
    popTipView.borderColor = popTipView.textColor;
    popTipView.backgroundColor = [UIColor colorWithRed:(CGFloat) (242 / 255.0)
                                                 green:(CGFloat) (222 / 255.0)
                                                  blue:(CGFloat) (222 / 255.0)
                                                 alpha:1];
    popTipView.hasGradientBackground = NO;

    return popTipView;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"importContacts"]) {
        ImportContactsViewController *viewController = (ImportContactsViewController *) [segue destinationViewController];
        [viewController setGooglePlusEmailId:self.googlePlusEmailInput.text
                                 andPassword:self.googlePlusPasswordInput.text
        andIfFacebookFriendsShouldBeImported:[self.importFacebookFriendsSwitch isOn]];
    }
}


#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [(CustomUITextField *) textField shouldReturn];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [(CustomUITextField *) textField showPopTipView];

    return YES;
}


@end
