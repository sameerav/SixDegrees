//
//  UserConnection.h
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/10/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
@class Suggestion;
@class User;

@interface UserConnection : PFObject <PFSubclassing>

@property (strong, nonatomic) PFGeoPoint *location;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSMutableArray *suggestions;
@property (strong, nonatomic) NSString *initialUserID;
@property (strong, nonatomic) NSString *addedUserID;
@property (strong, nonatomic) NSNumber *mutualFriends;
@property (strong, nonatomic) NSString *initialUserName;
@property (strong, nonatomic) NSString *addedUserName;
@property (strong, nonatomic) NSNumber *initialUserVisible;
@property (strong, nonatomic) NSNumber *addedUserVisible;

- (instancetype)initWithInitialUser:(User *)me andAddedUser:(User *)friend inLocation:(PFGeoPoint *)location;

- (void)makeVisible:(User *)user;
- (void)makeInvisible:(User *)user;

@end
