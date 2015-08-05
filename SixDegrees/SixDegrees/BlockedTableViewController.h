//
//  BlockedTableViewController.h
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/24/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;
@class BlockedUserViewController;

@interface BlockedTableViewController : UITableViewController
- (instancetype)initWithUser:(User *)me;
- (void)saveAllChangedCells;
- (void)disableAllToggles;
- (void)enableAllToggles;
@property (weak, nonatomic) BlockedUserViewController *buvc;
@end
