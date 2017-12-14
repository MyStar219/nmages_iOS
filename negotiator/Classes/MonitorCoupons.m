//
//  MonitorCoupons.m
//  negotiator
//
//  Created by aplome on 03/08/2017.
//
//

#import "MonitorCoupons.h"

@implementation MonitorCoupons

@synthesize couponId = _couponId;
@synthesize couponTitle = _couponTitle;
@synthesize lat = _lat;
@synthesize lon = _lon;
@synthesize coordinate = _coordinate;
@synthesize distance = _distance;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.couponId = @"";
        self.couponTitle = @"";
        self.lat = 0;
        self.lon = 0;
        self.coordinate = CLLocationCoordinate2DMake(0, 0);
        self.distance = 0;
    }
    return self;
}

- (instancetype)initWithCouponInfo:(NSDictionary *)info {

    self = [super init];
    if (!self) return nil;

    
    self.couponId = [info objectForKey:@"id"];
    self.couponTitle = [info valueForKey:@"title"];
    self.lat = [[info objectForKey:@"lat"] doubleValue];
    self.lon = [[info objectForKey:@"lon"] doubleValue];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.lat;
    coordinate.longitude = self.lon;
    
    [self setCoordinate:coordinate];
    
    return self;
}

#pragma mark - MKAnnotation methods
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {

    _coordinate = coordinate;
}

- (void)setDistance:(CLLocationDistance)distance {

    _distance = distance;
}

- (void)dealloc {
    
    self.couponId = nil;
    self.couponTitle = nil;
    
    [super dealloc];
}

@end
