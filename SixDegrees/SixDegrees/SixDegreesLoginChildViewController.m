//
//  SixDegreesLoginChildViewController.m
//  SixDegrees
//
//  Created by Daniel Moreno on 7/7/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "SixDegreesLoginChildViewController.h"

@interface SixDegreesLoginChildViewController ()
@property (weak, nonatomic) IBOutlet UILabel *bigLabel;
@property (weak, nonatomic) IBOutlet UILabel *littleLabel;

@end

@implementation SixDegreesLoginChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Load text labels for tutorial
    
    if (self.index == 0) {
        self.bigLabel.text = @"What?";
        self.littleLabel.text = @"SixDegrees connects you with new people near you that you should already know.";
    } else if (self.index == 1) {
        self.bigLabel.text = @"How?";
        self.littleLabel.text = @"We expand your network through your mutual connections and interests";
    } else if (self.index == 2) {
        self.bigLabel.text = @"Why?";
        self.littleLabel.text = @"We believe in a more connected world, no matter where you are";
    } else if (self.index == 3) {
        self.bigLabel.text = @"Get Started";
        self.littleLabel.text = @"Log in with Facebook below, and start meeting new people";
    }
    
}

@end
