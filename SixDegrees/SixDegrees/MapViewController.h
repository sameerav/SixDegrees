//
//  MapViewController.h
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/6/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@class CLLocationManager;
@class User;
@class HomeViewController;

@import GoogleMaps;

@interface MapViewController : UIViewController <GMSMapViewDelegate, CLLocationManagerDelegate>
@property CLLocationManager *locationManager;
@property (strong, nonatomic) GMSMapView *mapView;
- (void)updateAllMarkers;
- (void)disableGestures;
- (void)enableGestures;
- (void)removeFromMap:(User *)friend;
- (void)updateMapAfterConnectionWith:(User *)friend;
@property (weak, nonatomic) HomeViewController *hvc;
@end
