//
//  Magazines.m
//  negotiator
//
//  Created by Alexandru Chis on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Magazines.h"

@implementation Magazines

@synthesize name            = _name;
@synthesize photoPerson     = _photoPerson;
@synthesize address1        = _address1;
@synthesize address2        = _address2;
@synthesize state           = _state;
@synthesize suburb          = _suburb;
@synthesize postcode        = _postcode;
@synthesize phone           = _phone;
@synthesize thumbImageURL   = _thumbImageURL;
@synthesize detailImageURL  = _detailImageURL;

@synthesize lat             = _lat;
@synthesize lon             = _lon;
@synthesize distance        = _distance;

@synthesize imageLoaded     = _imageLoaded;
@synthesize image           = _image;

@synthesize coordinate      = _coordinate;


- (id)initWithMagazineInfo:(NSDictionary *)info {
    self = [super init];
    if (!self) return nil;
    
    self.name           = [info objectForKey:@"name"];
    self.photoPerson    = [info objectForKey:@"photo_person"];
    self.address1       = [info objectForKey:@"address1"];
    self.address2       = [info objectForKey:@"address2"];
    self.state          = [info objectForKey:@"state"];
    self.suburb         = [info objectForKey:@"suburb"];
    self.postcode       = [info objectForKey:@"postcode"];
    self.phone          = [info objectForKey:@"phone"];
    self.thumbImageURL  = [info objectForKey:@"thumb_image"];
    self.detailImageURL = [info objectForKey:@"detail_image"];
    
    self.lat            = [[info objectForKey:@"lat"] doubleValue];
    self.lon            = [[info objectForKey:@"lon"] doubleValue];
    self.distance       = [[info objectForKey:@"distance"] doubleValue];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.lat;
    coordinate.longitude = self.lon;
    
    [self setCoordinate:coordinate];
    
    return self;
}


- (void)dealloc {
    
    self.name           = nil;
    self.photoPerson    = nil;
    self.address1       = nil;
    self.address2       = nil;
    self.state          = nil;
    self.suburb         = nil;
    self.postcode       = nil;
    self.phone          = nil;
    self.thumbImageURL  = nil;
    self.detailImageURL = nil;
    self.image          = nil;
    
    [super dealloc];
}

- (NSString *)formattedAddress {
    NSMutableString *formattedAddress = [NSMutableString string];
    
    if (![NSString isNilOrEmpty:self.address1]) {
        [formattedAddress appendString:self.address1];
    } 

    if (![NSString isNilOrEmpty:self.address2]) {
        if ([NSString isNilOrEmpty:formattedAddress]) {
            [formattedAddress appendString:self.address2];
        } else {
            [formattedAddress appendFormat:@", %@", self.address2];
        }
    }
    
    if ([NSString isNilOrEmpty:formattedAddress]) {
        [formattedAddress appendFormat:@"%@, %@ %@", self.suburb, self.state, self.postcode];
    } else {
        [formattedAddress appendFormat:@", %@", self.suburb];
    }
    
    return formattedAddress;
}

- (NSString *)formattedDistance {
    NSUInteger distance = self.distance;
    return [NSString stringWithFormat:@"Distance: %d km", distance];
}

#pragma mark - MKAnnotation methods
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
	_coordinate = newCoordinate;
}

- (NSString *)title {
	return self.name;
}
//
//#pragma mark - HJManagedImageDelegate methods
//-(void) managedImageSet:(HJManagedImageV*)mi {
//    self.imageLoaded = YES;
//    self.image = mi.image;
//}
//
//-(void) managedImageCancelled:(HJManagedImageV*)mi {
//    self.imageLoaded = NO;
//    self.image = mi.image;
//}

@end
