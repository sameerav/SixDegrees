//
//  LoginHelper.h
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/22/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@class SixDegreesLoginViewController;
@class HomeViewController;

@interface LoginHelper : NSObject
+ (void)loginAfterManualFacebookLoginWithLocation:(PFGeoPoint *)location andView:(SixDegreesLoginViewController *)viewController;
+ (void)loginAfterAutoLoginWithView:(HomeViewController *)viewController;
@end
