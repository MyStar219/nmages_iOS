//
//  Magazines.h
//  negotiator
//
//  Created by Alexandru Chis on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Magazines : NSObject <MKAnnotation> {
    NSString    *_name;
    NSString    *_photoPerson;
    NSString    *_address1;
    NSString    *_address2;
    NSString    *_state;
    NSString    *_suburb;
    NSString    *_postcode;
    NSString    *_phone;
    NSString    *_thumbImageURL;
    NSString    *_detailImageURL;
    
    double      _lat;
    double      _lon;
    double      _distance;
    
    BOOL        _imageLoaded;
    
    UIImage     *_image;
    
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic, retain) NSString    *name;
@property (nonatomic, retain) NSString    *photoPerson;
@property (nonatomic, retain) NSString    *address1;
@property (nonatomic, retain) NSString    *address2;
@property (nonatomic, retain) NSString    *state;
@property (nonatomic, retain) NSString    *suburb;
@property (nonatomic, retain) NSString    *postcode;
@property (nonatomic, retain) NSString    *phone;
@property (nonatomic, retain) NSString    *thumbImageURL;
@property (nonatomic, retain) NSString    *detailImageURL;

@property (nonatomic, assign) double    lat;
@property (nonatomic, assign) double    lon;
@property (nonatomic, assign) double    distance;

@property (nonatomic, assign) BOOL      imageLoaded;

@property (nonatomic, retain) UIImage   *image;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id)initWithMagazineInfo:(NSDictionary *)info;

- (NSString *)formattedAddress;
- (NSString *)formattedDistance;

@end
