//
//  ConverstionCell.h
//  SixDegrees
//
//  Created by Daniel Moreno on 7/10/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseUI/ParseUI.h>

@interface ConversationCell : PFTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsLabel;

@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *profilePicture;
@property (copy) NSString *user;


@end
