//
//  UserConnection.m
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/10/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "UserConnection.h"
#import "GraphRequestAPI.h"
#import "ParseAPI.h"
#import "User.h"
#import "Suggestion.h"
#import "SuggestionsAPI.h"

@implementation UserConnection
@dynamic location;
@dynamic date;
@dynamic suggestions;
@dynamic initialUserID;
@dynamic addedUserID;
@dynamic mutualFriends;
@dynamic initialUserName;
@dynamic addedUserName;
@dynamic initialUserVisible;
@dynamic addedUserVisible;


+ (NSString *)parseClassName {
    return @"UserConnection";
}

+ (void)registerSubclass {
    [super registerSubclass];
}

- (void)makeVisible:(User *)user {
    if ([user.objectId isEqualToString:self.addedUserID]) {
        self.addedUserVisible = [NSNumber numberWithBool:YES];
        [user.invisibleFrom removeObject:self.initialUserID];
    } else {
        self.initialUserVisible = [NSNumber numberWithBool:YES];
        [user.invisibleFrom removeObject:self.addedUserID];
    }
    [user saveInBackground];
    [self saveInBackground];
}

- (void)makeInvisible:(User *)user {
    if ([user.objectId isEqualToString:self.addedUserID]) {
        self.addedUserVisible = [NSNumber numberWithBool:NO];
        if (![user.invisibleFrom containsObject:self.initialUserID]) {
            [user.invisibleFrom addObject:self.initialUserID];
        }
    } else {
        self.initialUserVisible = [NSNumber numberWithBool:NO];
        if (![user.invisibleFrom containsObject:self.addedUserID]) {
            [user.invisibleFrom addObject:self.addedUserID];
        }
    }
    [user saveInBackground];
    [self saveInBackground];
}

- (instancetype)initWithInitialUser:(User *)me andAddedUser:(User *)friend inLocation:(PFGeoPoint *)location {
    self = [super init];
    if (self) {
        self.initialUserID = me.objectId;
        self.addedUserID = friend.objectId;
        self.location = location;
        
        // set the date to now
        self.date = [NSDate date];
        [self makeInvisible:me];
        [self makeInvisible:friend];
        
        // Figure out how to do these later
        
        self.suggestions = [NSMutableArray array];
        [SuggestionsAPI queryForSuggestionWithLocation:location withOffset: 0 withBlock:^(PFGeoPoint *location, NSString *description, NSString *name, NSNumber *rating, NSString *pictureURL) {
            Suggestion *suggestion = [[Suggestion alloc] initWithLocation:location andDescription:description andName:name andRating:rating andPictureURL:pictureURL];
            [self.suggestions addObject:suggestion];
            [self saveInBackground];
        }];
        
        self.initialUserName = me.name;
        self.initialUserID = me.objectId;
        self.addedUserName = friend.name;
        self.addedUserID = friend.objectId;
        FBSDKGraphRequest *mutualFriendsRequest = [GraphRequestAPI mutualFriendsRequest:friend];
        [mutualFriendsRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            self.mutualFriends = result[@"context"][@"mutual_friends"][@"summary"][@"total_count"];
        }];
    }
    return self;
}

@end
