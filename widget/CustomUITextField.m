//
// Created by Sharafat Ibn Mollah Mosharraf on 5/22/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "CustomUITextField.h"

const CGFloat IMAGE_PADDING = 7.0f;

@implementation CustomUITextField

- (void)setLeftInsetIcon:(UIImage *)icon {
    _leftInsetIcon = icon;
    self.leftViewMode = UITextFieldViewModeAlways;
    self.leftView = [[UIImageView alloc] initWithImage:icon];;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect textRect = [super leftViewRectForBounds:bounds];

    if (_leftInsetIcon == nil) {
        return textRect;
    }

    textRect.origin.x += IMAGE_PADDING;

    return textRect;
}

- (void)setRightInsetIcon:(UIImage *)icon {
    _rightInsetIcon = icon;
    self.rightViewMode = UITextFieldViewModeAlways;
    self.rightView = [[UIImageView alloc] initWithImage:icon];;
}

- (CGRect)rightRectForBounds:(CGRect)bounds {
    CGRect textRect = [super rightViewRectForBounds:bounds];

    if (_rightInsetIcon == nil) {
        return textRect;
    }

    textRect.origin.x -= IMAGE_PADDING;

    return textRect;
}

- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL withinMaxLength = YES;
    if (_maxLength > 0) {
        withinMaxLength = [self rangeWithinMaxLength:range replacementString:string];
    }

    BOOL inputCharactersFine = YES;
    if (_allowedChars != nil && _allowedChars.length > 0) {
        inputCharactersFine = [self InputCharactersAreFine:string];
    }

    return withinMaxLength && inputCharactersFine;
}

- (BOOL)rangeWithinMaxLength:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [self.text length] + [string length] - range.length;
    BOOL returnKeyFound = [string rangeOfString:@"\n"].location != NSNotFound;

    return newLength <= _maxLength || returnKeyFound;
}

- (BOOL)InputCharactersAreFine:(NSString *)string {
    NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:_allowedChars] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];

    return [string isEqualToString:filtered];
}

- (BOOL)shouldReturn {
    BOOL didResign = [self resignFirstResponder];
    if (!didResign) {
        return NO;
    }

    dispatch_async(dispatch_get_main_queue(), //It originally was dispatch_get_current_queue()
            ^{
                [_nextField becomeFirstResponder];
            });

    return YES;
}

@end
