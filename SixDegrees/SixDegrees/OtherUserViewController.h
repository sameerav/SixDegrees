//
//  OtherUserViewController.h
//  
//
//  Created by Daniel Moreno on 7/16/15.
//
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "iCarousel.h"
@class UserConnection;



@interface OtherUserViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>

@property (strong, nonatomic) NSMutableArray *suggestionsArray;
@property (strong, nonatomic) NSMutableArray *descriptions;
-(instancetype)initWithFBID:(NSString *)fbid andConnection:(UserConnection *)connection andURL:(NSString *) url andSuggestions:(NSMutableArray *)sugs;
-(void) setPictureForRating:(NSNumber*)rating;
-(void)findRestaurants:(NSString *)fbid andConnection:(UserConnection *)connection andURL:(NSString *) url andSuggestions:(NSMutableArray *)sugs;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UserConnection *connection;
@end
