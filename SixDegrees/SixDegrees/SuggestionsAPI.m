//
//  SuggestionsAPI.m
//  SixDegrees
//
//  Created by Sameera Vemulapalli on 7/15/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "SuggestionsAPI.h"
#import "Suggestion.h"
#import "NSURLRequest+OAuth.h"

static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search";
static NSString * const kBusinessPath      = @"/v2/business/";
static NSString * const kSearchLimit       = @"10";

@implementation SuggestionsAPI

+ (UIImage *)getPicture:(Suggestion *)suggestion {
    [suggestion fetchIfNeeded];
    NSString *pictureURLstring = suggestion.pictureURL;
    NSURL *url = [NSURL URLWithString:pictureURLstring];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

+ (void)getPictureAsynchronously:(Suggestion *)suggestion withCompletionHandler:(void (^)(UIImage *))completion {
    
    [suggestion fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        Suggestion *sug = (Suggestion *)object;
        NSURL *url = [NSURL URLWithString:sug.pictureURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                completion(image);
            }
        }];
    }];
}

+ (NSInteger)getLocalTimeHour {
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:tz];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    NSInteger hour = [dateComponents hour];
    NSInteger *modifiedHour = (hour%24)+4;
    if (modifiedHour > 23) {
        modifiedHour = modifiedHour - 24;
    }
    return modifiedHour;
}

+ (enum timeOfDay)getTimeOfDayFromHour:(NSInteger)hour {
    
    if (5 <= hour && hour < 11) {
        return morning;
    } else if (11 <= hour && hour < 14){
        return noon;
    } else if (14 <= hour && hour < 17) {
        return afternoon;
    } else if (17 <= hour && hour < 22) {
        return evening;
    } else {
        return night;
    }
}

+ (enum timeOfDay)getTimeOfDay {
    NSInteger hour = [self getLocalTimeHour];
    return [self getTimeOfDayFromHour:hour];
}

+ (NSString *)getLocationString:(PFGeoPoint *)location {
    NSString *locationString = [[[@"" stringByAppendingString:[NSString stringWithFormat:@"%f", location.latitude]] stringByAppendingString:@","] stringByAppendingString:[NSString stringWithFormat:@"%f", location.longitude]];
    return locationString;
}

+ (NSString *)getTermString{
    enum timeOfDay time = [self getTimeOfDay];
    NSString *termString = @"";
    if (time == morning) {
        termString = @"breakfast";
    } else if (time == noon) {
        termString = @"lunch";
    } else if (time == afternoon) {
        termString = @"snacks";
    } else if (time == evening) {
        termString = @"dinner";
    } else {
        termString = @"bar";
    }
    return termString;
}

+ (NSURLRequest *)searchRequestWithTerm:(NSString *)term location:(NSString *)location offset:(NSInteger)offset {
    NSDictionary *params = @{
                             @"term": term,
                             @"ll": location,
                             @"limit": kSearchLimit,
                             @"offset": [NSString stringWithFormat:@"%ld", (long)offset]
                             };
    
    return [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params];
}

+ (NSString *)editYelpURL:(NSString *)originalURL {
    return [originalURL stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"l.jpg"];
}

+ (void)queryForSuggestionWithLocation:(PFGeoPoint *)location withOffset:(NSInteger)offset withBlock:(void (^)(PFGeoPoint *location, NSString *description, NSString *name, NSNumber *rating, NSString *pictureURL))completion {
    NSString *termString = [self getTermString];
    NSString *locationString = [self getLocationString:location];
    NSURLRequest *searchRequest = [self searchRequestWithTerm:termString location:locationString offset:offset];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:searchRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (!error && httpResponse.statusCode == 200) {
            
            NSArray *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error][@"businesses"];
            // handle
            for (NSDictionary *potentialSuggestion in searchResponseJSON) {
                double latitude = [potentialSuggestion[@"location"][@"coordinate"][@"latitude"] doubleValue];
                double longitude = [potentialSuggestion[@"location"][@"coordinate"][@"longitude"] doubleValue];
                PFGeoPoint *location = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
                
                NSArray *categories = potentialSuggestion[@"categories"];
                NSString *description = @"";
                for (NSArray *category in categories) {
                    if (category.count > 0) {
                        description = [[description stringByAppendingString:@", "] stringByAppendingString:category[0]];
                    }
                }
                description = [description substringFromIndex:2];
                
                NSString *name = potentialSuggestion[@"name"];
                NSNumber *rating = [NSNumber numberWithDouble:(double)[potentialSuggestion[@"rating"] doubleValue]];
                
                NSString *imageURL = potentialSuggestion[@"image_url"];
                NSString *originalURL = [self editYelpURL:imageURL];
                
                if (completion) {
                    completion(location, description, name, rating, originalURL);
                }
            }
        }
    }] resume];
}

@end
