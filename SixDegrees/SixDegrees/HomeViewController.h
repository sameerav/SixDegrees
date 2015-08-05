//
//  HomeViewController.h
//  SixDegrees
//
//  Created by Daniel Moreno on 7/8/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
@class CLLocation;
@class MapViewController;
@class ConversationsViewController;
@class User;

@interface HomeViewController : UITabBarController<UITabBarControllerDelegate ,SWRevealViewControllerDelegate>
@property (strong, nonatomic) MapViewController *mvc;
@property (strong, nonatomic) ConversationsViewController *cvc;
@property (strong, nonatomic) User* currentUser;
@property (nonatomic) BOOL menuIsOpen;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end
