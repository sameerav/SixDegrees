//
//  BirthdayViewController.m
//  SixDegrees
//
//  Created by Daniel Moreno on 7/20/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "BirthdayViewController.h"
#import "SixDegreesLoginViewController.h"
#import "HomeViewController.h"
#import "User.h"

@interface BirthdayViewController ()
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) User *user;
@end

@implementation BirthdayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.datePicker.maximumDate = [NSDate date];
}
- (IBAction)save:(id)sender {
    //check if over 18?
    NSDate *toSave = self.datePicker.date;
    NSLog(@"Save to Parse: %@", toSave);
    
    self.user.birthday = toSave;
    [self.user saveInBackground];
    UIViewController *presentingVC = self.presentingViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        [presentingVC dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (instancetype)initWithUser:(User *)user {
    self = [super init];
    if (self) {
        self.user = user;
    }
    return self;
}



@end
