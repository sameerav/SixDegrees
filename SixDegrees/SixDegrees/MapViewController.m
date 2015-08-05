//
//  MapViewController.m
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/6/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "MapViewController.h"
#import "User.h"
#import "ParseAPI.h"
#import "MapInfoWindowViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ConnectedViewController.h"
#import "GraphRequestAPI.h"
#import "SixDegreesLoginViewController.h"
#import "OverlayViewController.h"
#import "DetailViewController.h"
#import "ConnectedMapInfoWindowViewController.h"
#import "HomeViewController.h"


@interface MapViewController ()
@property (strong, nonatomic) NSMutableArray *markers;
@property BOOL testMarker;
@property User *user;
@property (strong, nonatomic) NSMutableDictionary *markerData;
@property (strong, nonatomic) DetailViewController *currentDVC;
@end

@implementation MapViewController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        // MAKE THIS YES TO TEST THE MARKERS
        self.testMarker = NO;

        self.markerData = [NSMutableDictionary dictionary];
        self.markers = [NSMutableArray array];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 20;
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager startMonitoringSignificantLocationChanges];
        // Initialize mapView
        int zoomLevel = 13;
    
        CLLocationCoordinate2D coords = self.locationManager.location.coordinate;
        
        coords = self.locationManager.location.coordinate;
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coords.latitude
                                                                longitude:coords.longitude
                                                                     zoom:zoomLevel];
        
        GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        mapView.delegate = self;
        
        
        // Set the mapType to a drawn representation
        mapView.mapType = kGMSTypeNormal;
        mapView.myLocationEnabled = YES;
        mapView.settings.myLocationButton = YES;
        mapView.padding = UIEdgeInsetsMake(0, 0, 10, 0);
        
        self.mapView = mapView;
        
        UIButton *shuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shuffleButton addTarget:self action:@selector(shuffle) forControlEvents:UIControlEventTouchUpInside];
        [shuffleButton setImage:[UIImage imageNamed:@"shuffle"] forState:UIControlStateNormal];
        shuffleButton.frame = CGRectMake(326, 34, 30, 30);
        UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [helpButton addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
        [helpButton setImage:[UIImage imageNamed:@"help"] forState:UIControlStateNormal];
        helpButton.frame = CGRectMake(8, 537, 26, 26);
        UIImageView*logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"longlogo"]];
        
        logo.frame = CGRectMake(118, 25, 139, 53);
        
        
        self.view = mapView;
        [self.view addSubview:shuffleButton];
        [self.view addSubview:helpButton];
        [self.view addSubview:logo];
        //NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateAllMarkers) userInfo:nil repeats:YES];
        [ParseAPI doBlockForCurrentUser:^(User *me) {
            [self updateAllMarkers];
        }];
    }
    
    return self;
}

- (void)disableGestures {
    self.mapView.settings.scrollGestures = NO;
    self.mapView.settings.zoomGestures = NO;
    self.mapView.settings.tiltGestures = NO;
    self.mapView.settings.rotateGestures = NO;
}

- (void)enableGestures {
    self.mapView.settings.scrollGestures = YES;
    self.mapView.settings.zoomGestures = YES;
    self.mapView.settings.tiltGestures = YES;
    self.mapView.settings.rotateGestures = YES;
}

- (void)placeFriendMarker:(User *)friend {
    // this should ONLY add a new marker
    BOOL markerExists = NO;
    for (GMSMarker *marker in self.markers) {
        User *markerUser = (User *)(marker.userData);
        if (markerUser == friend) {
            markerExists = YES;
        }
    }
    if (!markerExists) {
        [friend refreshInBackgroundWithBlock:^(PFObject *refreshedObject, NSError *refreshedError) {
            User *refreshedUser = (User *)refreshedObject;
            if (![refreshedUser.invisibleFrom containsObject:self.user.objectId]) {
                GMSMarker *marker = [GMSMarker markerWithPosition:[refreshedUser getCLcurrentLocation]];
                marker.userData = refreshedUser;
                marker.map = self.mapView;
                if ([self.user.connections containsObject:refreshedUser.objectId]){
                    marker.icon = [UIImage imageNamed:@"grayPerson"];
                } else {
                    marker.icon = [UIImage imageNamed:@"person"];
                }
                marker.infoWindowAnchor = CGPointMake(1.2, 0);
                [self.markers addObject:marker];
                [self.view setNeedsDisplay];
                self.hvc.spinner.hidden = YES;
                [self.hvc.spinner stopAnimating];
                [self.hvc.spinner setNeedsDisplay];
            }
        }];
    }
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    [self updateAllMarkers];
}

- (void)updateFriendMarker:(CLLocationManager *)manager toLocation:(CLLocationCoordinate2D)location {
    // this should move an existing marker
    NSMutableArray *toRemove = [NSMutableArray array];
    for (int i = 0; i < [self.markers count]; i++) {
        GMSMarker *marker = self.markers[i];
        User *markerUser = (User *)(marker.userData);
        if (markerUser.locationManager == manager) {
            if (![markerUser.invisibleFrom containsObject:self.user.objectId]) {
                [markerUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    [UIView animateWithDuration:0.1 animations:^{
                        User *friend = (User *)object;
                        if ([self.user.connections containsObject:friend.objectId]) {
                            marker.icon = [UIImage imageNamed:@"grayPerson"];
                        } else {
                            marker.icon = [UIImage imageNamed:@"person"];
                        }
                        marker.position = [(User *)object getCLcurrentLocation];
                        [self.view setNeedsDisplay];
                    }];
                }];
            } else {
                // remove from the map
                marker.map = nil;
                [toRemove addObject:marker];
            }
        }
    }
    
    for (GMSMarker *marker in toRemove) {
        [self.markers removeObject:marker];
    }
}

- (void)updateAllMarkers {
    
    [ParseAPI doBlockForCurrentUser:^(User *me) {
        self.user = me;
        for (NSString *parseID in me.topConnections) {
            [ParseAPI getUser:parseID withBlock:^(User *connectionUser) {
                // set their location manager as a target to an action here
                connectionUser.locationManager.delegate = self;
                
                BOOL newMarker = YES;
                for (int i = 0; i < self.markers.count; i++) {
                    User *markerUser = (User *)(self.markers[i]);
                    if (markerUser == connectionUser) {
                        newMarker = NO;
                    }
                }
                if (newMarker) {
                    [self placeFriendMarker:connectionUser];
                } else {
                    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(connectionUser.currentLocation.latitude, connectionUser.currentLocation.longitude);
                    [self updateFriendMarker:connectionUser.locationManager toLocation:coords];
                }
                
                if (![[self.markerData allKeys] containsObject:connectionUser]) {
                    [self doMarkerQueries:connectionUser];
                }
            }];
        }
    }];
    
    [ParseAPI getUsersInLocation:self.user.currentLocation withRadius:200 withBlock:^(NSArray *potentialConnections) {
        NSMutableArray *filteredPotentialConnections = [potentialConnections mutableCopy];
        [filteredPotentialConnections removeObject:self.user];
        for (User *potentialFriend in filteredPotentialConnections){
            potentialFriend.locationManager.delegate = self;
            if (![potentialFriend.invisibleFrom containsObject:self.user.objectId] && [potentialFriend.preferences[@"switch"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                BOOL newMarker = YES;
                for (int i = 0; i < self.markers.count; i++) {
                    User *markerUser = (User *)(self.markers[i]);
                    if (markerUser == potentialFriend) {
                        newMarker = NO;
                    }
                }
                
                if (newMarker) {
                    [self placeFriendMarker:potentialFriend];
                    if (![[self.markerData allKeys] containsObject:potentialFriend]) {
                        [self doMarkerQueries:potentialFriend];
                    }
                } else {
                    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(potentialFriend.currentLocation.latitude, potentialFriend.currentLocation.longitude);
                    [self updateFriendMarker:potentialFriend.locationManager toLocation:coords];
                    double distance = [self.user.currentLocation distanceInMilesTo:potentialFriend.currentLocation];
                    self.markerData[potentialFriend.objectId][2] = [NSString stringWithFormat:@"%f", distance];
                }
            }
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (manager == self.locationManager) {
        // the user moved
        CLLocationCoordinate2D coords = ((CLLocation *)[locations firstObject]).coordinate;
        [self.mapView animateToLocation:coords];
        
        [self.user refreshInBackgroundWithBlock:^(PFObject *refreshedUser, NSError *refreshedError) {
            self.user = (User *)refreshedUser;
            self.user.currentLocation = [PFGeoPoint geoPointWithLatitude:coords.latitude longitude:coords.longitude];
            [self.user saveInBackground];
            [self updateAllMarkers];
        }];
    } else {
        // one of the users potential connections moved
        CLLocationCoordinate2D coords = ((CLLocation *)[locations firstObject]).coordinate;
        [self updateFriendMarker:manager toLocation:coords];
    }
    
    // TEST CODE, DELETE LATER
    if (self.testMarker) {
        CLLocationCoordinate2D coords = ((CLLocation *)[locations firstObject]).coordinate;
        GMSMarker *marker = [GMSMarker markerWithPosition:coords];
        marker.map = self.mapView;
        marker.icon = [UIImage imageNamed:@"person"];
        marker.userData = nil;
        marker.infoWindowAnchor = CGPointMake(3, 0);
    }
}

-(void)mapView:(GMSMapView *)mapView
didTapInfoWindowOfMarker:(GMSMarker *)marker{
    
    // INTRODUCE A MODAL ASKING FOR CONFIRMATION
    User *friend = (User *)(marker.userData);
    if ([self.user.connections containsObject:friend.objectId]) {
        NSURL *url = [NSURL URLWithString:friend.url];
        [[UIApplication sharedApplication] openURL:url];
    } else if ([(NSNumber *)(friend.preferences[@"switch"]) isEqualToNumber:[NSNumber numberWithBool:NO]]) {
        [self displayCancelAlertControllerWithMessage:@"Not Available" andTitle:@"Sorry! This person has disabled incoming connections."];
    } else {
       
        [self displayConversationAlertControllerWithFriend:friend];
    }
}

- (void)updateMapAfterConnectionWith:(User *)friend {
    [self updateAllMarkers];
    [self.view setNeedsDisplay];
    [self.mapView setNeedsDisplay];
    [self startConversationWith:friend];
    
    for (GMSMarker *marker in self.markers) {
        User *markerUser = (User *)(marker.userData);
        if (markerUser == friend) {
            marker.map = nil;
            marker.icon = [UIImage imageNamed:@"grayPerson"];
            [self.mapView setNeedsDisplay];
        }
    }
}

- (void)displayConversationAlertControllerWithFriend:(User *)friend {

    DetailViewController *modalViewController = [[DetailViewController alloc] initWithSelf:self.user andFriend:friend andData:self.markerData[friend.objectId]];
    self.currentDVC = modalViewController;
    modalViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:modalViewController animated:YES completion:nil];
}

- (void)removeFromMap:(User *)friend {
    for (int i = 0; i < [self.markers count]; i+=1) {
        GMSMarker *marker = self.markers[i];
        User *markerUser = (User *)(marker.userData);
        if ([markerUser.objectId isEqualToString:friend.objectId]) {
            marker.map = nil;
            [self.markers removeObject:marker];
            [self.mapView setNeedsDisplay];
            return;
        }
    }
}

- (void)startConversationWith:(User *)friend {
    
    PFGeoPoint *friendLocation = friend.currentLocation;
    PFGeoPoint *myLocation = self.user.currentLocation;
    double averageLatitude = (friendLocation.latitude + myLocation.latitude)/2;
    double averageLongitude = (friendLocation.longitude + myLocation.longitude)/2;
    PFGeoPoint *averageLocation = [PFGeoPoint geoPointWithLatitude:averageLatitude longitude:averageLongitude];
    UserConnection *newConnection = [[UserConnection alloc] initWithInitialUser:self.user andAddedUser:friend inLocation:averageLocation];
    [newConnection saveInBackground];
    [self.user addConnectionToUser:friend.objectId];
    [self.user saveInBackground];
    [friend saveInBackground];
    [newConnection saveInBackground];
    ConnectedViewController *cvc = [[ConnectedViewController alloc] initWithOtherFBID:friend.FBID andName:friend.name andURL:(NSString *) friend.url];
    [self presentViewController:cvc animated:YES completion:nil];
    
    PFPush *push = [[PFPush alloc] init];
    NSString *channelName = [@"C" stringByAppendingString:friend.objectId];
    [push setChannel:channelName];
    NSString *notificationMessage = [self.user.name stringByAppendingString:@" has started a conversation with you!"];
    [push setMessage:notificationMessage];
    [push sendPushInBackground];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateAllMarkers];
    [self enableGestures];
}

- (void)doMarkerQueries:(User *)friend {
    self.markerData[friend.objectId] = [NSMutableArray array];
    self.markerData[friend.objectId][0] = @"0";
    self.markerData[friend.objectId][1] = @"0";
    self.markerData[friend.objectId][2] = @"0";
    self.markerData[friend.objectId][3] = [NSMutableArray array];
    self.markerData[friend.objectId][4] = [NSMutableArray array];

    FBSDKGraphRequest *mutualFriendsRequest = [GraphRequestAPI mutualFriendsRequest:friend];
    [mutualFriendsRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        NSString *stringValue = [result[@"context"][@"mutual_friends"][@"summary"][@"total_count"] stringValue];
        self.markerData[friend.objectId][0] = stringValue;
        for (NSDictionary *dict in result[@"context"][@"mutual_friends"][@"data"]){
            [self.markerData[friend.objectId][4] addObject:dict];
        }
        [self.currentDVC reloadFriendsCarousel];
    }];

    FBSDKGraphRequest *mutualLikesRequest = [GraphRequestAPI mutualLikesRequest:friend];
    [mutualLikesRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        NSString *stringValue = [result[@"context"][@"mutual_likes"][@"summary"][@"total_count"] stringValue];
        self.markerData[friend.objectId][1] = stringValue;
        for (NSDictionary *dict in result[@"context"][@"mutual_likes"][@"data"]){
            [self.markerData[friend.objectId][3] addObject:dict];
        }
        [self.currentDVC reloadLikesCarousel];
    }];
    
    PFGeoPoint *myCurrentLocation = [PFGeoPoint geoPointWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
    self.user.currentLocation = myCurrentLocation;
    [self.user saveInBackground];
    double distance = [myCurrentLocation distanceInMilesTo:friend.currentLocation];
    self.markerData[friend.objectId][2] = [NSString stringWithFormat:@"%.1f", distance];
}


- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    // TESTING CODE, DELETE LATER
    if (self.testMarker) {
        MapInfoWindowViewController *vc =[[MapInfoWindowViewController alloc] init];
        vc.testing = YES;
        return vc.view;
    }
    User *friend = (User *)(marker.userData);
    
    if ([self.user.connections containsObject:friend.objectId]) {
        // they've already connected, show a connected viewcontroller
        ConnectedMapInfoWindowViewController *cvc = [[ConnectedMapInfoWindowViewController alloc] initWithFriend:friend];
        marker.infoWindowAnchor = CGPointMake(3, 0);
        return cvc.view;
    } else {
        MapInfoWindowViewController *vc = [[MapInfoWindowViewController alloc] initWithArray:self.markerData[friend.objectId]];
        marker.infoWindowAnchor = CGPointMake(3, 0);
        return vc.view;
    }
}

- (void)displayCancelAlertControllerWithMessage:(NSString *)message andTitle:(NSString *)title {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [ac dismissViewControllerAnimated:YES completion:nil];
    }];
    [ac addAction:cancelAction];
    [self presentViewController:ac animated:YES completion:nil];
}

-(void) shuffle{
    // PICK THE BEST PERSON
    NSArray *topMatches = self.user.topConnections;
    if (topMatches.count == 0 || topMatches == nil) {
        [self displayCancelAlertControllerWithMessage:@"No Matches" andTitle:@"Sorry! No potential friends could be found near you."];
    } else {
        NSString *bestUserID = topMatches[0];
        NSInteger index = 1;
        while ([self.user.connections containsObject:bestUserID] && index < topMatches.count) {
            bestUserID = topMatches[index];
            index += 1;
        }
        
        if ([self.user.connections containsObject:bestUserID]) {
            // no new people could be found
            [self displayCancelAlertControllerWithMessage:@"No Matches" andTitle:@"Sorry! No new potential friends could be found near you."];
        } else {
            [ParseAPI getUser:bestUserID withBlock:^(User *friend) {
                [self displayConversationAlertControllerWithFriend:friend];
            }];
        }
    }
}

-(void) help{
    OverlayViewController *ovc = [[OverlayViewController alloc] init];
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:ovc animated:NO completion:nil];
}

@end
