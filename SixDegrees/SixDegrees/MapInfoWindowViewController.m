//
//  MapInfoWindowViewController.m
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/6/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "MapInfoWindowViewController.h"

@interface MapInfoWindowViewController ()
@property (strong, nonatomic) NSArray *array;
@end

@implementation MapInfoWindowViewController

- (instancetype) initWithArray:(NSMutableArray *)array {
    self = [super init];
    if (self) {
        self.array = array;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mutualFriendsLabel.text = self.array[0];
    self.mutualInterestLabel.text = self.array[1];
    self.distanceLabel.text = self.array[2];
}

@end
