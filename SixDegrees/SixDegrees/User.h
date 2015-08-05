// Copyright 2004-present Facebook. All Rights Reserved.

#import <Foundation/Foundation.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import <Parse/Parse.h>

#import <CoreLocation/CoreLocation.h>

@interface User : PFObject<PFSubclassing, CLLocationManagerDelegate>
@property CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *topConnections;
@property (nonatomic, strong) PFGeoPoint *currentLocation;
// A dictionary of PFGeoPoints to NSDate

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *FBID;
@property (nonatomic, strong) NSMutableDictionary *preferences;

// an array of ids
@property (nonatomic, retain) NSMutableArray *connections;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDate *birthday;

@property (nonatomic, strong) NSMutableArray *invisibleFrom;
@property (nonatomic, strong) NSMutableArray *blocked;

// an inherited objectId property exists too (from subclassing pfobject)

- (instancetype)initWithFBID:(NSString *)FBID andLocation:(PFGeoPoint *)location;
- (CLLocationCoordinate2D)getCLcurrentLocation;

- (void)addConnectionToUser:(NSString *)userID;

- (NSUInteger)numConnections;

- (void)blockUser:(User *)user;
- (void)unblockUser:(User *)user;

@end

