// Copyright 2004-present Facebook. All Rights Reserved.

#import "AppDelegate.h"

#import <Parse/Parse.h>
#import "ParseAPI.h"

#import "User.h"
#import "SixDegreesLoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "HomeViewController.h"
#import "SWRevealViewController.h"
#import "MapViewController.h"
#import "MenuViewController.h"

#import "TestConversationsVIewController.h"
#import "UserConnection.h"
#import "ParseAPI.h"
#import <Parse/Parse.h>
#import "Suggestion.h"
#import "SuggestionsAPI.h"

@import GoogleMaps;

@interface AppDelegate ()
@property CLLocationManager *locationManager;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if ([[launchOptions allKeys] containsObject:UIApplicationLaunchOptionsLocationKey]) {
        
    }
    // [self testSuggestions];

    // set up Parse
    [self setUpParse:application launchOptions: launchOptions];
    // set up Google Maps
    [GMSServices provideAPIKey:@"AIzaSyDoZNgp8IRsJb4Pyb2r7kSWqWieSMprbgk"];
    
    // constant location tracking
    [self handleLocationTracking:launchOptions];
    
    //loads FB login
        [FBSDKLoginButton class];
    
    //sets our home page as the root view controller
    MenuViewController *menu = [[MenuViewController alloc] init];
    HomeViewController *hvc = [[HomeViewController alloc] init];
    SWRevealViewController *rvc = [[SWRevealViewController alloc] initWithRearViewController:menu frontViewController:hvc];
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = rvc;
    [self.window makeKeyAndVisible];
    
    //Keep user logged in even after closing app
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

// COMMENT THIS OUT AFTER TESTED
- (void)handleLocationTracking:(NSDictionary *)launchOptions {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 20;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocationCoordinate2D coords = ((CLLocation *)[locations firstObject]).coordinate;
    
    // unarchive user
//    NSData *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
//    NSString *userIDString = [NSKeyedUnarchiver unarchiveObjectWithData:userID];
//    
//    [ParseAPI getUser:userIDString withBlock:^(User *me) {
//        me.currentLocation = [PFGeoPoint geoPointWithLatitude:coords.latitude longitude:coords.longitude];
//        [me saveInBackground];
//    }];

}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    //used to make FB requests
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)setUpParse:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
    // Register all custom PFObject subclasses
    [User registerSubclass];
    [UserConnection registerSubclass];
    [Suggestion registerSubclass];

    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];

    // Initialize Parse.
    [Parse setApplicationId:@"BRGDrlWQuSmSkhXmc3f7wTCuKogWxonkKMKBU9lC"
                  clientKey:@"cIpsAkwwQtfw7IyckUHEePi09PsTlku3OMpw7MA9"];

    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //Logging app activations
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
