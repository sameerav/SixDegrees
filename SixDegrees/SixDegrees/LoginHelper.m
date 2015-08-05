//
//  LoginHelper.m
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/22/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "LoginHelper.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ParseAPI.h"
#import "User.h"
#import "WebViewController.h"
#import "SixDegreesLoginViewController.h"
#import "HomeViewController.h"
#import "ConversationsViewController.h"
#import "MapViewController.h"
#import "GraphRequestAPI.h"
#import "BirthdayViewController.h"

@implementation LoginHelper
+ (void)loginAfterManualFacebookLoginWithLocation:(PFGeoPoint *)location andView:(SixDegreesLoginViewController *)viewController{
    NSDictionary *params = @{@"fields":@"friends"};
    FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:params];
    FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
    
    [connection addRequest:requestMe completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        [ParseAPI getUserFromFBID:result[@"id"] withBlock:^(User *me) {
            void (^afterUserSaveBlock)(User *me) = ^void(User *me) {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:me.objectId];
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"userID"];
                [ParseAPI updateOrCreateUser:me withBlock:^(User *currentUser) {
                    
                    if (!currentUser.birthday) {
                        BirthdayViewController *bvc = [[BirthdayViewController alloc] initWithUser:currentUser];
                        [viewController presentViewController:bvc animated:YES completion:nil];
                    } else {
                        [viewController dismissViewControllerAnimated:YES completion:nil];
                    }
                    
                    [self subscribeToOwnChannel:currentUser];
                    [me saveInBackground];
                }];
            };
            
            if (me == nil) {
                me = [[User alloc] initWithFBID:result[@"id"] andLocation:location];
                WebViewController *wvc = [[WebViewController alloc] initWithUser:me];
                wvc.block = afterUserSaveBlock;
                [viewController presentViewController:wvc animated:YES completion:nil];
            } else {
                afterUserSaveBlock(me);
            }
            
        }];
    }];
    
    [connection start];
}

+ (void)loginAfterAutoLoginWithView:(HomeViewController *)viewController {
    if(![FBSDKAccessToken currentAccessToken]){
        SixDegreesLoginViewController *lvc = [[SixDegreesLoginViewController alloc] init];
        lvc.hvc = viewController;
        viewController.modalPresentationStyle = UIModalPresentationPageSheet;
        [viewController presentViewController:lvc animated:YES completion:nil];
    } else {
        // handle self
        [ParseAPI doBlockForCurrentUser:^(User *me) {
            if (me != nil) {
                [self subscribeToOwnChannel:me];
                viewController.currentUser = me;
                [viewController.cvc addUser:me];
                [ParseAPI findTopFriendsInBackground:me.objectId withBlock:^void(NSArray *potentialFriendsArray){
                    for (User *friend in potentialFriendsArray) {
                        friend.locationManager = [[CLLocationManager alloc] init];
                        friend.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                        friend.locationManager.distanceFilter = 20;
                        friend.locationManager.delegate = viewController.mvc;
                        [friend.locationManager startUpdatingLocation];
                        [friend.locationManager requestAlwaysAuthorization];
                        [friend.locationManager startMonitoringSignificantLocationChanges];
                    }
                    
                    [GraphRequestAPI rankPotentialFriends:potentialFriendsArray currentUser:me withBlock:^(){
                        [viewController.mvc updateAllMarkers];
                    }];
                }];
            }
        }];
    }
}

+ (void)subscribeToOwnChannel:(User *)user {
    NSString *channelName = [@"C" stringByAppendingString:user.objectId];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:channelName forKey:@"channels"];
    [currentInstallation saveInBackground];
}

@end
