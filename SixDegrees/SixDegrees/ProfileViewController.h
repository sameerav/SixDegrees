//
//  ProfileViewController.h
//  SixDegrees
//
//  Created by Daniel Moreno on 7/9/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface ProfileViewController : UIViewController <FBSDKLoginButtonDelegate, iCarouselDataSource, iCarouselDelegate>

@property (strong, nonatomic) NSMutableArray *fbids;
@property (strong, nonatomic) NSMutableArray *likes;

@property (strong, nonatomic) NSMutableDictionary *cache;
@property (strong, nonatomic) NSMutableArray *friendProfilePictures;
@property (strong, nonatomic) IBOutlet UILabel *hometown;

- (void)setValues;
@end
