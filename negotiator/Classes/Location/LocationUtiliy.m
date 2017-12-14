//
//  LocationUtiliy.m
//  SmartSaver
//
//  Created by Andrei Vig on 11/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.


#import "LocationUtiliy.h"
#import "Utility.h"
#import "Haversine.h"
#import "AppDelegate.h"

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

#define DISTANCE_FILTER (5)

/* define notification names*/
//static NSString *kNewLocationAvailableNotiticationName = @"newLocationAvailable";

static LocationUtiliy *kLocationUtiliy;

@implementation LocationUtiliy

@synthesize monitorCoupons = _monitorCoupons;
@synthesize currentLocation = _currentLocation;
@synthesize userAcceptedLocation = _userAcceptedLocation;

+ (LocationUtiliy *)sharedInstance {
    
    
	if (nil == kLocationUtiliy) {
		kLocationUtiliy = [[LocationUtiliy alloc] init];
	}
    
	return kLocationUtiliy;
}

- (void)dealloc {
	[super dealloc];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        /* setup location manager */
        _locationUtiliy = [[CLLocationManager alloc] init];
        [_locationUtiliy setDelegate:self];
        [_locationUtiliy setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
  
        [_locationUtiliy requestWhenInUseAuthorization];

//        [_locationUtiliy requestAlwaysAuthorization];
        [_locationUtiliy setDistanceFilter:DISTANCE_FILTER];
            [_locationUtiliy startMonitoringSignificantLocationChanges];
        self.userAcceptedLocation = YES;
    }
    return self;
}

- (void)setMonitorCoupons:(NSMutableArray<MonitorCoupons *> *)monitorCoupons {
    NSLog(@"%s", __FUNCTION__);
    
    BOOL isAlreadyCoupons = NO;
    
    if (_monitorCoupons.count > 0) {
        
        isAlreadyCoupons = YES;
    }
    _monitorCoupons = monitorCoupons;
    
    if (isAlreadyCoupons) {
        
        if (self.currentLocation != nil) {
         
            [self setupMonitoringWithLocation:self.currentLocation];
        }
    }
}

- (BOOL)userAccepted {
    NSLog(@"%s", __FUNCTION__);
    return (self.userAcceptedLocation && (self.currentLocation != nil)); 
}

- (void)start
{
    NSLog(@"%s", __FUNCTION__);
	LOG(@"location manager started");
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    
//        [_locationUtiliy startUpdatingLocation];
//    });

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusDenied)
    {
        NSLog(@"Location services are disabled in settings.");
    }
    else
    {
        // for iOS 8
//        if ([_locationUtiliy respondsToSelector:@selector(requestAlwaysAuthorization)])
//        {
//            [_locationUtiliy requestAlwaysAuthorization];
//        }

        if ([_locationUtiliy respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [_locationUtiliy requestWhenInUseAuthorization];
        }
        // for iOS 9
        if ([_locationUtiliy respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)])
        {
            [_locationUtiliy setAllowsBackgroundLocationUpdates:YES];
        }
        
        [_locationUtiliy startUpdatingLocation];
    }
    
}

- (void)stop
{
    NSLog(@"%s", __FUNCTION__);
	[_locationUtiliy stopUpdatingLocation];
}

- (NSArray *)monitoredRegions {
    NSLog(@"%s", __FUNCTION__);

    return _locationUtiliy.monitoredRegions.allObjects;
}

#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"%s", __FUNCTION__);
    
    NSLog(@"1-Monitor Regions: %lu", self.monitoredRegions.count);
    
    if (locations.count > 0) {
     
        // Old locatio self.currentLocation
        
        // New Location
        CLLocation *location = locations[0];
        
        NSLog(@"\nLatitude: %f, Longitude: %f", location.coordinate.latitude, location.coordinate.longitude);
        NSLog(@"\n Current Latitude: %f, Current Longitude: %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
        
        NSLog(@"Location Distance changed: %f", [Haversine toMetersFrom:self.currentLocation toLocation:location]);
        
        
        if (![self.currentLocation isEqualORRangeWith:location] || [self.currentLocation isEqual:nil]) {
            
            self.currentLocation = location;
            //self.currentLocation = [[CLLocation alloc]initWithLatitude:-33.86 longitude:151.21f];
        
            [self setupMonitoringWithLocation:self.currentLocation];

            NSLog(@"New Latitude: %f, New Longitude: %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userAcceptedUseOfLocation" object:nil];
            
        }
        
        if (self.isEnableLocationFromDeepLink) {
            
            self.isEnableLocationFromDeepLink = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deepLinkingEnabledLocation" object:nil];
        }
    }
}

//- (void)locationManager:(CLLocationManager *)manager
//   didUpdateToLocation:(CLLocation *)newLocation
//          fromLocation:(CLLocation *)oldLocation
//{
//    NSLog(@"%s", __FUNCTION__);
//    [_locationUtiliy stopUpdatingLocation];
//    
//
//    NSLog(@"\n\n\n");
//    NSLog(@"Location Distance: %f", [Haversine distanceFrom:oldLocation.coordinate toCoordinate:newLocation.coordinate]);
//    NSLog(@"Location Distance KM: %f", [Haversine toKilometersFrom:oldLocation.coordinate toCoordinate:newLocation.coordinate]);
//    NSLog(@"Location Distance M: %f", [Haversine toMetersFrom:oldLocation.coordinate toCoordinate:newLocation.coordinate]);
//    NSLog(@"Location Distance Ml: %f", [Haversine toMilesFrom:oldLocation.coordinate toCoordinate:newLocation.coordinate]);
//    NSLog(@"Location Distance F: %f", [Haversine toFeetFrom:oldLocation.coordinate toCoordinate:newLocation.coordinate]);
//    NSLog(@"\n\n\n");
//    NSLog(@"Location Distance: %f", [Haversine distanceFrom:oldLocation toLocation:newLocation]);
//    NSLog(@"Location Distance KM: %f", [Haversine toKilometersFrom:oldLocation toLocation:newLocation]);
//    NSLog(@"Location Distance M: %f", [Haversine toMetersFrom:oldLocation toLocation:newLocation]);
//    NSLog(@"Location Distance Ml: %f", [Haversine toMilesFrom:oldLocation toLocation:newLocation]);
//    NSLog(@"Location Distance F: %f", [Haversine toFeetFrom:oldLocation toLocation:newLocation]);
//    
//    
//    NSLog(@"Latitude: %f, Longitude: %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
//    
//    if (![self.currentLocation isEqualORRangeWith:newLocation] || [self.currentLocation isEqual:nil]) {
//    
//        self.currentLocation = newLocation;
//        //self.currentLocation = [[CLLocation alloc]initWithLatitude:-33.86 longitude:151.21f];
//        NSLog(@"New Latitude: %f, New Longitude: %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"userAcceptedUseOfLocation" object:nil];
//        
//    }
//    
//    if (self.isEnableLocationFromDeepLink) {
//     
//        self.isEnableLocationFromDeepLink = NO;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"deepLinkingEnabledLocation" object:nil];
//    }
//}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"%s", __FUNCTION__);

//    if (status == kCLAuthorizationStatusAuthorizedAlways) {
//
//    }
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    
	if (kCLErrorDenied == [error code]) {
	
        self.userAcceptedLocation = NO;
        
        /* user didn't allow the app to get his/her location */
		[_locationUtiliy stopUpdatingLocation];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userDeniedUseOfLocation" object:nil];
	}
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    NSLog(@"%s", __FUNCTION__);
	return NO;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"%s", __FUNCTION__);

    NSLog(@"Enter: %@", region.identifier);
    CLLocation * lastLocation = [manager location];
    
    BOOL doesItContainMyPoint;
    
    if(lastLocation==nil)
    {
        doesItContainMyPoint = NO;
    }
    else {
        
        CLLocationCoordinate2D theLocationCoordinate = lastLocation.coordinate;
        CLCircularRegion * theRegion = (CLCircularRegion*)region;
        doesItContainMyPoint = [theRegion containsCoordinate:theLocationCoordinate];
    }
    
    if (doesItContainMyPoint) {
        
        
        
        [self showNotificationWithRegion:[self getCoupons:region.identifier]];
        
//        [self removeCoupons:region.identifier];
//        [_locationUtiliy stopMonitoringForRegion:region];
//        [self setupMonitoringWithLocation:self.currentLocation];
        // Near By notifications
    }
    else {
    }
    
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
//    NSLog(@"%s", __FUNCTION__);

    NSLog(@"Exit: %@", region.identifier);
    
    [self removeCoupons:region.identifier];
    [_locationUtiliy stopMonitoringForRegion:region];
    [self setupMonitoringWithLocation:self.currentLocation];

//    [_locationUtiliy stopMonitoringForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
//    NSLog(@"%s", __FUNCTION__);

//    NSLog(@"didStart: %@", region.identifier);
//    NSLog(@"Lat: %f, Lon: %f",region.center.latitude, region.center.longitude);
//    NSLog(@"2-Monitor Regions: %lu", self.monitoredRegions.count);
}

#pragma mark - Helper Methods

- (void)showNotificationWithRegion:(MonitorCoupons *)coupons {
    NSLog(@"%s", __FUNCTION__);
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
        
//        #if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
//                // For iOS 10 display notification
//        
//                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//                content.title = [NSString localizedUserNotificationStringForKey:@""
//                                                                      arguments:nil];
//                content.body = [NSString localizedUserNotificationStringForKey:coupons.couponTitle
//                                                                     arguments:nil];
//                content.sound = [UNNotificationSound defaultSound];
//                // 4. update application icon badge number
//                //     content.badge = [NSNumber numberWithInteger:([UIApplication sharedApplication].applicationIconBadgeNumber + 1)];
//                // Deliver the notification in five seconds.
//        
//                NSTimeInterval interval = [NSDate date].timeIntervalSinceNow;
//                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
//                                                              triggerWithTimeInterval:interval
//                                                              repeats:NO];
//        
//                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:coupons.couponTitle
//                                                                                      content:content
//                                                                                      trigger:trigger];
//                /// 3. schedule localNotification
//                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//                [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//                    if (!error) {
//                        NSLog(@"add NotificationRequest succeeded!");
//                    }
//                }];
//        
//        
//        
//        #else
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        
        localNotification.alertBody = coupons.couponTitle;
        localNotification.alertTitle = @"Nearby Coupons";
        
//        localNotification.fireDate = [NSDate date];
//        NSTimeZone* timezone = [NSTimeZone defaultTimeZone];
//        localNotification.timeZone = timezone;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        //        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        //
        //        [userInfo setValue:region. forKey:@"icon"];
        //        [userInfo setValue:[remoteMessage.appData valueForKey:@"from"] forKey:@"from"];
        
        //        localNotification.userInfo = userInfo;
//        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        
//        #endif
    }
    else {
        
        // Show alerts and popups
        
//        NSString *title = NSLocalizedString(@"Negotiator", nil);
//        NSString *message = NSLocalizedString(@"Some Coupons are nearby you.", nil);
//        NSString *actionTitle = NSLocalizedString(@"OK", nil);
//        
//        if ([UIAlertController class] != nil) {
//        
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
//            
//            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
//            
//            [alertController addAction:okAction];
//            
//            [[[[UIApplication appDelegate] window] rootViewController] presentViewController:alertController animated:YES completion:nil];
//        }
//        else {
//        
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:actionTitle otherButtonTitles:nil, nil];
//            [alert show];
//        }
        
    }
}

- (void)setupMonitoring {

    if (self.currentLocation != nil) {
        
        [self setupMonitoringWithLocation:self.currentLocation];
    }
}

- (void)setupMonitoringWithLocation:(CLLocation *)location {
    NSLog(@"%s", __FUNCTION__);

//    [self stopMonitoring];
    
    
    NSMutableArray *sortedFences = [[NSMutableArray alloc] init];
    
    if (self.monitorCoupons.count > 0) {
     
        // add distance to each fence to be sorted
        for (MonitorCoupons *geofence in self.monitorCoupons) {
            // create a CLLocation object from my custom object
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geofence.coordinate.latitude, geofence.coordinate.longitude);
            CLLocation *fenceLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            // calculate distance from current location
            CLLocationDistance distance = [location distanceFromLocation:fenceLocation];
            // save distance so we can filter array later
            
//            NSLog(@"Lat: %f, Lon: %f", geofence.coordinate.latitude, geofence.coordinate.longitude);
            
            // Within 50 Meters to 2000 Meters (2KM) radius for geofencing
            
//            if (distance > 50.0 && distance < 2000.0) {
            
                geofence.distance = distance;
                [sortedFences addObject:geofence];
//            }
        }
        
        // sort our array of geofences by distance and add we can add the first 20
        
        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        NSArray *sortedArray = [sortedFences sortedArrayUsingDescriptors:sortDescriptors];
        
        
        
        if (sortedArray.count > 0) {
        
            // Only first 20 elements
            if (sortedArray.count >= 20) {
                sortedArray = [sortedArray subarrayWithRange:NSMakeRange(0, 20)];
            }
            
            [self startMonitoring:sortedArray];
        }
        else {
        
//            [self stopMonitoring];
        }
    }
    else {
    
    }
}

- (void)stopMonitoring {
    NSLog(@"%s", __FUNCTION__);

    for (CLCircularRegion *region in _locationUtiliy.monitoredRegions.allObjects) {
    
        NSLog(@"Stop: %@", region.identifier);
        [_locationUtiliy stopMonitoringForRegion:region];
    }
}

- (void)startMonitoring:(NSArray<MonitorCoupons *> *)couponsArray {
    NSLog(@"%s", __FUNCTION__);

    [self stopMonitoring];
    
    // 1
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        
        NSLog(@"Geofencing is not supported on this device!");
        return;
    }
    
    // 2
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        
        NSLog(@"Your Region is saved but will only be activated once you grant permission to access the device location.");
    }
    
    // should only use array of 20, but I was using hardcoded count to exit
    
    for (MonitorCoupons *geofence in couponsArray) {
        
        // 3
        CLCircularRegion *fenceRegion = [self regionFromCoupon:geofence];
        
        [_locationUtiliy startMonitoringForRegion:fenceRegion];
    }
}

- (CLCircularRegion *)regionFromCoupon:(MonitorCoupons *)monitorCoupon {
//    NSLog(@"%s", __FUNCTION__);

    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(monitorCoupon.coordinate.latitude, monitorCoupon.coordinate.longitude);
    NSLog(@"Lat: %f, Lon: %f",monitorCoupon.coordinate.latitude, monitorCoupon.coordinate.longitude);
    NSLog(@"Distance: %f",monitorCoupon.distance);
    CLLocationDistance radius = 200.0;//monitorCoupon.distance;
    NSString *ident = monitorCoupon.couponId;
    
    CLCircularRegion *fenceRegion = [[CLCircularRegion alloc] initWithCenter:coordinate radius:radius identifier:ident];
    
    fenceRegion.notifyOnEntry = YES;
    fenceRegion.notifyOnExit = YES;
    
    return fenceRegion;
}

- (MonitorCoupons *)getCoupons:(NSString *)couponId {
    NSLog(@"%s", __FUNCTION__);
    
    MonitorCoupons *geofenceObject = [[MonitorCoupons alloc] init];
    
    if (self.monitorCoupons.count > 0) {
        
        // add distance to each fence to be sorted
        for (MonitorCoupons *geofence in self.monitorCoupons) {
            
            if (geofence.couponId == couponId) {
            
                geofenceObject = geofence;
            }
        }
    }
    
    return geofenceObject;
}

- (void)removeCoupons:(NSString *)couponId {
    NSLog(@"%s", __FUNCTION__);
    
    NSArray *tempArray = [NSArray arrayWithArray:self.monitorCoupons];
    
    if (tempArray > 0) {
        
        // add distance to each fence to be sorted
        for (MonitorCoupons *geofence in tempArray) {
            
            if (geofence.couponId == couponId) {
                
                [self.monitorCoupons removeObject:geofence];
            }
        }
    }
}

@end
