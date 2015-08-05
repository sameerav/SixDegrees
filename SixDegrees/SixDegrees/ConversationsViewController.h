//
//  ConversationsViewController.h
//  SixDegrees
//
//  Created by Daniel Moreno on 7/8/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ConversationsTableViewController;
@class User;


@interface ConversationsViewController : UIViewController
- (instancetype)initWithUser:(User *)user;
- (void)addUser:(User *)user;
@property (strong, nonatomic) ConversationsTableViewController *ctvc;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end
