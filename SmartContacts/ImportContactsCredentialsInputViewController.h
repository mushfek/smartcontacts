//
// Created by Sharafat Ibn Mollah Mosharraf on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CustomUITextField;


@interface ImportContactsCredentialsInputViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet CustomUITextField *facebookEmailInput;
@property (weak, nonatomic) IBOutlet CustomUITextField *googlePlusEmailInput;
@property (weak, nonatomic) IBOutlet CustomUITextField *googlePlusPasswordInput;
@property (weak, nonatomic) IBOutlet CustomUITextField *facebookPasswordInput;

- (IBAction)importContacts:(id)sender;
- (IBAction)skipImportingContacts:(id)sender;

@end
