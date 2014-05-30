//
// Created by Arefeen on 5/30/14.
// Copyright (c) 2014 Therap (BD) Ltd. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "Objection.h"
#import "FacebookContactsService.h"
#import "NSString+NSStringExtension.h"

#define Semaphore int


@implementation FacebookContactsService {
    void (^onResultBlock)(NSError *, id);

    /**
    * Typical entry in this dictionary:
    * "{id}" => dict{
    *       "firstName" => "value of type NSString*",
    *       "lastName" => "value of type NSString*"
    *       "photo" => "value of type NSData"
    * }
    */
    NSMutableDictionary *friends;
    Semaphore noOfActionsToBeCompleted;
}

objection_register_singleton(FacebookContactsService)

- (void)loginAndDo:(void (^)(NSError *, id))onResult {
    onResultBlock = onResult;

    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
    } else {    // If the session state is not any of the two "open" states when the button is clicked
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"user_friends"]
                                           allowLoginUI:YES
                                      completionHandler:
                                              ^(FBSession *session, FBSessionState state, NSError *error) {
            // Retrieve the app delegate
            //AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
            [self facebookSessionStateChanged:session state:state error:error];
        }];
    }
}

- (void)fetchContactsAndDo:(void (^)(NSError *, id))onResult {
    onResultBlock = onResult;

    friends = [[NSMutableDictionary alloc] init];

    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            [FBRequestConnection startWithGraphPath:@"/me/friends"
                                         parameters:nil
                                         HTTPMethod:@"GET"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    [self onError:error];
                } else {
                    NSArray *friendList = [((FBGraphObject *) result) valueForKey:@"data"];
                    noOfActionsToBeCompleted = [friendList count] * 2;  //One for fetching details, another for fetching photo
                    for (FBGraphObject *friend in friendList) {
                        NSString *friendId = [friend valueForKey:@"id"];
                        [friends setValue:[[NSMutableDictionary alloc] init] forKey:friendId];
                        [self fetchFriendDetails:friendId];
                        [self fetchFriendPhoto:friendId];
                    }
                }
            }];
        }
    }];
}

- (void)fetchFriendDetails:(NSString *)friendId {
    [FBRequestConnection startWithGraphPath:concat(@"/", friendId)
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            FBGraphObject *fbGraphObject = (FBGraphObject *) result;
            NSMutableDictionary *friend = [friends valueForKey:[fbGraphObject valueForKey:@"id"]];
            [friend setValue:[fbGraphObject valueForKey:@"first_name"] forKey:@"firstName"];
            [friend setValue:[fbGraphObject valueForKey:@"last_name"] forKey:@"lastName"];
        }

        noOfActionsToBeCompleted--;

        if (noOfActionsToBeCompleted == 0) {
            onResultBlock(nil, friends);
        }
    }];
}

- (void)fetchFriendPhoto:(NSString *)friendId {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
            @"false", @"redirect",
            @"50", @"height",
            @"50", @"width",
            @"square", @"type",
            nil
    ];

    void(^completionHandler)(FBRequestConnection *, id, NSError*)
            = ^(FBRequestConnection *connection, id result, NSError *error) {
                NSMutableDictionary *friend = [friends valueForKey:friendId];

                if (!error) {
                    FBGraphObject *fbGraphObject = [(FBGraphObject *) result valueForKey:@"data"];
                    NSString *friendImageUrl = [fbGraphObject valueForKey:@"url"];
                    UIImage *photo = [self fetchImageAtUrl:friendImageUrl];
                    [friend setValue:UIImagePNGRepresentation(photo) forKey:@"photo"];
                } else {
                    [friend setValue:nil forKey:@"photo"];
                }

                noOfActionsToBeCompleted--;

                if (noOfActionsToBeCompleted == 0) {
                    onResultBlock(nil, friends);
                }
            };

    [FBRequestConnection startWithGraphPath:concat(@"/", friendId, @"/picture")
                                 parameters:params
                                 HTTPMethod:@"GET"
                          completionHandler:completionHandler];
}

- (UIImage *)fetchImageAtUrl:(NSString *)url {
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
}

- (void)facebookSessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen) {
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
//        [self userLoggedOut];
    }

    // Handle errors
    if (error) {
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error]) {
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
//            [self showMessage:alertText withTitle:alertTitle];
        } else {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");

                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
//                [self showMessage:alertText withTitle:alertTitle];

                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];

                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
//                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
//        [self userLoggedOut];
        [self onError:error];
    }
}

- (void)userLoggedIn {
    onResultBlock(nil, nil);
}

- (void)onError:(NSError *)error {
    onResultBlock(error, nil);
}

@end
