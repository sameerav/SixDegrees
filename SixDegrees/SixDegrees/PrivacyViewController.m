//
//  PrivacyViewController.m
//  SixDegrees
//
//  Created by Daniel Moreno on 7/24/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "PrivacyViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ParseAPI.h"
#import "User.h"
#import "SWRevealViewController.h"
#import "HomeViewController.h"
#import "MapViewController.h"
#import "ConversationsViewController.h"
#import "ConversationsTableViewController.h"

@interface PrivacyViewController ()
@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *otherUser;
@property (strong, nonatomic) IBOutlet UISwitch *locationSwitch;
@property (strong, nonatomic) NSString *fbid;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UILabel *blockLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UISwitch *block;
@property (strong, nonatomic) NSNumber *locationSwitchBool;
@end

@implementation PrivacyViewController

-(instancetype)initWithFBID:(NSString *)fbid andName:(NSString *)userName {
    self = [super init];
    if (self){
        self.fbid = fbid;
        self.name = userName;
        
        [ParseAPI doBlockForCurrentUser:^(User *me) {
            [ParseAPI getUserFromFBID:self.fbid withBlock:^(User *friend) {
                [ParseAPI forConnection:me with:friend.objectId doBlock:^(UserConnection *connection) {
                    //
                    if ([me.objectId isEqualToString:connection.addedUserID]) {
                        if ([connection.addedUserVisible isEqualToNumber:[NSNumber numberWithBool:NO]]) {
                            self.locationSwitchBool = [NSNumber numberWithBool:NO];
                        }
                    }
                    if ([me.objectId isEqualToString:connection.initialUserID]) {
                        if ([connection.initialUserVisible isEqualToNumber:[NSNumber numberWithBool:NO]]) {
                            self.locationSwitchBool = [NSNumber numberWithBool:NO];
                        }
                    }
                }];
            }];
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.otherUser.profileID = self.fbid;
    self.otherUser.layer.cornerRadius = self.otherUser.frame.size.width / 2;
    self.otherUser.layer.borderWidth = 1.0;
    self.otherUser.layer.borderColor = [UIColor whiteColor].CGColor;
    self.otherUser.clipsToBounds = YES;
    self.infoLabel.text = [NSString stringWithFormat:@"You & %@", self.name];
    self.textLabel.text = [NSString stringWithFormat:@"Always share location with %@?", self.name];
    
    self.blockLabel.text = [NSString stringWithFormat:@"Do you want to block %@?", self.name];
    
    [self setPreferences];
    
}

- (void)setPreferences {
    if ([self.locationSwitchBool isEqualToNumber:[NSNumber numberWithBool:NO]]) {
        [self.locationSwitch setOn:NO animated:YES];
    } else {
        [ParseAPI doBlockForCurrentUser:^(User *me) {
            [ParseAPI getUserFromFBID:self.fbid withBlock:^(User *friend) {
                [ParseAPI forConnection:me with:friend.objectId doBlock:^(UserConnection *connection) {
                    //
                    if ([me.objectId isEqualToString:connection.addedUserID]) {
                        if ([connection.addedUserVisible isEqualToNumber:[NSNumber numberWithBool:NO]]) {
                            [self.locationSwitch setOn:NO animated:YES];
                        }
                    }
                    if ([me.objectId isEqualToString:connection.initialUserID]) {
                        if ([connection.initialUserVisible isEqualToNumber:[NSNumber numberWithBool:NO]]) {
                            [self.locationSwitch setOn:NO animated:YES];
                        }
                    }
                }];
            }];
        }];
    }
}

- (IBAction)blocked:(id)sender {
}


- (void)savePrivacyPreferences {
    [ParseAPI doBlockForCurrentUser:^(User *me) {
        [ParseAPI getUserFromFBID:self.fbid withBlock:^(User *friend) {
            [ParseAPI forConnection:me with:friend.objectId doBlock:^(UserConnection *connection) {
                if (self.locationSwitch.on) {
                    [connection makeVisible:me];
                } else {
                    [connection makeInvisible:me];
                }
            }];

            if (self.locationSwitch.on) {
                [me.invisibleFrom removeObject:friend.objectId];
            } else {
                if (![me.invisibleFrom containsObject:friend.objectId]){
                    [me.invisibleFrom addObject:friend.objectId];
                }
            }
            
            if (self.block.on) {
                NSString *title = [[@"Block " stringByAppendingString:friend.name] stringByAppendingString:@"?"];
                NSString *message = [[@"Are you sure you want to block " stringByAppendingString:friend.name] stringByAppendingString:@"?"];
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [self.block setOn:NO animated:YES];
                }];
                
                UIAlertAction *approveAction = [UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [ac dismissViewControllerAnimated:YES completion:nil];
                    [me blockUser:friend];
                    UIViewController *firstVC = self.presentingViewController;
                    SWRevealViewController *secondVC = (SWRevealViewController *)(self.presentingViewController.presentingViewController);
                    HomeViewController *hvc = (HomeViewController *)(secondVC.frontViewController);
                    MapViewController *mvc = hvc.mvc;
                    [mvc removeFromMap:friend];
                    [mvc.mapView setNeedsDisplay];
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        [firstVC dismissViewControllerAnimated:YES completion:^{
                            [hvc.cvc.ctvc reloadData];
                            
                            NSString *firstName = [friend.name componentsSeparatedByString:@" "][0];
                            NSString *blockedMessage = [[[[@"Succesfullly blocked " stringByAppendingString:friend.name] stringByAppendingString:@". If you want to unblock "] stringByAppendingString:firstName] stringByAppendingString:@", go to Profile."];
                            UIAlertController *blockController = [UIAlertController alertControllerWithTitle:@"Success!" message:blockedMessage preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *cancelBlock = [UIAlertAction actionWithTitle:@"Got it!" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                [self.block setOn:NO animated:YES];
                            }];
                            [blockController addAction:cancelBlock];
                        }];
                    }];
                }];
                
                [ac addAction:cancelAction];
                [ac addAction:approveAction];
                [self presentViewController:ac animated:YES completion:nil];
            }
        }];
    }];
}

- (IBAction)done:(id)sender {
    [self savePrivacyPreferences];

    if(![self.block isOn]){
            [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
