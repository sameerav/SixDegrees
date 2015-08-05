//
//  ConversationsViewController.m
//  SixDegrees
//
//  Created by Daniel Moreno on 7/8/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "ConversationsViewController.h"
#import "ConversationCell.h"
#import "UserConnection.h"
#import <QuartzCore/QuartzCore.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "MessengerButton.h"
#import "ConversationsTableViewController.h"
@import Foundation;

#import "ParseAPI.h"
#import "User.h"
#import "ParseAPI.h"


@interface ConversationsViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) User *user;
@end

@implementation ConversationsViewController


- (instancetype)initWithUser:(User *)user {
    self = [super init];
    if (self) {
        // instantiate conversationtableviewcontroller here
        self.user = user;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.layer.zPosition = MAXFLOAT;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    [self.view setNeedsDisplay];
    [self.view addGestureRecognizer:tap];
}

- (void)addUser:(User *)user {
    if (!self.user && user) {
        self.user = user;
        self.ctvc = [[ConversationsTableViewController alloc] initWithUser:user andCVC:self];
        CGFloat tableViewHeight = self.view.frame.size.height-114.0;
        self.ctvc.tableView.frame = CGRectMake(0, 114,  self.view.frame.size.width, tableViewHeight);
        self.searchBar.delegate = self.ctvc;

        [self.view insertSubview:self.ctvc.tableView belowSubview:self.spinner];
    }
    if (self.user) {
        self.spinner.hidden = YES;
        [self.spinner stopAnimating];
        [self.view setNeedsDisplay];
    }
}

- (void) dismissKeyboard
{
    // add self
    [self.searchBar resignFirstResponder];
}

@end
