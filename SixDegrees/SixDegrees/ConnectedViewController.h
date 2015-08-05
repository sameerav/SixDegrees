//
//  ConnectedViewController.h
//  SixDegrees
//
//  Created by Daniel Moreno on 7/21/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface ConnectedViewController : UIViewController
-(instancetype) initWithOtherFBID:(NSString *)fbid andName:(NSString *) name andURL:(NSString *)url;
@end
