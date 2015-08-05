//
//  AboutUsViewController.m
//  SixDegrees
//
//  Created by Daniel Moreno on 7/20/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "AboutUsViewController.h"
#import "SWRevealViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AboutUsViewController ()
@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *amanda;
@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *sameera;
@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *daniel;
@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *joe;

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.amanda.profileID =@"863624613649419";
    self.sameera.profileID =@"100001854015133";
    self.daniel.profileID =@"650136256";
    self.joe.profileID =@"1466661881";
    
    self.amanda.layer.cornerRadius = self.amanda.frame.size.width / 2;
    self.amanda.layer.borderWidth = 1.0;
    self.amanda.layer.borderColor = [UIColor whiteColor].CGColor;
    self.amanda.clipsToBounds = YES;

    self.sameera.layer.cornerRadius = self.sameera.frame.size.width / 2;
    self.sameera.layer.borderWidth = 1.0;
    self.sameera.layer.borderColor = [UIColor whiteColor].CGColor;
    self.sameera.clipsToBounds = YES;

    self.daniel.layer.cornerRadius = self.daniel.frame.size.width / 2;
    self.daniel.layer.borderWidth = 1.0;
    self.daniel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.daniel.clipsToBounds = YES;
    
    
    
    self.joe.layer.cornerRadius = self.joe.frame.size.width / 2;
    self.joe.layer.borderWidth = 1.0;
    self.joe.layer.borderColor = [UIColor whiteColor].CGColor;
    self.joe.clipsToBounds = YES;

}

- (IBAction)menuTapped:(id)sender {
    if (self.revealViewController){
        [self.revealViewController revealToggle:self];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

}

@end
