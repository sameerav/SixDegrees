// Copyright 2004-present Facebook. All Rights Reserved.

#import "User.h"

#import <Parse/PFObject+Subclass.h>

#import "ParseAPI.h"

@interface User ()
@end

@implementation User

@dynamic currentLocation;
@dynamic FBID;
@dynamic preferences;
@dynamic connections;
@dynamic name;
@dynamic url;
@dynamic birthday;
@dynamic invisibleFrom;
@dynamic blocked;

@synthesize locationManager;
@dynamic topConnections;


- (CLLocationCoordinate2D)getCLcurrentLocation {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.currentLocation.latitude, self.currentLocation.longitude);
    return coordinate;
}

+ (NSString *)parseClassName {
    return @"User";
}

+ (void)registerSubclass {
    [super registerSubclass];
}

- (instancetype)initWithFBID:(NSString *)FBID andLocation:(PFGeoPoint *)location {
    self = [User object];
    if (self) {
        self.currentLocation = location;
        self.FBID = FBID;
        self.preferences = [NSMutableDictionary dictionary];
        self.invisibleFrom = [NSMutableArray array];
        self.blocked = [NSMutableArray array];
        // set default values for preferences
        self.preferences[@"distance"] = [NSNumber numberWithFloat:0.5];
        self.preferences[@"mutualFriends"] = [NSNumber numberWithFloat:0.5];
        self.preferences[@"mutualLikes"] = [NSNumber numberWithFloat:0.5];
        self.preferences[@"age"] = [NSNumber numberWithFloat:0.5];
        self.preferences[@"switch"] = [NSNumber numberWithBool:YES];
        
        self.connections = [NSMutableArray array];
        self.topConnections = [NSMutableArray array];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
        self.name = @"";
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             self.name = result[@"name"];
             [self saveInBackground];
         }];
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = [PFGeoPoint geoPointWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    [self saveInBackground];
}

// both users must be saved for this method to work
- (void)addConnectionToUser:(NSString *)userID {

    [ParseAPI getUser:userID withBlock:^(User *otherUser) {
        [otherUser.connections addObject:self.objectId];
        [self.connections addObject:userID];
        [self saveInBackground];
        [otherUser saveInBackground];
    }];
}

- (NSUInteger)numConnections {
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:self.connections];
    NSArray *arrayWithoutDuplicates = [orderedSet array];
    self.connections = [arrayWithoutDuplicates mutableCopy];
    return self.connections.count;
}

- (void)blockUser:(User *)user {
    if (![self.invisibleFrom containsObject:user.objectId]) {
        [self.invisibleFrom addObject:user.objectId];
    }
    if (![user.invisibleFrom containsObject:self.objectId]) {
        [user.invisibleFrom addObject:self.objectId];
    }
    if (![self.blocked containsObject:user.objectId]) {
        [self.blocked addObject:user.objectId];
    }
    
    // delete the userconnection object
    [self.connections removeObject:user.objectId];
    [user.connections removeObject:self.objectId];
    [ParseAPI forConnection:self with:user.objectId doBlock:^(UserConnection *connection) {
        [connection deleteInBackground];
    }];
    [self saveInBackground];
    [user saveInBackground];
}

- (void)unblockUser:(User *)user {
    [self.invisibleFrom removeObject:user.objectId];
    [user.invisibleFrom removeObject:self.objectId];
    [self.blocked removeObject:user.objectId];
    [self saveInBackground];
    [user saveInBackground];
}

@end
