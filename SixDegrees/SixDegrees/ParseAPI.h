// Copyright 2004-present Facebook. All Rights Reserved.

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "UserConnection.h"

@class User;

@interface ParseAPI : NSObject


// METHODS TO QUERY THE DATABASE

// DONT USE THIS GENERALLY, THIS SLOWS DOWN THE MAIN THREAD
+ (User *) getUser :(NSString *)userID;

// USE THIS WITH A COMPLETION HANDLER INSTEAD
+ (void) getUser:(NSString *)userID withBlock:(void (^)(User *))completion;

+ (User *)getUserFromFBID: (NSString *)FBID;

+ (void) getUserFromFBID:(NSString *)FBID withBlock:(void (^)(User *))completion;

+ (NSArray *) getUsersInLocation: (PFGeoPoint *) location
                      withRadius:(NSInteger) radius;

+ (void) getUsersInLocation: (PFGeoPoint *)location withRadius: (NSInteger) radius withBlock:(void (^)(NSArray *))completion;

+ (NSArray *) getUsersWithPreferences: (NSDictionary *) preferences
                           inLocation: (PFGeoPoint *) location
                           withRadius: (NSInteger) radius;

+ (void) getUsersWithPreferences: (NSDictionary *)preferences inLocation:(PFGeoPoint *)location withRadius:(NSInteger)radius withBlock:(void (^)(NSArray *))completion;

+ (BOOL) userIsNewUser:(User *)user;

// METHODS TO UPDATE ROWS IN THE DATABASE - THESE WILL ONLY BE USED BY MODEL OBJECTS
+ (BOOL)updateOrCreateUser:(User *)user;

+ (void)updateOrCreateUser:(User *)user withBlock:(void (^)(User *))completion;

+ (User *)getCurrentUser;

// METHODS TO SEND NOTIFICATIONS
+ (void)sendConversationStartedMessageFrom:(NSString *)myID to:(NSString *)friendID;

+ (void)findTopFriendsInBackground:(NSString *)userID withBlock:(void (^)(NSArray *))completion;

+ (void) doBlockForCurrentUser:(void (^)(User *))action;

// METHODS ABOUT USER CONNECTIONS
// synchronous methods
+ (UserConnection *) getConnection:(User *)me with:(NSString *)friendID;
+ (NSArray *) getAllConnections:(User *)me;
+ (BOOL) updateOrCreateConnection:(UserConnection *)connection;
// asynchronous methods
+ (void) forConnection:(User *)me with:(NSString *)friendID doBlock:(void (^)(UserConnection *))completion;
+ (void) forAllConnectionsTo:(User *)me doBlock:(void (^)(NSArray *))completion;
+ (void)updateOrCreateConnection:(UserConnection *)connection withBlock:(void (^)(UserConnection *))completion;

@end
