//
//  ContactDetailsViewController.h
//  SmartContacts
//
//  Created by Sharafat Ibn Mollah Mosharraf on 5/30/14.
//  Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Contact;

@interface ContactDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *contactAddress;
@property (weak, nonatomic) IBOutlet UILabel *contactEmailAddress;
@property (weak, nonatomic) IBOutlet UILabel *contactName;
@property (weak, nonatomic) IBOutlet UIImageView *contactPhoto;
@property (weak, nonatomic) IBOutlet UILabel *contactPhone;

@property (weak, nonatomic) IBOutlet UILabel *contactOrganization;
@property (weak, nonatomic) IBOutlet UILabel *contactIms;
@property (weak, nonatomic) IBOutlet UILabel *contactSocialProfile;
@property (weak, nonatomic) IBOutlet UILabel *contactUrl;
@property (assign, nonatomic) Contact *detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
