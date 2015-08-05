//
//  SixDegreesLoginViewController.m
//  SixDegrees
//
//  Created by Daniel Moreno on 7/7/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "SixDegreesLoginViewController.h"
#import "SixDegreesLoginChildViewController.h"
#import "ParseAPI.h"
#import "User.h"
#import "HomeViewController.h"
#import "MapViewController.h"
#import "GraphRequestAPI.h"
#import "SWRevealViewController.h"
#import "ConversationsViewController.h"
#import "WebViewController.h"
#import "BirthdayViewController.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "LoginHelper.h"
#import <ClusterPrePermissions/ClusterPrePermissions.h>


@interface SixDegreesLoginViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *background;
@end
@implementation SixDegreesLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //sets initial background
    self.background.image = [UIImage imageNamed:@"bench.jpg"];
    
    //Permisions requested to generate access token
    
    ClusterPrePermissions *permissions = [ClusterPrePermissions sharedPermissions];
    [permissions showPhotoPermissionsWithTitle:@"Access your Facebook friends and likes?"
                                       message:@"SixDegrees would like to safely access this information in order to calculate your top connections."
                               denyButtonTitle:@"Not Now"
                              grantButtonTitle:@"Give Access"
                             completionHandler:^(BOOL hasPermission,
                                                 ClusterDialogResult userDialogResult,
                                                 ClusterDialogResult systemDialogResult) {
                                 if (hasPermission) {
                                     self.loginButton.readPermissions = @[@"public_profile", @"user_friends", @"user_likes", @"user_photos"];
                                 } else {
                                     // Handle access not being available
                                 }
                             }];
    self.loginButton.delegate = self;
    
    //loads and initializes page controller for tutorial
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.dataSource = self;
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width , self.view.bounds.size.height - 47);
    [[self.pageController view] setFrame:frame];
    
    SixDegreesLoginChildViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.pageController];
    [[self view]insertSubview:[self.pageController view] belowSubview:[self view]];
    [self.pageController didMoveToParentViewController:self];
    
}

//+ (NSArray *)AppSecretProof:(NSString *)accessToken appSecret:(NSString *)appSecret
//{
//    NSString *hashInput = [NSString stringWithFormat:@"%@%@", accessToken, appSecret];
//    const char* str = [hashInput UTF8String];
//    unsigned char result[CC_SHA256_DIGEST_LENGTH];
//    CC_SHA256(str, strlen(str), result);
//    
//    NSMutableString *hashedString = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
//    for (int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++) {
//        [hashedString appendFormat:@"%02x",result[i]];
//    }
//    NSLog(@"%@", hashedString);
//    return hashedString;
//}

+ (NSString *)AppSecretProof:(NSString *)accessToken appSecret:(NSString *)appSecret
{
    if (accessToken) {
        const char *cKey  = [appSecret cStringUsingEncoding:NSASCIIStringEncoding];
        const char *cData = [accessToken cStringUsingEncoding:NSASCIIStringEncoding];
        
        unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
        
        CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
        
        NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
        
        return [[HMAC.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    } else {
        return @"";
    }
}




- (SixDegreesLoginChildViewController *)viewControllerAtIndex:(NSUInteger)index {
    //returns correct viewcontroller from the tutorial
    SixDegreesLoginChildViewController *childViewController = [[SixDegreesLoginChildViewController alloc] initWithNibName:@"SixDegreesLoginChildViewController" bundle:nil];
    childViewController.index = index;
    return childViewController;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [(SixDegreesLoginChildViewController *)viewController index];
    if (index == 0){
        self.background.image = [UIImage imageNamed:@"bench.jpg"];
        return nil;
    }
    if (index == 1){
        self.background.image = [UIImage imageNamed:@"pool.jpg"];
    }else if (index == 2) {
        self.background.image = [UIImage imageNamed:@"chill.jpg"];
    }else if (index ==3){
        self.background.image = [UIImage imageNamed:@"coffee.jpg"];
    }
        
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [(SixDegreesLoginChildViewController *)viewController index];
    if (index == 0){
        self.background.image = [UIImage imageNamed:@"bench.jpg"];
    }
    if (index == 1){
        self.background.image = [UIImage imageNamed:@"pool.jpg"];
    }else if (index == 2) {
        self.background.image = [UIImage imageNamed:@"chill.jpg"];
    }else if (index ==3){
        self.background.image = [UIImage imageNamed:@"coffee.jpg"];
        return nil;
    }

    index++;
    
    return [self viewControllerAtIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 4;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    PFGeoPoint *location = [PFGeoPoint geoPointWithLocation:self.hvc.mvc.locationManager.location];
    [LoginHelper loginAfterManualFacebookLoginWithLocation:location andView:self];
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    //TODO: Implement Logout
}

@end
