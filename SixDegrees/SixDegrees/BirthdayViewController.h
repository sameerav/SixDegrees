//
//  BirthdayViewController.h
//  SixDegrees
//
//  Created by Daniel Moreno on 7/20/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;
@interface BirthdayViewController : UIViewController
- (instancetype)initWithUser:(User *)user;
@end
