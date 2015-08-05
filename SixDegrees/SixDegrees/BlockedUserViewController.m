//
//  BlockedUserViewController.m
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/24/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "BlockedUserViewController.h"
#import "BlockedTableViewController.h"
#import "User.h"

@interface BlockedUserViewController ()
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) BlockedTableViewController *btvc;
@end

@implementation BlockedUserViewController

- (IBAction)doneButtonClicked:(id)sender {
    [self saveAllUnblocking];
    [self.view setNeedsDisplay];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveAllUnblocking {
    [self.btvc saveAllChangedCells];
}

- (void)viewDidLoad {
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
}

- (instancetype)initWithUser:(User *)me {
    self = [super init];
    if (self) {
        self.user = me;
        [me refreshInBackgroundWithBlock:^(PFObject *refreshedObject, NSError *refreshedError) {
            User *refreshedUser = (User *)refreshedObject;
            self.user = refreshedUser;
            self.btvc = [[BlockedTableViewController alloc] initWithUser:me];
            self.btvc.buvc = self;
            self.btvc.tableView.allowsSelection = NO;
            CGFloat tableViewHeight = self.view.frame.size.height-114.0;
            self.btvc.tableView.frame = CGRectMake(0, 70,  self.view.frame.size.width, tableViewHeight);
            [self.view addSubview:self.btvc.tableView];
        }];
    }
    return self;
}

@end
