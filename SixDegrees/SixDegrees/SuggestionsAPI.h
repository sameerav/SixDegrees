//
//  SuggestionsAPI.h
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/15/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
@class Suggestion;

@interface SuggestionsAPI : NSObject
+ (enum timeOfDay)getTimeOfDay;
+ (void)queryForSuggestionWithLocation:(PFGeoPoint *)location withOffset: (NSInteger) offset withBlock:(void (^)(PFGeoPoint *location, NSString *description, NSString *name, NSNumber *rating, NSString *pictureURL))completion;

+ (UIImage *)getPicture:(Suggestion *)suggestion;

+ (void)getPictureAsynchronously:(Suggestion *)suggestion withCompletionHandler:(void (^)(UIImage *))completion;
@end
