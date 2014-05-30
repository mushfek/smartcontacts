//
// Created by Sharafat Ibn Mollah Mosharraf on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "ImportContactsCredentialsInputViewController.h"
#import "CustomUITextField.h"


@implementation ImportContactsCredentialsInputViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [(CustomUITextField *) textField shouldReturn];
}

@end
