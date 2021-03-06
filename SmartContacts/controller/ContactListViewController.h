//
//  ContactListViewController.h
//  SmartContacts
//
//  Created by Sharafat Ibn Mollah Mosharraf on 5/30/14.
//  Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface ContactListViewController : UITableViewController
        <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate,
        MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
