//
//  DetailViewController.h
//  Pods
//
//  Created by Daniel Moreno on 7/27/15.
//
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
@class User;

@interface DetailViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>
- (instancetype)initWithSelf:(User *)me andFriend:(User *)friend andData:(NSArray *)data;
- (void) reloadLikesCarousel;
- (void) reloadFriendsCarousel;

@property (weak, nonatomic) IBOutlet UILabel *noMutualFriendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *noMutualInterestsLabel;

@end
