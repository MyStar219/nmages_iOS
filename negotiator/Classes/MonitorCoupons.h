//
//  MonitorCoupons.h
//  negotiator
//
//  Created by aplome on 03/08/2017.
//
//

#import <Foundation/Foundation.h>

@interface MonitorCoupons : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString    *couponId;
@property (nonatomic, strong) NSString    *couponTitle;

@property (nonatomic) double    lat;
@property (nonatomic) double    lon;
@property (nonatomic) CLLocationDistance distance;
@property (nonatomic) CLLocationCoordinate2D coordinate;

- (instancetype)initWithCouponInfo:(NSDictionary *)info;

@end
