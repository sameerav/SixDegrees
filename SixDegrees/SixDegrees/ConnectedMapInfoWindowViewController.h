//
//  ConnectedMapInfoWindowViewController.h
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/28/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface ConnectedMapInfoWindowViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *profilePic;
- (instancetype)initWithFriend:(User *)friend;
@end
