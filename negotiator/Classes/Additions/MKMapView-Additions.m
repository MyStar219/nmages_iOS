//
//  MKMapView-Additions.m
//  vevoke
//
//  Created by Andrei Vig on 11/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MKMapView-Additions.h"


@implementation MKMapView (MKMapView_Additions)

+ (double)distanceFromStartCoordinate:(CLLocationCoordinate2D)startCoordinate
					  toEndCoordinate:(CLLocationCoordinate2D)endCoordinate {

	/* calculate distance from last locaiton */
	int earthRadius = 6371; /* in kilometers */
	
	double latitudeDelta = (endCoordinate.latitude - startCoordinate.latitude) * M_PI / 180.0;
	double longitudeDelta = (endCoordinate.longitude - startCoordinate.longitude) * M_PI / 180.0;
	double a = sin(latitudeDelta / 2) * sin(latitudeDelta / 2) +	cos(startCoordinate.latitude * M_PI / 180.0) * 
																	cos(endCoordinate.latitude * M_PI / 180.0) * 
																	sin(longitudeDelta / 2) * 
																	sin(longitudeDelta / 2);
	double c = 2 * atan2(sqrt(a), sqrt(1 - a));
	
	double distance = earthRadius * c;
	
	return distance;
}

+ (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations {
	CLLocationDegrees maxLatitude = -90.0;
	CLLocationDegrees minLatitude = 90.0;
	CLLocationDegrees maxLongitude = -180.0;
	CLLocationDegrees minLongitude = 180.0;
	
	for (id<MKAnnotation>anno in annotations) {
		CLLocationDegrees thisLatitude = anno.coordinate.latitude;
		CLLocationDegrees thisLongitude = anno.coordinate.longitude;
		
		if (thisLatitude > maxLatitude) maxLatitude = thisLatitude;
		if (thisLatitude < minLatitude) minLatitude = thisLatitude;
		if (thisLongitude > maxLongitude) maxLongitude = thisLongitude;
		if (thisLongitude < minLongitude) minLongitude = thisLongitude;
	}
	
	MKCoordinateRegion myRegion;
	
	myRegion.center.latitude = (maxLatitude + minLatitude) / 2.0;
	myRegion.center.longitude = (maxLongitude + minLongitude) / 2.0;
	myRegion.span.latitudeDelta = (maxLatitude - minLatitude) + 0.05;
	myRegion.span.longitudeDelta = (maxLongitude - minLongitude) + 0.05;
	
	if (myRegion.span.latitudeDelta == 0.0) myRegion.span.latitudeDelta = 0.05;
	if (myRegion.span.longitudeDelta == 0.0) myRegion.span.longitudeDelta = 0.05;
	
	return myRegion;
}

@end
