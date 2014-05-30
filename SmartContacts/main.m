//
//  main.m
//  SmartContacts
//
//  Created by Sharafat Ibn Mollah Mosharraf on 5/30/14.
//  Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "JSObjection.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [JSObjection setDefaultInjector:[JSObjection createInjector]];

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
