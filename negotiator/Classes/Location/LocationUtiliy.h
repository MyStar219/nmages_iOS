//
//  LocationUtiliy.h
//  SmartSaver
//
//  Created by Andrei Vig on 11/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CLLocation-Additions.h"
#import "Coupons.h"
#import "MonitorCoupons.h"


static NSString *kNewLocationAvailableNotiticationName;

@interface LocationUtiliy : NSObject <CLLocationManagerDelegate>{
    
    NSMutableArray<MonitorCoupons*> *_monitorCoupons;
	CLLocationManager *_locationUtiliy;
	CLLocation *_currentLocation;
    BOOL _userAcceptedLocation;
}

@property (nonatomic, strong) NSMutableArray<MonitorCoupons*> *monitorCoupons;

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, assign) BOOL userAcceptedLocation;

@property (nonatomic, assign) BOOL isEnableLocationFromDeepLink;

+ (LocationUtiliy *)sharedInstance;

- (BOOL)userAccepted;

- (void)start;
- (void)stop;

- (NSArray *)monitoredRegions;
- (CLLocation *)currentLocation;

- (void)setupMonitoring;

@end
