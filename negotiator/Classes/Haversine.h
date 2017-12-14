//
//  haversine.h
//
//  Created by Carsten Nielsen on 23/04/09.
//

#import <Foundation/Foundation.h>


extern float const HAVERSINE_RADS_PER_DEGREE;
extern float const HAVERSINE_MI_RADIUS;
extern float const HAVERSINE_KM_RADIUS;
extern float const HAVERSINE_M_PER_KM;
extern float const HAVERSINE_F_PER_MI;

@interface Haversine : NSObject

#pragma MARK - CLLocationCoordinate2D

+ (float)distanceFrom:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to;
+ (float)toKilometersFrom:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to;
+ (float)toMetersFrom:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to;
+ (float)toMilesFrom:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to;
+ (float)toFeetFrom:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to;

#pragma MARK - CLLocation

+ (float)distanceFrom:(CLLocation *)from toLocation:(CLLocation *)to;
+ (float)toKilometersFrom:(CLLocation *)from toLocation:(CLLocation *)to;
+ (float)toMetersFrom:(CLLocation *)from toLocation:(CLLocation *)to;
+ (float)toMilesFrom:(CLLocation *)from toLocation:(CLLocation *)to;
+ (float)toFeetFrom:(CLLocation *)from toLocation:(CLLocation *)to;

@end
