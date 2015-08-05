//
//  BlockedTableViewCell.h
//  SixDegrees
//
//  Created by Daniel Moreno on 7/24/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface BlockedTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UISwitch *blockedSwitch;
@property (strong, nonatomic) NSString *parseId;
@end
