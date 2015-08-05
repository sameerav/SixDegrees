//
//  Suggestion.h
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/16/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <Parse/Parse.h>

enum timeOfDay
{
    morning, // == 0 (by default)
    noon, // == 1 (incremented by 1 from previous)
    afternoon, // == 2
    evening, // == 3
    night // == 4
};

@interface Suggestion : PFObject <PFSubclassing>
@property (strong, nonatomic) PFGeoPoint *location;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *rating;
@property (strong, nonatomic) NSString *pictureURL;

- (instancetype)initWithLocation:(PFGeoPoint *)location andDescription:(NSString *)description andName:(NSString *)name andRating:(NSNumber *)rating andPictureURL:(NSString *)pictureURL;
@end
