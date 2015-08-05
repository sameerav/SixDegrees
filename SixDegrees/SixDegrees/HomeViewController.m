//
//  HomeViewController.m
//  SixDegrees
//
//  Created by Daniel Moreno on 7/8/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "HomeViewController.h"
#import "MapViewController.h"
#import "ConversationsViewController.h"
#import "ConversationsTableViewController.h"
#import "SixDegreesLoginViewController.h"
#import "SWRevealViewController.h"
#import "ParseAPI.h"
#import "User.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "GraphRequestAPI.h"
#import "LoginHelper.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    // Do any additional setup after loading the view from its nib.
    self.menuIsOpen = NO;
    //initialize view controllers
    MapViewController *mvc = [[MapViewController alloc] init];
    ConversationsViewController *cvc = [[ConversationsViewController alloc] initWithUser:nil];
    self.mvc = mvc;
    self.cvc = cvc;
    self.viewControllers = @[self.mvc, self.cvc];
    //tested only on iPhone 6, probably looks bad on other platforms
    
    //configure tab Bar
    UITabBar *tabBar = self.tabBar;
    self.delegate = self;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UIColor *salmon =[UIColor colorWithRed:241.0/255.0 green:98.0/255.0 blue:109.0/255.0 alpha:1.0];
    [[UITabBar appearance] setBarTintColor:[UIColor viewFlipsideBackgroundColor]];
    [[UITabBar appearance] setTintColor:salmon];
    [[UITabBar appearance] setTranslucent:NO];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avenir Next" size:10.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    tabBarItem1.title = @"Map";
    tabBarItem2.title = @"Connections";
    tabBarItem1.image = [UIImage imageNamed:@"notif"];
    tabBarItem2.image = [UIImage imageNamed:@"mDSelected"];

    //configure menu button
    UIButton * menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton addTarget:self action:@selector(gotoMenu) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setImage:[UIImage imageNamed:@"menuS"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(25, 35, 25, 25);
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0);
    [self.spinner setColor:[[UIColor alloc] initWithRed:241.0/255.0 green:98.0/255.0 blue:109.0/255.0 alpha:1.0]];
    self.mvc.hvc = self;
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
    
    [self.view addSubview:menuButton];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    ConversationsViewController *passedIn = (ConversationsViewController *)viewController;
    if (passedIn == self.cvc) {
        self.spinner.hidden = YES;
        [self.spinner stopAnimating];
        [self.view setNeedsDisplay];
        [self.cvc addUser:self.currentUser];
        [self.cvc.ctvc.tableView reloadData];
        [self.cvc.ctvc.view setNeedsDisplay];
        [self.cvc.view setNeedsDisplay];
    } else {
        ((MapViewController *)viewController).hvc = self;
    }
    return YES;
}



- (void)viewDidAppear:(BOOL)animated{
    //checks existing FB login, initializes login flow
    if (!self.currentUser) {
        [LoginHelper loginAfterAutoLoginWithView:self];
    }
    
    
}

- (void) gotoMenu {
    // TODO: show View Deck with View Controller names
    [self.revealViewController revealToggle:self];
    if(self.menuIsOpen){
        self.mvc.view.userInteractionEnabled = YES;
        self.mvc.mapView.userInteractionEnabled = YES;
        self.menuIsOpen = NO;
    }else {
        self.mvc.view.userInteractionEnabled = NO;
        self.mvc.mapView.userInteractionEnabled = NO;
        self.menuIsOpen = YES;
    }
}




@end
