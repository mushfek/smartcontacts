//
// Created by Arefeen on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import "NSString+FormInputValidation.h"


@implementation NSString (FormInputValidation)

-(BOOL)isValidEmailAddressString {
    NSString *regex = @"[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];

    return [emailPredicate evaluateWithObject:self];
}

@end