//
//  BlockedTableViewController.m
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/24/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "BlockedTableViewController.h"
#import "User.h"
#import "BlockedTableViewCell.h"
#import "BlockedTableViewCell.h"
#import "ParseAPI.h"
#import <UIKit/UIKit.h>
#import "BlockedUserViewController.h"

@interface BlockedTableViewController ()
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *current;
@end

@implementation BlockedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)saveAllChangedCells {
    for (int section = 0; section < [self.tableView numberOfSections]; section++) {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            BlockedTableViewCell* cell = (BlockedTableViewCell *)([self.tableView cellForRowAtIndexPath:cellPath]);
            if (![cell.blockedSwitch isOn]) {
                // this person was unblocked!
                [ParseAPI getUser:cell.parseId withBlock:^(User *blockedFriend) {
                    [self.user unblockUser:blockedFriend];
                    [self.user saveInBackground];
                    [blockedFriend saveInBackground];
                }];
            }
        }
    }
}

- (void)disableAllToggles {
    for (int section = 0; section < [self.tableView numberOfSections]; section++) {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            BlockedTableViewCell* cell = (BlockedTableViewCell *)([self.tableView cellForRowAtIndexPath:cellPath]);
            cell.blockedSwitch.enabled = NO;
            [cell setNeedsDisplay];
        }
    }
}

- (void)enableAllToggles {
    for (int section = 0; section < [self.tableView numberOfSections]; section++) {
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            BlockedTableViewCell* cell = (BlockedTableViewCell *)([self.tableView cellForRowAtIndexPath:cellPath]);
            cell.blockedSwitch.enabled = YES;
            [cell setNeedsDisplay];
        }
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger num = self.user.blocked.count;
    self.count = [NSNumber numberWithInteger:num];
    self.current = [NSNumber numberWithInt:0];
    return num;
}

- (instancetype)initWithUser:(User *)me {
    self = [super init];
    if (self) {
        UINib *blockedCellNib = [UINib nibWithNibName:@"BlockedTableViewCell" bundle:nil];
        [self.tableView registerNib:blockedCellNib forCellReuseIdentifier:@"BlockedTableViewCell"];
        self.user = me;
    }
    return self;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BlockedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BlockedTableViewCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[BlockedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BlockedTableViewCell"];
    }
    cell.parseId = self.user.blocked[indexPath.row];
    [ParseAPI getUser:cell.parseId withBlock:^(User *friend) {
        cell.profilePicture.profileID = friend.FBID;
        cell.userName.text = friend.name;
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.size.width / 2;
        cell.profilePicture.layer.borderWidth = 1.0;
        cell.profilePicture.layer.borderColor = [UIColor redColor].CGColor;
        cell.profilePicture.clipsToBounds = YES;
        [cell setNeedsDisplay];
        self.current = [NSNumber numberWithInt:[self.current intValue]+1];
        if ([self.current isEqualToNumber:self.count]) {
            self.buvc.spinner.hidden = YES;
            [self.buvc.spinner stopAnimating];
        }
    }];
    // Configure the cell...
    
    return cell;
}


@end
