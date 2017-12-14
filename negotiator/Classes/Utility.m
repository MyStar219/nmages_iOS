//
//  Utility.m
//  negotiator
//
//  Created by aplome on 24/07/2017.
//
//

#import "Utility.h"
#import "RegionManager.h"
#import <MagicalRecord/MagicalRecord.h>
#import <MagicalRecord/MagicalRecord+ShorthandMethods.h>

@import FirebaseDynamicLinks;

@implementation Utility

#pragma mark - Location Methods

// adapted from C++ code on this page
+ (CGFloat)directMetersFromCoordinate:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to {
    
    static const double DEG_TO_RAD = 0.017453292519943295769236907684886;
    static const double EARTH_RADIUS_IN_METERS = 6372797.560856;
    
    double latitudeArc  = (from.latitude - to.latitude) * DEG_TO_RAD;
    double longitudeArc = (from.longitude - to.longitude) * DEG_TO_RAD;
    double latitudeH = sin(latitudeArc * 0.5);
    latitudeH *= latitudeH;
    double lontitudeH = sin(longitudeArc * 0.5);
    lontitudeH *= lontitudeH;
    double tmp = cos(from.latitude*DEG_TO_RAD) * cos(to.latitude*DEG_TO_RAD);
    return EARTH_RADIUS_IN_METERS * 2.0 * asin(sqrt(latitudeH + tmp*lontitudeH));
}

+ (double) distanceBetweenLat1:(double)lat1 lon1:(double)lon1
                          lat2:(double)lat2 lon2:(double)lon2 {
    //degrees to radians
    double lat1rad = lat1 * M_PI/180;
    double lon1rad = lon1 * M_PI/180;
    double lat2rad = lat2 * M_PI/180;
    double lon2rad = lon2 * M_PI/180;
    
    //deltas
    double dLat = lat2rad - lat1rad;
    double dLon = lon2rad - lon1rad;
    
    double a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat1rad) * cos(lat2rad);
    double c = 2 * asin(sqrt(a));
    double R = 6372.8;
    return R * c;
}

#pragma mark - Other Methods

+ (RegionObject *)convertRegionsFromDB:(RegionsEntity *)regionEntity {

    RegionObject *regionObject = [[RegionObject alloc] init];
    
    regionObject.regionId = regionEntity.regionId;
    regionObject.regionName = regionEntity.regionName;
    regionObject.regionImagePath = regionEntity.regionImage;
    regionObject.regionImageLink = regionEntity.regionImageURL;
    
    return regionObject;
}

+ (NSMutableArray *)parseRegionsJSON:(id)responseObject {
    
    NSArray *responseArray = [NSArray arrayWithArray:responseObject];
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    
    for (NSDictionary *dict in responseArray) {
        
        [resultArray addObject:[[RegionObject alloc] initWithDictionary:dict]];
    }
    
    return resultArray;
}



+ (MonitorCoupons *)convertCouponsFromDB:(MonitorCouponsEntity *)monitorEntity {

    MonitorCoupons *monitorCoupons = [[MonitorCoupons alloc] init];
    
    monitorCoupons.couponId = monitorEntity.couponId;
    monitorCoupons.couponTitle = monitorEntity.couponTitle;
    monitorCoupons.lat = monitorEntity.lat;
    monitorCoupons.lon = monitorEntity.lon;
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = monitorCoupons.lat;
    coordinate.longitude = monitorCoupons.lon;
    
    [monitorCoupons setCoordinate:coordinate];
    
    return monitorCoupons;
}

+ (NSMutableArray *)parseCouponsJSON:(id)responseObject {
    
    NSArray *responseArray = [NSArray arrayWithArray:responseObject];
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    
    for (NSDictionary *dict in responseArray) {
        
        [resultArray addObject:[[MonitorCoupons alloc] initWithCouponInfo:dict]];
    }
    
    return resultArray;
}

+ (NSMutableArray<MonitorCoupons *> *)getMonitorCouponsFromDB {
    
    NSArray *result = [MonitorCouponsEntity MR_findAllSortedBy:@"couponId" ascending:YES];
    
    NSMutableArray *objectArray = [[NSMutableArray alloc] init];
    
    for (MonitorCouponsEntity *monitorEntity in result) {
        
        [objectArray addObject:[self convertCouponsFromDB:monitorEntity]];
    }
    
    return objectArray;
}

+ (NSString *)getLowercaseStringWithoutWhiteSpaces:(NSString *)stringValue {

    NSString *newStringValue = stringValue.lowercaseString;
    
    newStringValue = [newStringValue stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
    return newStringValue;
}

+ (NSString *)getRegionIdFromRegionName:(NSString *)name {

//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"regionName=%@", name];
    
    NSArray *result = [RegionsEntity MR_findAll];
    
    NSMutableArray *objectArray = [[NSMutableArray alloc] init];
    
    for (RegionsEntity *regionEntity in result) {
        
        [objectArray addObject:[self convertRegionsFromDB:regionEntity]];
    }
    
    for (RegionObject *regionObject in objectArray) {
        
        NSString *regionName = regionObject.regionName;
        
        regionName = regionName.lowercaseString;
        
        regionName = [regionName stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        
        if ([regionName isEqualToString:name]) {
            
            return regionObject.regionId;
        }
        else if ([regionName containsString:name]) {
        
            return regionObject.regionId;
        }
        else if ([name containsString:regionName]) {
            
            return regionObject.regionId;
        }
    }
    
    return @"";
}


+ (void)setFirstStartUp {

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstStartUp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isFirstStartUp {

    BOOL firstStartUp = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstStartUp"];
    
    return !firstStartUp;
}

+ (void)setFCMToken:(NSString *)token {

    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"FCMToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getFCMToken {

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FCMToken"] != [NSNull null]) {
        
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"FCMToken"];
        if (token == nil) {
        
            return @"";
        }
        
        return token;
    }
    else {
    
        return @"";
    }
}

+ (void)showCouponRedeemWithCoupon:(Coupons *)coupon onTarget:(UINavigationController *)navigationController {

    CouponRedeemViewController *fullViewController = [[CouponRedeemViewController alloc] initWithCouponInfo:coupon];
    fullViewController.hidesBottomBarWhenPushed = YES;
    [navigationController pushViewController:fullViewController animated:YES];
    [fullViewController release];
}

+ (void)showCouponDetailsWithCoupon:(Coupons *)coupon onTarget:(UINavigationController *)navigationController {
    
    CouponDetailsViewController *detailsController = [[CouponDetailsViewController alloc] initWithNibName:@"CouponDetailsViewController"
                                                                                                   bundle:[NSBundle mainBundle]
                                                                                              couponsInfo:coupon];
    [navigationController pushViewController:detailsController animated:YES];
    
    [detailsController release];
}

+ (FIRDynamicLinkAndroidParameters *)getAndroidParameters {

    FIRDynamicLinkAndroidParameters *androidParam = [FIRDynamicLinkAndroidParameters parametersWithPackageName:FIREBASE_ANDROID_PACKAGENAME];
    
    androidParam.fallbackURL = [NSURL URLWithString:FIREBASE_APPLINK];
    androidParam.minimumVersion = FIREBASE_ANDROID_VERSION.intValue;
    
    return androidParam;
}

+ (FIRDynamicLinkIOSParameters *)getiOSParameters {

    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
    NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    
    FIRDynamicLinkIOSParameters *iOSParam = [FIRDynamicLinkIOSParameters parametersWithBundleID:bundleIdentifier];
    
    iOSParam.minimumAppVersion = bundleVersion;
    iOSParam.appStoreID = FIREBASE_APPSTOREID;
    iOSParam.fallbackURL = [NSURL URLWithString:FIREBASE_APPLINK];
    iOSParam.iPadFallbackURL = [NSURL URLWithString:FIREBASE_APPLINK];
    iOSParam.iPadBundleID = bundleIdentifier;
    
    return iOSParam;
}

+ (void)getDynamicLinkWithCoupons:(Coupons *)coupon completion:(DynamicLinkURLCompletion)completion {

    NSString *regionName = [[[RegionManager sharedInstance] region] regionName];
    regionName = [Utility getLowercaseStringWithoutWhiteSpaces:regionName];
    NSString *magzineName = [Utility getLowercaseStringWithoutWhiteSpaces:coupon.category[0].categoryName];
    NSString *couponId = coupon.couponId;
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", regionName,magzineName,couponId];
    
    NSLog(@"\n\nPath: %@ \n\n", path);
    
    [Utility getDynamicLinkForShareWithPath:path completion:^(NSURL * _Nullable shortURL, NSArray<NSString *> * _Nullable warnings, NSError * _Nullable error) {
        
        completion(shortURL, shortURL.absoluteString, error);
    }];
}

/**
 returns dynamic link for coupons

 @param path dynamiclink path for parse and identify link. like 'blacktown/chow/2814'
 */
+ (void)getDynamicLinkForShareWithPath:(NSString *)path completion:(FIRDynamicLinkShortenerCompletion)completion {

    
    NSString *domain = FIREBASE_DOMAIN;
    NSString *baseURLString = FIREBASE_APPLINK;
    
    //http://www.nmags.com/blacktown/chow/2814
    NSString *fullURLString = [NSString stringWithFormat:@"%@%@",baseURLString,path];
    
    NSURL *deeplinkURL = [NSURL URLWithString:fullURLString];
    
    if (deeplinkURL != nil) {
        
        FIRDynamicLinkComponents *components = [FIRDynamicLinkComponents componentsWithLink:deeplinkURL domain:domain];
        
        components.iOSParameters = [Utility getiOSParameters];
        
        components.androidParameters = [Utility getAndroidParameters];
    
        FIRDynamicLinkComponentsOptions *options = [[FIRDynamicLinkComponentsOptions alloc] init];
        
        options.pathLength = FIRShortDynamicLinkPathLengthShort;
        
        components.options = options;
        
        [components shortenWithCompletion:^(NSURL * _Nullable shortURL, NSArray<NSString *> * _Nullable warnings, NSError * _Nullable error) {
        
            completion(shortURL,warnings,error);
        }];
    }
    
/*
 
 
 let options = DynamicLinkComponentsOptions()
 
 /// set path length for dynamic link url short or unguessable
 options.pathLength = .short
 components.options = options
 
 components.shorten { (shortURL, warnings, error) in
 
 completion(shortURL, warnings, error)
 }
 }
 
 */
    
}

//+(void) setUserLoggedIn:(int) loggedIn
//{
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:loggedIn] forKey:@"UserLoggedIn"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//+(int) isUserLoggedin
//{
//    if([[NSUserDefaults standardUserDefaults] objectForKey:@"UserLoggedIn"] != [NSNull null])
//    {
//        NSNumber *adFrequency = (NSNumber *) [[NSUserDefaults standardUserDefaults] objectForKey:@"UserLoggedIn"] ;
//        if (adFrequency == nil) {
//            return 0;
//        }
//        
//        return  [adFrequency intValue];
//    }
//    return 0;
//}

    
@end
