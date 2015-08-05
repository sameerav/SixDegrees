//
//  MapInfoWindowViewController.h
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/6/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface MapInfoWindowViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *mutualFriendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *mutualInterestLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

// TEST CODE, DELETE LATER
@property BOOL testing;

- (instancetype) initWithArray:(NSMutableArray *)array;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) User *friend;
@end
