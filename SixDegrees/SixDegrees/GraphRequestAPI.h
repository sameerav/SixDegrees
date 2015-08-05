//
//  GraphRequestAPI.h
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/10/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface GraphRequestAPI : NSObject
+ (void)rankPotentialFriends:(NSArray *)potentialFriendsArray currentUser:(User *)currentUser withBlock:(void (^)())completion;

+ (FBSDKGraphRequest *)mutualLikesRequest:(User *)potentialFriend;

+ (FBSDKGraphRequest *)mutualFriendsRequest:(User *)potentialFriend;

+ (NSArray *)calculateMutualFriendsArray:(User *)currentUser andPotentialFriend:(User *)potentialFriend;

@end
