//
//  MKMapView-Additions.h
//  vevoke
//
//  Created by Andrei Vig on 11/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface MKMapView (MKMapView_Additions)

+ (double)distanceFromStartCoordinate:(CLLocationCoordinate2D)startCoordinate
					  toEndCoordinate:(CLLocationCoordinate2D)endCoordinate;

+ (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations;

@end
