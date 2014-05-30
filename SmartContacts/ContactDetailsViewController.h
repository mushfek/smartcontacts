//
//  ContactDetailsViewController.h
//  SmartContacts
//
//  Created by Sharafat Ibn Mollah Mosharraf on 5/30/14.
//  Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactDetailsViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
