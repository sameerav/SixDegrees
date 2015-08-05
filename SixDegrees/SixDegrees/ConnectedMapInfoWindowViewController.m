//
//  ConnectedMapInfoWindowViewController.m
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/28/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "ConnectedMapInfoWindowViewController.h"
#import "User.h"

@interface ConnectedMapInfoWindowViewController ()
@property (strong, nonatomic) User *friend;
@end

@implementation ConnectedMapInfoWindowViewController
- (instancetype)initWithFriend:(User *)friend {
    self = [super init];
    if (self) {
        self.friend = friend;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2;
    self.profilePic.layer.borderWidth = 1.0;
    self.profilePic.layer.borderColor = [[UIColor alloc] initWithRed:241.0/255.0 green:98.0/255.0 blue:109.0/255.0 alpha:1].CGColor;
    self.profilePic.clipsToBounds = YES;
    self.userName.text = [self.friend.name componentsSeparatedByString:@" "][0];
}
@end
