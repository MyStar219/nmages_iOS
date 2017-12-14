//
//  Utility.h
//  negotiator
//
//  Created by aplome on 24/07/2017.
//
//

#import <Foundation/Foundation.h>
#import "RegionObject.h"
#import "Coupons.h"
#import "CouponDetailsViewController.h"
#import "CouponRedeemViewController.h"
#import "MonitorCouponsEntity+CoreDataClass.h"
#import "RegionsEntity+CoreDataClass.h"

typedef void(^DynamicLinkURLCompletion)(NSURL * _Nullable shortURL, NSString * _Nullable shortStringURL, NSError * _Nullable error);

@interface Utility : NSObject

+ (RegionObject *)convertRegionsFromDB:(RegionsEntity *)regionEntity;
+ (MonitorCoupons *)convertCouponsFromDB:(MonitorCouponsEntity *)monitorEntity;

+ (NSString *)getRegionIdFromRegionName:(NSString *)name;
+ (NSMutableArray<MonitorCoupons *> *)getMonitorCouponsFromDB;

+ (NSMutableArray *)parseRegionsJSON:(id)responseObject;
+ (NSMutableArray *)parseCouponsJSON:(id)responseObject;

+ (void)setFirstStartUp;
+ (BOOL)isFirstStartUp;

+ (void)setFCMToken:(NSString *)token;
+ (NSString *)getFCMToken;

+ (CGFloat)directMetersFromCoordinate:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to;
+ (double) distanceBetweenLat1:(double)lat1 lon1:(double)lon1
                          lat2:(double)lat2 lon2:(double)lon2;


+ (void)showCouponRedeemWithCoupon:(Coupons *)coupon onTarget:(UINavigationController *)navigationController;
+ (void)showCouponDetailsWithCoupon:(Coupons *)coupon onTarget:(UINavigationController *)navigationController;
+ (NSString *)getLowercaseStringWithoutWhiteSpaces:(NSString *)stringValue;
+ (void)getDynamicLinkWithCoupons:(Coupons *)coupon completion:(DynamicLinkURLCompletion)completion;

@end
