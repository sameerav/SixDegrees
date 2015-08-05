//
//  GraphRequestAPI.m
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/10/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "GraphRequestAPI.h"
#import "User.h"
#import "ParseAPI.h"
#import "SixDegreesLoginViewController.h"

@interface GraphRequestAPI ()
@end

@implementation GraphRequestAPI

+ (void)rankPotentialFriends:(NSArray *)potentialFriendsArray currentUser:(User *)currentUser withBlock:(void (^)())completion{
    
    __block NSMutableDictionary *userIDToStats = [[NSMutableDictionary alloc] init];
    [self setUpUserIDToStatsDictionary:userIDToStats potentialFriends:potentialFriendsArray];
    FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
    __block NSNumber *currentRequestCount = [NSNumber numberWithInt:0];
    
    //Change the 2 to a 3 when you uncomment the code to delete anyone you are facebook friends with!!
    __block NSNumber *finalRequestCount = [NSNumber numberWithInt:(int)[potentialFriendsArray count] * 2];
    
    __block void (^finishedRequestsBlock)() = ^void(){
        currentRequestCount = [NSNumber numberWithInt:[currentRequestCount intValue] + 1];
        if ([currentRequestCount intValue] == [finalRequestCount intValue]) {
            [self calculateTopFriends:userIDToStats currentUser:currentUser potentialFriends:potentialFriendsArray];
            completion();
            [currentUser saveInBackground];
        }
    };
    
    for (User *potentialFriend in potentialFriendsArray) {
        
        
//UNCOMMENT THIS WHEN READY TO IMPLEMENT STUFF TO DELETE FACEBOOK FRIENDS FROM ARRAY
//        //Figure out if currentUser and potentialFriend are facebook friends
//        [connection addRequest:[self isFriendRequest:potentialFriend user:currentUser] completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//            NSArray *theData = result[@"data"];
//            if (theData == nil || [theData count] == 0) {
//                //Users are not friends so add 0 to the last array entry
//                userIDToStats[potentialFriend.objectId][5] = [NSNumber 0];
//            }else{
//                //Users are facebook friends so add 1 to the last array entry
//                userIDToStats[potentialFriend.objectId][5] = [NSNumber 1];
//            }
//        }];
        
        
        [connection addRequest:[self mutualLikesRequest:potentialFriend] completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            //Adds mutual likes count to first array entry
            userIDToStats[potentialFriend.objectId][0] = result[@"context"][@"mutual_likes"][@"summary"][@"total_count"];
            finishedRequestsBlock();
        }];
        
        [connection addRequest:[self mutualFriendsRequest:potentialFriend] completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            //Adds mutual friends count to second array entry
            userIDToStats[potentialFriend.objectId][1] = result[@"context"][@"mutual_friends"][@"summary"][@"total_count"];
            finishedRequestsBlock();
        }];
        
        // userIDToStats[potentialFriend.objectId][2] = [NSDate date];
        // userIDToStats[potentialFriend.objectId][3] = [NSDate date];
        userIDToStats[potentialFriend.objectId][2] = potentialFriend.birthday;
        userIDToStats[potentialFriend.objectId][3] = currentUser.birthday;
        
        // handle location
        PFGeoPoint *myLocation = currentUser.currentLocation;
        PFGeoPoint *friendLocation = potentialFriend.currentLocation;
        double distance = [myLocation distanceInMilesTo:friendLocation];
        NSNumber *distanceValue = [NSNumber numberWithDouble:distance];
        //Adds distance as fifth array entry
        userIDToStats[potentialFriend.objectId][4] = distanceValue;
        
    }
    
    [connection start];
}


//This method calculates the top ten friends for the current user.  Stored in currentUser.connections
+ (void)calculateTopFriends:(NSMutableDictionary *)userIDToStats currentUser:(User *)currentUser potentialFriends:potentialFriendsArray {
    
    //Replace 3rd and 4th birthday entries of array with a single age difference array entry
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    for (NSString *key in [userIDToStats allKeys]){
        NSDateComponents *components = [gregorianCalendar components:(NSDayCalendarUnit |NSYearCalendarUnit )
                                                            fromDate:userIDToStats[key][2]
                                                              toDate:userIDToStats[key][3]
                                                             options:0];
        NSInteger year = [components year];
        NSNumber *ageDiff = [NSNumber numberWithInteger:year];
        [userIDToStats[key] removeObjectAtIndex:3];
        [userIDToStats[key] replaceObjectAtIndex:2 withObject:ageDiff];
        
    //Now for each user in the dictionary there should be an array with: mutual likes, mutual friends, age difference and distance (in that order)
    }
    
    
//Normalize the array entries in the dictionary, userIDToStats
    for (int i = 0; i < 4; i ++) {
        //Find max and min over all the users for each array entry
        NSNumber *topValue = [NSNumber numberWithInt:0];
        NSNumber *bottomValue = [NSNumber numberWithInt:100000];
        for (NSString *key in [userIDToStats allKeys]) {
            NSNumber *value = userIDToStats[key][i];
            if ([topValue doubleValue] < [value doubleValue]) {
                topValue = value;
            }
            if ([value doubleValue] < [bottomValue doubleValue]) {
                bottomValue = value;
            }
        }
        
        //Normalize each entry
        for (NSString *key in userIDToStats) {
            NSNumber *value = userIDToStats[key][i];
            float newFloat = ([value floatValue]-[bottomValue floatValue])/([topValue floatValue] - [bottomValue floatValue]);
            NSNumber *newValue = [NSNumber numberWithFloat:newFloat];
            [userIDToStats[key] replaceObjectAtIndex:i withObject:newValue];
        }
    }
    
    //userIDToStats now contains normalized data
    
    //Next add first two array items and subtract last two to get score.  Add score to new dictionary that contains user IDs and their score
    NSMutableDictionary *userScores = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in userIDToStats) {
        float addedFloat = 0;
        for (int j = 0; j < 4; j++) {
            NSNumber *normalizedValue = userIDToStats[key][j];
            
            NSDictionary *currentUserPreferences = currentUser.preferences;
            if (j == 0) {
                // likes
                NSNumber *weight = currentUserPreferences[@"mutualLikes"];
                normalizedValue = [NSNumber numberWithFloat:[normalizedValue floatValue]*[weight floatValue]];
            } else if (j == 1) {
                // friends
                NSNumber *weight = currentUserPreferences[@"mutualFriends"];
                normalizedValue = [NSNumber numberWithFloat:[normalizedValue floatValue]*[weight floatValue]];
            } else if (j == 2) {
                /// age
                NSNumber *weight = currentUserPreferences[@"age"];
                normalizedValue = [NSNumber numberWithFloat:[normalizedValue floatValue]*[weight floatValue]];
            } else if (j == 3) {
                // distance
                NSNumber *weight = currentUserPreferences[@"distance"];
                normalizedValue = [NSNumber numberWithFloat:[normalizedValue floatValue]*[weight floatValue]];
            }
            
            if (j == 0 || j == 1){
                addedFloat = addedFloat + [normalizedValue floatValue];
            } else {
                addedFloat = addedFloat - [normalizedValue floatValue];
            }
        }
        
        NSNumber *score = [NSNumber numberWithFloat:addedFloat];
        [userScores setObject:score forKey:key];
        
//        //Remove user if facebook friends with user.  Comment out until ready to use.
//        if (userIDToStats[key][4] == 1) {
//            [userScores removeObjectForKey:key]
//        }
        
    }
    
    [userScores removeObjectForKey:currentUser.objectId];
    
    // remove all people who don't meet the criteria
    [ParseAPI doBlockForCurrentUser:^(User *me) {
        PFQuery *query = [[User query] whereKey:@"objectId" containedIn:[userScores allKeys]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject *obj in objects){
                User *u = (User *)obj;
                if ([u.preferences[@"switch"] isEqualToNumber:[NSNumber numberWithBool:NO]] || [u.invisibleFrom containsObject:me.objectId]) {
                    [userScores removeObjectForKey:u.objectId];
                }
            }
            
            NSArray *sorted = [userScores keysSortedByValueUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
                float first = [(NSNumber *)obj1 floatValue];
                float second = [(NSNumber *)obj2 floatValue];
                if (first > second) {
                    return (NSComparisonResult)NSOrderedAscending;
                } else if (second > first) {
                    return (NSComparisonResult)NSOrderedDescending;
                } else {
                    return (NSComparisonResult)NSOrderedSame;
                }
            }];
            
            if ([[userScores allKeys] count] < 10) {
                currentUser.topConnections = [sorted mutableCopy];
            } else {
                NSRange range = NSMakeRange(0, 10);
                NSArray *cutArray = [sorted subarrayWithRange:range];
                currentUser.topConnections = [cutArray mutableCopy];
                NSLog(@"%@", currentUser.topConnections);
            }
        }];
    }];
}


+ (FBSDKGraphRequest *)mutualLikesRequest:(User *)potentialFriend {
    NSDictionary *params = @{@"fields": @"context.fields(mutual_likes)", @"appsecret_proof":[SixDegreesLoginViewController AppSecretProof:[FBSDKAccessToken currentAccessToken].tokenString appSecret:@"1103aa335d4e7821b570464de39fd6fa"]};
    FBSDKGraphRequest *mutualLikesRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:potentialFriend.FBID parameters:params HTTPMethod:@"GET"];
    return mutualLikesRequest;
}

+ (FBSDKGraphRequest *)mutualFriendsRequest:(User *)potentialFriend {
    NSDictionary *params = @{@"fields": @"context.fields(mutual_friends)", @"appsecret_proof":[SixDegreesLoginViewController AppSecretProof:[FBSDKAccessToken currentAccessToken].tokenString appSecret:@"1103aa335d4e7821b570464de39fd6fa"]};
    FBSDKGraphRequest *mutualFriendsRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:potentialFriend.FBID parameters:params HTTPMethod:@"GET"];
    return mutualFriendsRequest;
}

+ (FBSDKGraphRequest *)birthdayRequest:(User *)user {
    NSDictionary *params = @{@"fields": @"birthday"};
    FBSDKGraphRequest *birthdayRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:user.FBID parameters:params HTTPMethod:@"GET"];
    return birthdayRequest;
}

+ (FBSDKGraphRequest *)isFriendRequest:(User *)potentialFriend user:(User *)currentUser {
    NSString *pathTwo = [NSString stringWithFormat:@"%@/friends/%@", currentUser.FBID, potentialFriend.FBID];
    //NSDictionary *params = @{@"appsecret_proof":[SixDegreesLoginViewController AppSecretProof:[FBSDKAccessToken currentAccessToken].tokenString appSecret:@"1103aa335d4e7821b570464de39fd6fa"]};
    
    FBSDKGraphRequest *isFriendsRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:pathTwo parameters:nil HTTPMethod:@"GET"];
    return isFriendsRequest;
}


+ (void)setUpUserIDToStatsDictionary:(NSMutableDictionary *)userIDToStats potentialFriends:(NSArray *)potentialFriendsArray{
    // Set up the raw structure of the dictionary
    for (User *potentialFriend in potentialFriendsArray) {
        NSMutableArray *statsForOneUser = [NSMutableArray array];
        //Change i < 6 to i < 7 when uncommenting everything to delete facebook friends from array
        for (int i = 0; i < 6; i++) {
            statsForOneUser[i] = [NSNull null];
        }
        userIDToStats[potentialFriend.objectId] = statsForOneUser;
    }
}

@end
