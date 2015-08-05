//
//  MenuViewController.m
//  SixDegrees
//
//  Created by Daniel Moreno on 7/8/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "MenuViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SixDegreesLoginViewController.h"
#import "SWRevealViewController.h"
#import "ProfileViewController.h"
#import "HomeViewController.h"
#import "SettingsViewController.h"
#import "ParseAPI.h"
#import "ConversationsViewController.h"
#import "AboutUsViewController.h"
#import "User.h"
#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *profilePicture;
@property (weak, nonatomic) IBOutlet UIButton *meetButton;
@property (strong, nonatomic) HomeViewController *hvc;
@property (strong, nonatomic) SettingsViewController *svc;
@property (strong, nonatomic) ProfileViewController *pvc;
@end

@implementation MenuViewController

- (void)setUpProfilePicture {
    self.profilePicture.profileID = @"me";
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
    self.profilePicture.clipsToBounds = YES;
    self.profileButton.layer.cornerRadius = 10.0f;
}

- (void)setUpButtons {
    self.meetButton.layer.cornerRadius = 10.0f;
    self.settingsButton.layer.cornerRadius = 10.0f;
    self.aboutButton.layer.cornerRadius = 10.0f;
}

- (void)setUpViewControllers {
    HomeViewController *hvc = [[HomeViewController alloc] init];
    SettingsViewController *svc = [[SettingsViewController alloc] init];
    ProfileViewController *pvc = [[ProfileViewController alloc] init];
    
    self.hvc = hvc;
    self.svc = svc;
    self.pvc = pvc;
    
    [ParseAPI doBlockForCurrentUser:^(User *me) {
        [hvc.cvc addUser:me];
        svc.currentUser = me;
    }];
}

- (void)startCachingProfileView {
    NSDictionary *params = @{@"fields": @"cover,name,likes,friends,hometown"};
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:params HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        NSDictionary *cover = [result objectForKey:@"cover"];
        NSArray *friends = [result objectForKey:@"friends"][@"data"];
        for (NSDictionary *dict in friends) {
            UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
            FBSDKProfilePictureView *pfview = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
            pfview.profileID = dict[@"id"];
            [myView addSubview:pfview];
            NSString *name = [NSString stringWithFormat:@" %@",dict[@"name"]];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, 250, 30)];
            UIColor *salmon =[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
            label.backgroundColor = salmon;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.numberOfLines = 2;
            label.lineBreakMode = UILineBreakModeWordWrap;
            label.font = [UIFont fontWithName:@"Avenir Next" size:20];
            label.text = name;
            [myView addSubview:label];
            [self.pvc.friendProfilePictures addObject:myView];
        }
        NSDictionary *hometown = [result objectForKey:@"hometown"];
        NSString *homeTown = [hometown objectForKey:@"name"];
        NSString *name = [result objectForKey:@"name"];
        NSString *source = [cover objectForKey:@"source"];
        
        NSURL *imageURL = [NSURL URLWithString:source];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [[UIImage alloc] initWithData:data];
                self.pvc.cache[@"cover"] = image;
                [self.pvc setValues];
            }
        }];
        
        self.pvc.cache[@"name"] = name;
        [self.pvc setValues];
        
        [ParseAPI doBlockForCurrentUser:^(User *currentUser) {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:currentUser.currentLocation.latitude longitude:currentUser.currentLocation.longitude];
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                NSString *locality = placemark.locality;
                NSString *administrativeArea = placemark.administrativeArea;
                if (locality != nil && administrativeArea != nil) {
                    self.pvc.cache[@"hometown"] = [[locality stringByAppendingString:@", "] stringByAppendingString:administrativeArea];
                } else if (administrativeArea) {
                    self.pvc.cache[@"hometown"] = administrativeArea;
                } else if (locality) {
                    self.pvc.cache[@"hometown"] = locality;
                } else if (homeTown) {
                    self.pvc.cache[@"hometown"] = homeTown;
                } else {
                    self.pvc.cache[@"hometown"] = @"Earth";
                }
                [self.pvc setValues];
            }];
        }];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpProfilePicture];
    [self setUpButtons];
    [self setUpViewControllers];
    [self startCachingProfileView];
}

- (void)viewWillAppear:(BOOL)animated{
    self.profilePicture.profileID = @"me";
}


- (IBAction)profileButton:(id)sender {
    if (self.revealViewController) {
        if (self.revealViewController.frontViewController.class != [ProfileViewController class]){
            [self.revealViewController setFrontViewController:self.pvc animated:YES];
        }
        [self.revealViewController revealToggle:self];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        [self.revealViewController.frontViewController.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (IBAction)sixDegreesButton:(id)sender {
    if (self.revealViewController.frontViewController.class != [HomeViewController class]){
        [self.revealViewController setFrontViewController:self.hvc animated:YES];
        self.hvc.mvc.view.userInteractionEnabled = YES;
        self.hvc.mvc.mapView.userInteractionEnabled = YES;
        self.hvc.menuIsOpen = NO;
    } else {
        HomeViewController *hvc = (HomeViewController *)(self.revealViewController.frontViewController);
        hvc.mvc.view.userInteractionEnabled = YES;
        hvc.mvc.mapView.userInteractionEnabled = YES;
        hvc.menuIsOpen = NO;
    }
    [self.revealViewController revealToggle:self];
}
- (IBAction)settingsButton:(id)sender {
    if (self.revealViewController.frontViewController.class != [SettingsViewController class]){
        [self.revealViewController setFrontViewController:self.svc animated:YES];
    }
    [self.revealViewController revealToggle:self];
}

- (IBAction)aboutUsButton:(id)sender {
    AboutUsViewController *avc = [[AboutUsViewController alloc] init];
    if (self.revealViewController.frontViewController.class != [AboutUsViewController class]){
        [self.revealViewController setFrontViewController:avc animated:YES];
    }
    [self.revealViewController revealToggle:self];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.revealViewController.frontViewController.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}


@end
