//
//  Coupons.h
//  negotiator
//
//  Created by Alexandru Chis on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Category;

@interface Coupons : NSObject <MKAnnotation> {
    NSString    *_couponId;
    NSString    *_couponTitle;
    NSString    *_company;
    NSString    *_address1;
    NSString    *_address2;
    NSString    *_companyAddress;
    NSString    *_couponFullAddress;
    NSString    *_state;
    NSString    *_suburb;
    NSString    *_email;
    NSString    *_website;
    NSString    *_phone;
    NSString    *_contact;
    NSString    *_postcode;
    NSString    *_description;
    NSString    *_conditions;
    NSString    *_daysLeft;
    NSString    *_couponsLeft;
    NSString    *_thumbImageURL;
    NSString    *_largeImageURL;
    NSString    *_smallImageURL;
    NSString    *_reducedImageURL;  
    NSString    *_companyImageURL;
    
    NSArray<Category*>     *_category;
    
    double      _lat;
    double      _lon;
    double      _distance;
    NSDate      *_endDate;
    
    BOOL        _imageLoaded;
    BOOL        _isFavourite;
    BOOL        _isRedeemed;
    
    UIImage     *_image;
    
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic, retain) NSString    *couponFullAddress;
@property (nonatomic, retain) NSString    *companyAddress;
@property (nonatomic, retain) NSString    *couponTitle;
@property (nonatomic, retain) NSString    *couponId;
@property (nonatomic, retain) NSString    *company;
@property (nonatomic, retain) NSString    *address1;
@property (nonatomic, retain) NSString    *address2;
@property (nonatomic, retain) NSString    *state;
@property (nonatomic, retain) NSString    *suburb;
@property (nonatomic, retain) NSString    *postcode;
@property (nonatomic, retain) NSString    *description;
@property (nonatomic, retain) NSString    *conditions;
@property (nonatomic, retain) NSString    *email;
@property (nonatomic, retain) NSString    *website;
@property (nonatomic, retain) NSString    *phone;
@property (nonatomic, retain) NSString    *contact;
@property (nonatomic, retain) NSString    *thumbImageURL;
@property (nonatomic, retain) NSString    *reducedImageURL;
@property (nonatomic, retain) NSString    *largeImageURL;
@property (nonatomic, retain) NSString    *smallImageURL;
@property (nonatomic, retain) NSString    *companyImageURL;
@property (nonatomic, retain) NSString    *daysLeft;
@property (nonatomic, retain) NSString    *couponsLeft;

@property (nonatomic, retain) NSArray<Category*>     *category;

@property (nonatomic, retain) NSDate      *endDate;

@property (nonatomic, assign) double    lat;
@property (nonatomic, assign) double    lon;
@property (nonatomic, assign) double    distance;

@property (nonatomic, assign) BOOL      imageLoaded;
@property (nonatomic, assign) BOOL      isFavourite;
@property (nonatomic, assign) BOOL      isRedeemed;

@property (nonatomic, retain) UIImage   *image;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id)initWithCouponInfo:(NSDictionary *)info isSearch:(BOOL)isSearch;
- (id)initWithCouponInfo:(NSDictionary *)info;
- (NSString *)formattedAddress;
- (NSString *)formattedDistance;

- (void)setCouponToFavourites:(NSNotification *)aNotif;
- (void)removeCouponFromFavourites:(NSNotification *)aNotif;

- (void)couponUsed:(NSNotification *)aNotif;

@end

/************** Category **************/

@interface Category : NSObject {
    
    NSString    *_categoryId;
    NSString    *_categoryName;
    NSString    *_categoryDescription;
}
@property (nonatomic, retain) NSString    *categoryId;
@property (nonatomic, retain) NSString    *categoryName;
@property (nonatomic, retain) NSString    *categoryDescription;

- (id)initWithDictionary:(NSDictionary *)info;
- (id)initWithCategoryId:(NSString *)Id categoryName:(NSString *)name categoryDescription:(NSString *)description;

+ (NSArray*)categoryArrayWithResponse:(NSArray *)array;

@end
