//
//  SettingsViewController.h
//  SixDegrees
//
//  Created by Daniel Moreno on 7/9/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@class User;

@interface SettingsViewController : UIViewController 
@property (strong, nonatomic) User *currentUser;
@end
