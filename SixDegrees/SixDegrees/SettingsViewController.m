//
//  SettingsViewController.m
//  SixDegrees
//
//  Created by Daniel Moreno on 7/9/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "SettingsViewController.h"
#import "SWRevealViewController.h"
#import "SixDegreesLoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "ParseAPI.h"
#import "User.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UISwitch *incomingConnections;
@property (strong, nonatomic) IBOutlet UISlider *distanceSlider;
@property (strong, nonatomic) IBOutlet UISlider *mutualFriendsSlider;
@property (strong, nonatomic) IBOutlet UISlider *mutualLikesSlider;
@property (strong, nonatomic) IBOutlet UISlider *ageSlider;
@property (strong, nonatomic) NSMutableDictionary *changedSettings;

@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@end

@implementation SettingsViewController

- (IBAction)incomingConnectionsSwitchToggled:(id)sender {
    if ([self.incomingConnections isOn]) {
        self.changedSettings[@"switch"] = [NSNumber numberWithBool:YES];
    } else {
        self.changedSettings[@"switch"] = [NSNumber numberWithBool:NO];
    }
}

- (void)handleSliderShiftForKey:(NSString *)key withSender:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.changedSettings[key] = [NSNumber numberWithFloat:slider.value];
}

- (IBAction)distanceSliderShifted:(id)sender {
    [self handleSliderShiftForKey:@"distance" withSender:sender];
}

- (IBAction)mutualFriendSliderShifted:(id)sender {
    [self handleSliderShiftForKey:@"mutualFriends" withSender:sender];
}
- (IBAction)mutualLikesSliderShifted:(id)sender {
    [self handleSliderShiftForKey:@"mutualLikes" withSender:sender];
}
- (IBAction)ageSliderShifted:(id)sender {
    [self handleSliderShiftForKey:@"age" withSender:sender];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.changedSettings = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.currentUser refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self setValuesForPreferences];
        [self.view setNeedsDisplay];
    }];
    
    // set the values
    [self setValuesForPreferences];
}

- (void)setValuesForPreferences {
    for (NSString *key in [self.currentUser.preferences allKeys]) {
        if ([key isEqualToString:@"switch"]) {
            if ([self.currentUser.preferences[@"switch"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                // the switch is on
                [self.incomingConnections setOn:YES];
            } else {
                [self.incomingConnections setOn:NO];
            }
        } else if ([key isEqualToString:@"distance"]) {
            NSNumber *nsvalue = self.currentUser.preferences[@"distance"];
            float value = [nsvalue floatValue];
            [self.distanceSlider setValue:value animated:NO];
        } else if ([key isEqualToString:@"mutualFriends"]) {
            NSNumber *nsvalue = self.currentUser.preferences[@"mutualFriends"];
            float value = [nsvalue floatValue];
            [self.mutualFriendsSlider setValue:value animated:NO];
        } else if ([key isEqualToString:@"mutualLikes"]) {
            NSNumber *nsvalue = self.currentUser.preferences[@"mutualLikes"];
            float value = [nsvalue floatValue];
            [self.mutualLikesSlider setValue:value animated:NO];
        } else if ([key isEqualToString:@"age"]) {
            NSNumber *nsvalue = self.currentUser.preferences[@"age"];
            float value = [nsvalue floatValue];
            [self.ageSlider setValue:value animated:NO];
        }
    }
}

- (IBAction)menuButtonTapped:(id)sender {
    
    if (self.revealViewController){
        [self.revealViewController revealToggle:self];
    }
    for (NSString *key in [self.changedSettings allKeys]) {
        NSNumber *value = self.changedSettings[key];
        self.currentUser.preferences[key] = value;
    }
    [self.currentUser saveInBackground];
}

@end
