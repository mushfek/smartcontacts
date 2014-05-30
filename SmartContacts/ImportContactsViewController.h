//
// Created by Sharafat Ibn Mollah Mosharraf on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImportContactsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *importingContactsLabel1;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingImage1;
@property (weak, nonatomic) IBOutlet UILabel *importingContactsLabel2;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingImage2;
@property (weak, nonatomic) IBOutlet UILabel *importingContactsLabel3;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingImage3;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage1;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage2;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage3;

- (void)setGooglePlusEmailId:(NSString *)email andPassword:(NSString *)password
        andIfFacebookFriendsShouldBeImported:(BOOL)importFacebookFriends;

@end
