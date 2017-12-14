//
//  haversine.m
//
//  Created by Carsten Nielsen.
//

#import "Haversine.h"

float const HAVERSINE_RADS_PER_DEGREE = 0.0174532925199433;
float const HAVERSINE_MI_RADIUS = 3956.0;
float const HAVERSINE_KM_RADIUS = 6372.8;
float const HAVERSINE_M_PER_KM = 1000.0;
float const HAVERSINE_F_PER_MI = 5282.0;


@implementation Haversine

#pragma mark - Using CLLocationCoordinate2D

+ (float)distanceFrom:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to {

    float lat1 = from.latitude;
    float lon1 = from.longitude;
    float lat2 = to.latitude;
    float lon2 = to.longitude;
    
    float lat1Rad = lat1 * HAVERSINE_RADS_PER_DEGREE;
    float lat2Rad = lat2 * HAVERSINE_RADS_PER_DEGREE;
    float dLonRad = ((lon2 - lon1) * HAVERSINE_RADS_PER_DEGREE);
    float dLatRad = ((lat2 - lat1) * HAVERSINE_RADS_PER_DEGREE);
    float a = pow(sin(dLatRad / 2), 2) + cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLonRad / 2), 2);
    return (2 * atan2(sqrt(a), sqrt(1 - a)));
}

+ (float)toKilometersFrom:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to {

    return [Haversine distanceFrom:from toCoordinate:to] * HAVERSINE_KM_RADIUS;
}

+ (float)toMetersFrom:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to {

    return [Haversine toKilometersFrom:from toCoordinate:to] * HAVERSINE_M_PER_KM;
}

+ (float)toMilesFrom:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to {

    return [Haversine distanceFrom:from toCoordinate:to] * HAVERSINE_MI_RADIUS;
}

+ (float)toFeetFrom:(CLLocationCoordinate2D)from toCoordinate:(CLLocationCoordinate2D)to {

    return [Haversine toMilesFrom:from toCoordinate:to] * HAVERSINE_F_PER_MI;
}

#pragma mark - Using CLLocation

+ (float)distanceFrom:(CLLocation *)from toLocation:(CLLocation *)to {
    
    return [Haversine distanceFrom:from.coordinate toCoordinate:to.coordinate];
}

+ (float)toKilometersFrom:(CLLocation *)from toLocation:(CLLocation *)to {
    
    return [Haversine toKilometersFrom:from.coordinate toCoordinate:to.coordinate];
}

+ (float)toMetersFrom:(CLLocation *)from toLocation:(CLLocation *)to {
    
    return [Haversine toMetersFrom:from.coordinate toCoordinate:to.coordinate];
}

+ (float)toMilesFrom:(CLLocation *)from toLocation:(CLLocation *)to {
    
    return [Haversine toMilesFrom:from.coordinate toCoordinate:to.coordinate];
}

+ (float)toFeetFrom:(CLLocation *)from toLocation:(CLLocation *)to {
    
    return [Haversine toFeetFrom:from.coordinate toCoordinate:to.coordinate];
}

@end
