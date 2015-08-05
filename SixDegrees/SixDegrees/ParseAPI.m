// Copyright 2004-present Facebook. All Rights Reserved.

#import "ParseAPI.h"
#import <Parse/Parse.h>
#import "User.h"

@interface ParseAPI ()
@end

static NSString *currentUserID = @"";

@implementation ParseAPI

+ (BOOL) userIsNewUser:(User *)user {
    if (user == nil) {
        return NO;
    }
    
    NSString *userID = user.objectId;
    User *objectInDatabase = [ParseAPI getUser:userID];
    if (objectInDatabase == nil) {
        return YES;
    } else {
        return NO;
    }
}

+ (void) getUser:(NSString *)userID withBlock:(void (^)(User *))completion {
    if (userID != nil) {
        [[User query] getObjectInBackgroundWithId:userID block:^(PFObject *object, NSError *error) {
            User *user = (User *)object;
            completion(user);
        }];
    }
}

+ (User *)getCurrentUser {
    return [self getUser:currentUserID];
}

+ (User *) getUser :(NSString *)userID {
    if (userID == nil) {
        return nil;
    }
    PFObject *obj = [[User query] getObjectWithId:userID];
    if (obj == nil) {
        return nil;
    } else {
        User *desiredUser = (User *)obj;
        return desiredUser;
    }
}

+ (void) getUserFromFBID:(NSString *)FBID withBlock:(void (^)(User *))completion {
    if (FBID != nil) {
        PFQuery *query = [[User query] whereKey:@"FBID" equalTo:FBID];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            User *user = (User *)object;
            completion(user);
        }];
    }
}

+ (User *)getUserFromFBID: (NSString *)FBID {
    if (FBID == nil) {
        return nil;
    }
    
    PFQuery *query = [[User query] whereKey:@"FBID" equalTo:FBID];
    PFObject *obj = [query getFirstObject];
    if (obj == nil) {
        return nil;
    } else {
        User *desiredUser = (User *)obj;
        return desiredUser;
    }

}

+ (void) getUsersInLocation: (PFGeoPoint *)location withRadius: (NSInteger) radius withBlock:(void (^)(NSArray *))completion {
    if (location != nil && radius > 0) {
        PFQuery *query = [[User query] whereKey:@"currentLocation" nearGeoPoint:location withinMiles:radius];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSMutableArray *users = [NSMutableArray array];
            for (PFObject *obj in objects) {
                User *user = (User *)obj;
                [users addObject:user];
            }
            completion(users);
        }];
    }
}

+ (NSArray *) getUsersInLocation: (PFGeoPoint *) location
                      withRadius:(NSInteger) radius {
    if (location == nil || radius <= 0) {
        return nil;
    }
    
    PFQuery *query = [[User query] whereKey:@"currentLocation" nearGeoPoint:location withinMiles:radius];
    return [query findObjects];
}

+ (void) getUsersWithPreferences: (NSDictionary *)preferences inLocation:(PFGeoPoint *)location withRadius:(NSInteger)radius withBlock:(void (^)(NSArray *))completion {
    if (location != nil && radius > 0) {
        PFQuery *query = [[User query] whereKey:@"currentLocation" nearGeoPoint:location withinMiles:radius];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSMutableArray *users = [NSMutableArray array];
            for (PFObject *obj in objects) {
                User *user = (User *)obj;
                for (NSString *key in [preferences allKeys]) {
                    NSSet *testingPreferencesForKey = preferences[key];
                    NSSet *userPreferencesForKey = user.preferences[key];
                    for (NSString *preference in testingPreferencesForKey) {
                        if ([userPreferencesForKey containsObject:preference]) {
                            if (![users containsObject:user]) {
                                [users addObject:user];
                            }
                        }
                    }
                }
            }
            completion(users);
        }];
    }
}

+ (NSArray *) getUsersWithPreferences: (NSDictionary *) preferences
                           inLocation: (PFGeoPoint *) location
                           withRadius: (NSInteger) radius {
    if (preferences == nil || location == nil || radius <= 0) {
        return nil;
    }
    
    NSArray *allUsers = [ParseAPI getUsersInLocation:location withRadius:radius];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSDictionary *userPreferences = ((User *)evaluatedObject).preferences;
        for (NSString *key in [preferences allKeys]) {
            NSSet *testingPreferencesForKey = preferences[key];
            NSSet *userPreferencesForKey = userPreferences[key];
            for (NSString *preference in testingPreferencesForKey) {
                if ([userPreferencesForKey containsObject:preference]) {
                    return YES;
                }
            }
        }
        return FALSE;
    }];
    return [allUsers filteredArrayUsingPredicate:predicate];

}

+ (BOOL)updateOrCreateUser:(User *)user {
    if (user == nil) {
        return YES;
    }
    
    if (user.objectId == nil) {
        // this needs to be inserted in the database
        return [user save];
    } else {
        // this object needs to be updated
        if ([user isDirty]) {
            return [user save];
        }
        return YES;
    }
}

+ (void)updateOrCreateUser:(User *)user withBlock:(void (^)(User *))completion {
    if (user != nil) {
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            currentUserID = user.objectId;
            completion(user);
        }];
    }
}

+ (void)findTopFriendsInBackground:(NSString *)userID withBlock:(void (^)(NSArray *))completion {
    [ParseAPI getUser:userID withBlock:^(User *me) {
        // hi
        [ParseAPI getUsersInLocation:me.currentLocation withRadius:150 withBlock:^(NSArray *users) {
            NSMutableArray *allUsers = [NSMutableArray array];
            for (PFObject *obj in users) {
                User *u = (User *)obj;
                [allUsers addObject:u];
            }
            
            completion(allUsers);
        }];
    }];
}

+ (void)sendConversationStartedMessageFrom:(NSString *)myID to:(NSString *)friendID {
    [ParseAPI getUser:myID withBlock:^(User *user) {
        PFPush *push = [[PFPush alloc] init];
        [push setChannel:friendID];
        
        // TODO: UPDATE FIRST NAME
        NSString *firstName = [[NSString stringWithFormat:@"%@", user.name] capitalizedString];
        
        NSString *message = [firstName stringByAppendingString:@" has started a conversation with you! Open your Messenger application to read it."];
        [push setMessage:message];
        [push sendPushInBackground];
    }];
}

+ (void) doBlockForCurrentUser:(void (^)(User *))action {
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         [ParseAPI getUserFromFBID:result[@"id"] withBlock:^(User *user) {
             action(user);
         }];
     }];
}



+ (UserConnection *) getConnection:(User *)me with:(NSString *)friendID {
    // fix this
    PFQuery *query = [[[UserConnection query] whereKey:@"initialUserID" equalTo:me.objectId] whereKey:@"addedUserID" equalTo:friendID];
    NSArray *allObjects = [query findObjects];
    if (allObjects == nil || [allObjects count] == 0) {
        query = [[[UserConnection query] whereKey:@"addedUserID" equalTo:me.objectId] whereKey:@"initialUserID" equalTo:friendID];
        allObjects = [query findObjects];
        if (allObjects == nil || [allObjects count] == 0) {
            return nil;
        } else {
            UserConnection *connection = (UserConnection *)(allObjects[0]);
            return connection;
        }
    } else {
        UserConnection *connection = (UserConnection *)(allObjects[0]);
        return connection;
    }
}

+ (NSArray *) getAllConnections:(User *)me {
    PFQuery *firstQuery = [[UserConnection query] whereKey:@"initialUserID" equalTo:me.objectId];
    PFQuery *secondQuery = [[UserConnection query] whereKey:@"addedUserID" equalTo:me.objectId];
    NSMutableArray *firstQueryResults = [[firstQuery findObjects] mutableCopy];
    NSMutableArray *secondQueryResults = [[secondQuery findObjects] mutableCopy];
    [firstQueryResults addObjectsFromArray:secondQueryResults];
    return firstQueryResults;
}

+ (BOOL) updateOrCreateConnection:(UserConnection *)connection {
    if (connection == nil) {
        return YES;
    }
    
    if (connection.objectId == nil) {
        // this needs to be inserted in the database
        return [connection save];
    } else {
        // this object needs to be updated
        if ([connection isDirty]) {
            return [connection save];
        }
        return YES;
    }
}

// asynchronous methods
+ (void) forConnection:(User *)me with:(NSString *)friendID doBlock:(void (^)(UserConnection *))completion {
    PFQuery *queryOne = [[[UserConnection query] whereKey:@"initialUserID" equalTo:me.objectId] whereKey:@"addedUserID" equalTo:friendID];
    PFQuery *queryTwo = [[[UserConnection query] whereKey:@"initialUserID" equalTo:friendID] whereKey:@"addedUserID" equalTo:me.objectId];
    for (PFQuery *query in @[queryOne, queryTwo]) {
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            UserConnection *connection = (UserConnection *)object;
            completion(connection);
        }];
    }
}

+ (void) forAllConnectionsTo:(User *)me doBlock:(void (^)(NSArray *))completion {
    PFQuery *queryOne = [[UserConnection query] whereKey:@"initialUserID" equalTo:me.objectId];
    PFQuery *queryTwo = [[UserConnection query] whereKey:@"addedUserID" equalTo:me.objectId];
    for (PFQuery *query in @[queryOne, queryTwo]) {
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSMutableArray *connections = [NSMutableArray array];
            for (PFObject *obj in objects) {
                UserConnection *connection = (UserConnection *)obj;
                [connections addObject:connection];
            }
            completion(connections);
        }];
    }
}

+ (void)updateOrCreateConnection:(UserConnection *)connection withBlock:(void (^)(UserConnection *))completion {
    if (connection != nil) {
        [connection saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            completion(connection);
        }];
    }
}

@end
