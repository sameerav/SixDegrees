//
//  ConnectedViewController.m
//  SixDegrees
//
//  Created by Daniel Moreno on 7/21/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "ConnectedViewController.h"

@interface ConnectedViewController ()
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *me;
@property (strong, nonatomic)  NSString *them;
@property (strong, nonatomic)  NSString *name;
@property (strong, nonatomic)  NSString *URL;
@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *theirPP;
@property (strong, nonatomic) IBOutlet UIButton *messenger;
@property (strong, nonatomic) IBOutlet UIView *vie;


@end

@implementation ConnectedViewController

-(instancetype) initWithOtherFBID:(NSString *)fbid andName:(NSString *) name andURL:(NSString *)url{
    self = [super init];
    self.them = fbid;
    self.name = name;
    self.URL = url;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.me.profileID = @"me";
    self.me.layer.cornerRadius = self.me.frame.size.width / 2;
    self.me.layer.borderWidth = 1.0;
    self.me.layer.borderColor = [UIColor whiteColor].CGColor;
    self.me.clipsToBounds = YES;
    
    self.theirPP.profileID = self.them;
    self.theirPP.layer.cornerRadius = self.me.frame.size.width / 2;
    self.theirPP.layer.borderWidth = 1.0;
    self.theirPP.layer.borderColor = [UIColor whiteColor].CGColor;
    self.theirPP.clipsToBounds = YES;
    
    self.vie.layer.cornerRadius = self.vie.frame.size.width / 2;
    self.vie.layer.borderWidth = 1.0;
    self.vie.layer.borderColor = [UIColor whiteColor].CGColor;
    self.vie.clipsToBounds = YES;

    self.label.text = [NSString stringWithFormat: @"You've just connected with %@. Send a message or click on their profile in the Conversations tab to find things to do together!", self.name];
   

}

- (IBAction)x:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)tapMessengerButton:(id)sender {
    NSURL *messengerURL = [NSURL URLWithString:self.URL];
    [[UIApplication sharedApplication] openURL:messengerURL];
    NSLog(@"%@", messengerURL);
    [self dismissViewControllerAnimated:NO completion:nil];
}





@end
