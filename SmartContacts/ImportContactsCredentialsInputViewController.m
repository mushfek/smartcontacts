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
    if (![self validateForm]) {
        [self loginGooglePlus];
    }
}

- (BOOL)validateForm {
    BOOL errorOccurred = false;
    [self clearRightIconsOfTextFields];

    if (![_facebookEmailInput.text isNotEmpty] && ![_facebookPasswordInput.text isNotEmpty]
            && ![_googlePlusEmailInput.text isNotEmpty] && ![_googlePlusPasswordInput.text isNotEmpty]) {
        self.facebookEmailInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];
        self.facebookPasswordInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];
        self.googlePlusEmailInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];
        self.googlePlusPasswordInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];

        [self addPopTipViewForTextField:_facebookEmailInput withMessage:@"Enter your email id"];

        return true;
    } else {
        if ([_facebookEmailInput.text isNotEmpty] && ![_facebookEmailInput.text isValidEmailAddressString]) {
            self.facebookEmailInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];

            [self addPopTipViewForTextField:_facebookEmailInput
                                withMessage:@"Invalid email id"];
            errorOccurred = true;
        } else if ([_facebookEmailInput.text isNotEmpty] && ![_facebookPasswordInput.text isNotEmpty]) {
            self.facebookPasswordInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];

            [self addPopTipViewForTextField:_facebookPasswordInput withMessage:@"Enter your password"];
            errorOccurred = true;
        } else if (![_facebookEmailInput.text isNotEmpty] && [_facebookPasswordInput.text isNotEmpty]) {
            self.facebookEmailInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];

            [self addPopTipViewForTextField:_facebookEmailInput withMessage:@"Enter your email id"];
            errorOccurred = true;
        }

        if ([_googlePlusEmailInput.text isNotEmpty] && ![_googlePlusEmailInput.text isValidEmailAddressString]) {
            self.googlePlusEmailInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];

            if (!errorOccurred) {
                [self addPopTipViewForTextField:_googlePlusEmailInput
                                    withMessage:@"Invalid email id"];
            }

            errorOccurred = true;
        } else if ([_googlePlusEmailInput.text isNotEmpty] && ![_googlePlusPasswordInput.text isNotEmpty]) {
            self.googlePlusPasswordInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];

            if (!errorOccurred) {
                [self addPopTipViewForTextField:_googlePlusPasswordInput
                                    withMessage:@"Enter your password"];
            }

            errorOccurred = true;
        } else if (![_googlePlusEmailInput.text isNotEmpty] && [_googlePlusPasswordInput.text isNotEmpty]) {
            self.googlePlusEmailInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];

            if (!errorOccurred) {
                [self addPopTipViewForTextField:_googlePlusEmailInput
                                    withMessage:@"Enter your email id"];
            }

            errorOccurred = true;
        }
    }
    return errorOccurred;
}

- (void)clearRightIconsOfTextFields {
    self.facebookEmailInput.rightInsetIcon = nil;
    self.facebookPasswordInput.rightInsetIcon = nil;
    self.googlePlusEmailInput.rightInsetIcon = nil;
    self.googlePlusPasswordInput.rightInsetIcon = nil;
}

- (void)loginGooglePlus {
    if ([self.googlePlusEmailInput.text isNotEmpty]) {
        [_googleContactsService loginByUserName:self.googlePlusEmailInput.text
                                       password:self.googlePlusPasswordInput.text
                                          andDo:^(NSError *error, id resultObject) {
            if (error) {
                [self clearRightIconsOfTextFields];
                if ([error code] == 403) {
                    self.googlePlusPasswordInput.text = @"";
                    self.googlePlusEmailInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];
                    [self addPopTipViewForTextField:_googlePlusEmailInput
                                        withMessage:@"Enter proper email id & password"];
                } else if ([error code] == -1009) {
                    //TODO: show alert msg to connect to internet
                } else {
                    //TODO: show alert msg with unknown error and log to console.
                    self.googlePlusPasswordInput.text = @"";
                    self.googlePlusEmailInput.rightInsetIcon = [UIImage imageNamed:@"Failure"];
                    [self addPopTipViewForTextField:_googlePlusEmailInput
                                        withMessage:@"Enter occurred"];

                    NSLog(@"Unknow error occurred");
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

- (void)addPopTipViewForTextField:(UITextField *)textField withMessage:(NSString *)message {
    CMPopTipView *popTipView;

    popTipView = [[CMPopTipView alloc] initWithMessage:message];
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

    [popTipView presentPointingAtView:textField inView:self.view animated:YES];
}

- (void)prepareForMovingToContactImportView {
    NSLog(@"All OK!");
    [self saveCredentials];
    [self performSegueWithIdentifier:@"importContacts" sender:self];
}

- (void)saveCredentials {
    BOOL doesExist;
    NSError *error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Credentials" ofType:@"plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [[NSString alloc] initWithString:[documentsDirectory
            stringByAppendingPathComponent:@"Credentials.plist"]];

    doesExist = [fileManager fileExistsAtPath:path];
    NSMutableDictionary *plistDict;
    if (doesExist) {
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    } else {
        [fileManager copyItemAtPath:filePath toPath:path error:&error];
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    }

    NSLog(@"Google Plus Email ID %@", [plistDict valueForKey:@"googlePlusEmailId"]);
    [plistDict setObject:self.googlePlusEmailInput.text forKey:@"googlePlusEmailId"];
    [plistDict setObject:self.googlePlusPasswordInput.text forKey:@"googlePlusPassword"];

    [plistDict writeToFile:path atomically:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"importContacts"]) {
        ImportContactsViewController *viewController
                = (ImportContactsViewController *) [segue destinationViewController];
        [viewController setGooglePlusEmailId:self.googlePlusEmailInput.text andPassword:self.googlePlusPasswordInput.text];
    }
}


#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [(CustomUITextField *) textField shouldReturn];
}

@end
