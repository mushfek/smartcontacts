//
// Created by Sharafat Ibn Mollah Mosharraf on 5/22/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CustomUITextField : UITextField

/**
* nextField is for setting which field to focus on Next button press.
* http://stackoverflow.com/questions/1347779/how-to-navigate-through-textfields-next-done-buttons#answer-5889795
*/
@property (nonatomic, readwrite, assign) IBOutlet UITextField *nextField;
@property (nonatomic, weak) UIImage *leftInsetIcon;
@property (nonatomic, weak) UIImage *rightInsetIcon;
@property (nonatomic) int maxLength;
@property (nonatomic, copy) NSString *allowedChars;

/**
* - Check input characters
* - Limit no. of characters
* http://stackoverflow.com/questions/2523501/set-uitextfield-maximum-length#answer-8913595
* http://stackoverflow.com/questions/9477563/how-to-enter-numbers-only-in-uitextfield-and-limit-maximum-length#answer-9489535
*/
- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

/**
* focus next field on Next button press.
* http://stackoverflow.com/questions/1347779/how-to-navigate-through-textfields-next-done-buttons#answer-5889795
*/
- (BOOL)shouldReturn;

@end
