//
//  WebViewController.h
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/15/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;

@interface WebViewController : UIViewController <UIWebViewDelegate>
- (instancetype) initWithUser:(User *)user;
@property (copy) void (^block) (User *);
@end
