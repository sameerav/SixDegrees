//
//  OtherUserViewController.m
//  
//
//  Created by Daniel Moreno on 7/16/15.
//
//

#import "OtherUserViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ParseAPI.h"
#import "iCarousel.h"

#import <MapKit/MapKit.h>


#import "UserConnection.h"
#import "SuggestionsAPI.h"
#import <Parse/Parse.h>
#import "Suggestion.h"
#import "PrivacyViewController.h"

@interface OtherUserViewController ()
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UIImageView *coverPicture;
@property (nonatomic) IBOutlet FBSDKProfilePictureView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *hometownLabel;
@property (strong, nonatomic) NSString* fbid;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) IBOutlet UILabel *suggestionsLabel;
@property (strong, nonatomic) IBOutlet UILabel *restaurantName;
@property (strong, nonatomic) IBOutlet UILabel *descr;
@property (strong, nonatomic) IBOutlet UIImageView *rating;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet iCarousel *carousel;
@property (nonatomic) BOOL wrap;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *sugSpinner;
@property (nonatomic, strong) NSMutableArray *pictures;

@property (assign) int offset;
@end


@implementation OtherUserViewController
- (IBAction)pressedDoneButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)messengerTapped:(id)sender {
    NSURL *url = [NSURL URLWithString:self.url];
    [ [UIApplication sharedApplication] openURL:url];
}

-(instancetype)initWithFBID:(NSString *)fbid andConnection:(UserConnection *)connection andURL:(NSString *) url andSuggestions:(NSMutableArray *)sugs{
    self = [super init];
    if (self){
        self.fbid = fbid;
        self.wrap = NO;
        self.url = url;
        self.connection = connection;
        self.offset = 0;
        if(!sugs){
            self.suggestionsArray = connection.suggestions;
        }else{
            self.suggestionsArray = sugs;
        }
        
        self.pictures = [NSMutableArray array];
        for (int i = 0; i < self.suggestionsArray.count; i++) {
            
            self.pictures[i] = [NSNull null];
            [self.suggestionsArray[i] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                Suggestion *sug = (Suggestion *)object;
                self.suggestionsArray[i] = sug;
                [SuggestionsAPI getPictureAsynchronously:sug withCompletionHandler:^(UIImage *image) {
                    self.pictures[i] = image;
                    [self.carousel reloadData];
                }];
            }];
        }
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    Suggestion *current = self.suggestionsArray[0];
    [self setUpCurrentSuggestion:current];
    [self setUpMapView];
    [self setUpUserInformation];
    self.carousel.perspective = iCarouselTypeLinear;
    self.carousel.currentItemIndex = 0;
    self.carousel.pagingEnabled = NO;
    [self.view setNeedsDisplay];
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return (unsigned long)[self.pictures count];
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    return 7;
}

- (NSInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    NSUInteger toReturn = (long) 0;
    return toReturn;
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    //wrap all carousels
    return YES;
}

-(CGFloat) carouselItemWidth:(iCarousel *)carousel{
    return 140;
}

-(void)setPictureForRating:(NSNumber*)rating{
    if ([rating isEqualToNumber: [[NSNumber alloc] initWithFloat:0.0f]]) {
        self.rating.image = [UIImage imageNamed:@"ZeroStars"];
    }else if([rating isEqualToNumber: [[NSNumber alloc] initWithFloat:0.5f]]){
        self.rating.image = [UIImage imageNamed:@"ZeroHalf"];
    }else if([rating isEqualToNumber:[[NSNumber alloc] initWithFloat:1.0f]]){
        self.rating.image = [UIImage imageNamed:@"OneStars"];
    }else if([rating isEqualToNumber: [[NSNumber alloc] initWithFloat:1.5f]]){
        self.rating.image = [UIImage imageNamed:@"OneHalfStars"];
    }else if([rating isEqualToNumber: [[NSNumber alloc] initWithFloat:2.0f]]){
        self.rating.image = [UIImage imageNamed:@"TwoStars"];
    }else if([rating isEqualToNumber: [[NSNumber alloc] initWithFloat:2.5f]]){
        self.rating.image = [UIImage imageNamed:@"TwoHalfStars"];
    }else if([rating isEqualToNumber: [[NSNumber alloc] initWithFloat:3.0f]]){
        self.rating.image = [UIImage imageNamed:@"ThreeStars"];
    }else if([rating isEqualToNumber: [[NSNumber alloc] initWithFloat:3.5f]]){
        self.rating.image = [UIImage imageNamed:@"ThreeHalfStars"];
    }else if([rating isEqualToNumber: [[NSNumber alloc] initWithFloat:4.0f]]){
        self.rating.image = [UIImage imageNamed:@"FourStars"];
    }else if([rating isEqualToNumber: [[NSNumber alloc] initWithFloat:4.5f]]){
        self.rating.image = [UIImage imageNamed:@"FourHalfStars"];
    }else{
        self.rating.image = [UIImage imageNamed:@"FiveStars"];
    }
    
}
- (IBAction)privacySettings:(id)sender {
    PrivacyViewController *pvc = [[PrivacyViewController alloc]initWithFBID: self.fbid andName:(NSString*) self.userName.text];
    [self presentViewController:pvc animated:YES completion:nil];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.canShowCallout = NO;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [mapView deselectAnnotation:view.annotation animated:YES];
    MKPointAnnotation *annotation = view.annotation;
    CLLocationCoordinate2D coord = annotation.coordinate;
    NSString *ll = [NSString stringWithFormat: @"http://maps.apple.com/?q=%@&near=%f,%f",self.restaurantName.text, coord.latitude, coord.longitude];
    ll=[ll stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSURL *url = [NSURL URLWithString:ll];
    [[UIApplication sharedApplication ] openURL:url];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    //create a numbered view

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 135, 135)];
    imageView.contentMode = UIViewContentModeScaleToFill;
    if (self.pictures[index]==[NSNull null]) {
        return imageView;
    } else {
        imageView.image = self.pictures[index];
        return imageView;
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    for (MKPointAnnotation *annotation in self.mapView.annotations) {
        [self.mapView removeAnnotation:annotation];
        
    }
    Suggestion *current = self.suggestionsArray[carousel.currentItemIndex];
    [self setUpCurrentSuggestion:current];
    if (carousel.currentItemIndex == carousel.numberOfItems-7 || carousel.currentItemIndex == carousel.numberOfItems-1){
        self.offset +=10;
        [self queryForMore];
    }

    
}

- (void) queryForMore{
    NSLog(@"query");
    self.sugSpinner.hidden = NO;
    if(self.carousel.numberOfItems == 150){
        self.sugSpinner.hidden = YES;
    }
        [SuggestionsAPI queryForSuggestionWithLocation:self.connection.location withOffset: self.offset withBlock:^(PFGeoPoint *location, NSString *description, NSString *name, NSNumber *rating, NSString *pictureURL) {
    Suggestion *sug = [[Suggestion alloc] initWithLocation:location andDescription:description andName:name andRating:rating andPictureURL:pictureURL];
    [self.suggestionsArray addObject:sug];
    }];
    for (int i = (int)self.carousel.numberOfItems; i < self.suggestionsArray.count; i++) {
        
        self.pictures[i] = self.pictures[i-1];
        [self.suggestionsArray[i] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            Suggestion *sug = (Suggestion *)object;
            self.suggestionsArray[i] = sug;
            [SuggestionsAPI getPictureAsynchronously:sug withCompletionHandler:^(UIImage *image) {
                self.pictures[i] = image;
                [self.carousel reloadData];
                self.sugSpinner.hidden = YES;
            }];
        }];
    }
}

- (void)setUpCurrentSuggestion:(Suggestion *)current {
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(current.location.latitude, current.location.longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    MKCoordinateRegion region = {coord, span};
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coord];
    
    [self.mapView setRegion:region];
    [self.mapView addAnnotation:annotation];
    [self setPictureForRating:current.rating];
    self.restaurantName.text = current.name;
    self.descr.text = current.info;
}

- (void)setUpMapView {
    self.mapView.zoomEnabled = NO;
    self.mapView.pitchEnabled = NO;
    self.mapView.rotateEnabled = NO;
    self.mapView.showsUserLocation = NO;
    self.mapView.scrollEnabled = NO;
}

- (void)setUpUserInformation {
    self.profilePicture.profileID = self.fbid;
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
    self.profilePicture.layer.borderWidth = 1.0;
    self.profilePicture.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profilePicture.clipsToBounds = YES;
    if (self.connection) {
        self.userName.text = self.connection.addedUserName;
        NSArray *array = [self.connection.addedUserName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *firstName = array[0];
        self.suggestionsLabel.text = [@"Suggestions for you and " stringByAppendingString:firstName];
    }
    
    NSDictionary *params = @{@"fields": @"cover,name,hometown"};
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:self.fbid
                                  parameters:params
                                  HTTPMethod:@"GET"];
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        
        NSDictionary *cover = [result objectForKey:@"cover"];
        NSDictionary *hometown = [result objectForKey:@"hometown"];
        NSString *homeTown = [hometown objectForKey:@"name"];
        
        [ParseAPI getUserFromFBID:self.fbid withBlock:^(User *friend) {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:friend.currentLocation.latitude longitude:friend.currentLocation.longitude];
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                NSString *locality = placemark.locality;
                NSString *administrativeArea = placemark.administrativeArea;
                if (locality != nil && administrativeArea != nil) {
                    self.hometownLabel.text = [[locality stringByAppendingString:@", "] stringByAppendingString:administrativeArea];
                } else if (administrativeArea) {
                    self.hometownLabel.text = administrativeArea;
                } else if (locality) {
                    self.hometownLabel.text = locality;
                } else if (homeTown) {
                    self.hometownLabel.text = homeTown;
                } else {
                    self.hometownLabel.text = @"Earth";
                }
                self.spinner.hidden = YES;
                [self.view setNeedsDisplay];
            }];
        }];
        
        NSString *name = [result objectForKey:@"name"];
        NSString *source = [cover objectForKey:@"source"];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:source]]];
        self.coverPicture.image = image;
        self.userName.text = name;
        NSArray *array = [name componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *firstName = array[0];
        if (name) {
            self.suggestionsLabel.text = [@"Suggestions for you and " stringByAppendingString:firstName];
        }
    }];
    [self.view setNeedsDisplay];
}

- (IBAction)privacyButton:(id)sender {
}

@end
