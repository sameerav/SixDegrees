//
//  BlockedUserViewController.h
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/24/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;

@interface BlockedUserViewController : UIViewController
- (instancetype)initWithUser:(User *)me;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end
