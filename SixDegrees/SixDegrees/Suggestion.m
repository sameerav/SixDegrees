//
//  Suggestion.m
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/16/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "Suggestion.h"
#import "SuggestionsAPI.h"

@implementation Suggestion
@dynamic location;
@dynamic info;
@dynamic name;
@dynamic rating;
@dynamic pictureURL;


+ (NSString *)parseClassName {
    return @"Suggestion";
}

+ (void)registerSubclass {
    [super registerSubclass];
}

- (instancetype)initWithLocation:(PFGeoPoint *)location andDescription:(NSString *)description andName:(NSString *)name andRating:(NSNumber *)rating andPictureURL:(NSString *)pictureURL {
    self = [super init];
    if (self) {
        self.location = location;
        self.info = description;
        self.name = name;
        self.rating = rating;
        self.pictureURL = pictureURL;
    }
    return self;
}

@end
