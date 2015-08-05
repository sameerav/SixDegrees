//
//  DetailViewController.m
//  Pods
//
//  Created by Daniel Moreno on 7/27/15.
//
//

#import "DetailViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "User.h"
#import "MapViewController.h"
#import "HomeViewController.h"
#import "ParseAPI.h"

@interface DetailViewController ()
@property (strong, nonatomic) IBOutlet iCarousel *friendsCarousel;

@property (strong, nonatomic) IBOutlet iCarousel *likesCarousel;
@property (strong, nonatomic) IBOutlet UIView *myVIew;
@property (strong, nonatomic) IBOutlet UIControl *dimmer;
@property (strong, nonatomic) User *me;
@property (strong, nonatomic) User *friend;
@property (strong, nonatomic) NSArray *data;
@end

@implementation DetailViewController
@synthesize friendsCarousel;
@synthesize likesCarousel;

- (instancetype)initWithSelf:(User *)me andFriend:(User *)friend andData:(NSArray *)data {
    self = [super init];
    if (self) {
        self.me = me;
        self.friend = friend;
        self.data = data;
    }
    return self;
}

- (IBAction)tap:(id)sender {
    [self cancel:sender];
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view{
    
    if (carousel == self.friendsCarousel) {
        UIView *carouselView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 56, 56)];
        FBSDKProfilePictureView *pp = [[FBSDKProfilePictureView alloc]initWithFrame:CGRectMake(6, 0, 44, 44)];
        pp.profileID = self.data[4][index][@"id"];
        pp.layer.cornerRadius = pp.frame.size.width / 2;
        pp.layer.borderWidth = 0.8;
        pp.layer.borderColor = [UIColor whiteColor].CGColor;
        pp.clipsToBounds = YES;
        [carouselView addSubview:pp];
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 48, 56, 10)];
        name.numberOfLines = 2;
        name.text = @"";
        name.font = [UIFont fontWithName:@"Avenir Next" size:10];
        name.textColor = [UIColor whiteColor];
        name.textAlignment = NSTextAlignmentCenter;
        [carouselView addSubview:name];
        
        NSString *firstName = [self.data[4][index][@"name"] componentsSeparatedByString:@" "][0];
        name.text = firstName;
        return carouselView;
    } else if (carousel == self.likesCarousel) {
        UIView *carouselView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 56, 72)];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(6, 0, 44, 44)];
        iv.image = [[UIImage alloc] init];
        iv.layer.cornerRadius = iv.frame.size.width / 2;
        iv.layer.borderWidth = 0.8;
        iv.layer.borderColor = [UIColor whiteColor].CGColor;
        iv.clipsToBounds = YES;
        [carouselView addSubview:iv];
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 56, 38)];
        name.text = @"";
        name.font = [UIFont fontWithName:@"Avenir Next" size:10];
        name.textColor = [UIColor whiteColor];
        name.numberOfLines = 2;
        name.lineBreakMode = UILineBreakModeTailTruncation;
        name.textAlignment = NSTextAlignmentCenter;
        [carouselView addSubview:name];
        
        NSDictionary *params = @{@"fields": @"picture.type(large)"};
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:[@"/" stringByAppendingString:self.data[3][index][@"id"]] parameters:params HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            // handle
            NSString *pictureURL = result[@"picture"][@"data"][@"url"];
            NSURL *url = [[NSURL alloc] initWithString:pictureURL];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                UIImage *image = [[UIImage alloc] initWithData:data];
                iv.image = image;
                [carouselView setNeedsDisplay];
            }];

            name.text = self.data[3][index][@"name"];
            [carouselView setNeedsDisplay];
        }];
        return carouselView;
    }
    return nil;
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    NSInteger count = 0;
    if (carousel == self.friendsCarousel) {
        count = [self.data[4] count];
    } else if (carousel == self.likesCarousel) {
        count = [self.data[3] count];
    }
    
    if (count ==  0) {
        if (carousel == self.friendsCarousel) {
            self.noMutualFriendsLabel.hidden = NO;
            [self.view setNeedsDisplay];
        } else if (carousel == self.likesCarousel) {
            self.noMutualInterestsLabel.hidden = NO;
            [self.view setNeedsDisplay];
        }
    } else {
        if (carousel == self.friendsCarousel) {
            self.noMutualFriendsLabel.hidden = YES;
            [self.view setNeedsDisplay];
        } else if (carousel == self.likesCarousel) {
            self.noMutualInterestsLabel.hidden = YES;
            [self.view setNeedsDisplay];
        }
    }
    return count;
}

- (void) reloadFriendsCarousel {
    [self.friendsCarousel reloadData];
}

- (void) reloadLikesCarousel {
    [self.likesCarousel reloadData];
}

-(void)carouselDidEndScrollingAnimation:(iCarousel *)carousel{
    if (carousel.currentItemIndex < 2 && carousel.numberOfItems > 4) {
        [carousel scrollToItemAtIndex:2 animated:YES];
    }else if(carousel.currentItemIndex > carousel.numberOfItems -3){
        [carousel scrollToItemAtIndex:carousel.numberOfItems-3 animated:YES];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.presentingViewController.view.alpha =0.5;
    self.myVIew.layer.cornerRadius = 10;
    self.myVIew.clipsToBounds = YES;
    self.friendsCarousel.currentItemIndex = 2;
    self.likesCarousel.currentItemIndex = 2;
    [self.friendsCarousel reloadData];
    [self.likesCarousel reloadData];
}
- (IBAction)cancel:(id)sender {
    self.presentingViewController.view.alpha =1.0;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)connect:(id)sender {
    self.presentingViewController.view.alpha =1.0;
    HomeViewController *hvc = (HomeViewController *)(self.presentingViewController);
    MapViewController *mvc = hvc.mvc;
    [mvc updateMapAfterConnectionWith:self.friend];
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
