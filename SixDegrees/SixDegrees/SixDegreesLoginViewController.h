//
//  SixDegreesLoginViewController.h
//  SixDegrees
//
//  Created by Daniel Moreno on 7/7/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@class HomeViewController;


@interface SixDegreesLoginViewController : UIViewController
    <FBSDKLoginButtonDelegate, UIPageViewControllerDataSource>
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *loginButton;
@property (strong, nonatomic) UIPageViewController *pageController;
@property (weak, nonatomic) HomeViewController *hvc;

+(NSString *)AppSecretProof:(NSString *)accessToken appSecret:(NSString *)appSecret;
@end
