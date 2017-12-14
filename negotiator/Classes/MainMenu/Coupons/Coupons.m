//
//  Coupons.m
//  negotiator
//
//  Created by Alexandru Chis on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Coupons.h"
#import "NSDictionary-Additions.h"

@implementation Coupons

@synthesize couponId            = _couponId;
@synthesize couponTitle         = _couponTitle;
@synthesize company             = _company;
@synthesize address1            = _address1;
@synthesize address2            = _address2;
@synthesize state               = _state;
@synthesize suburb              = _suburb;
@synthesize postcode            = _postcode;
@synthesize description         = _description;
@synthesize conditions          = _conditions;
@synthesize email               = _email;
@synthesize website             = _website;
@synthesize phone               = _phone;
@synthesize contact             = _contact;
@synthesize couponFullAddress   = _couponFullAddress;
@synthesize companyAddress      = _companyAddress;
@synthesize thumbImageURL       = _thumbImageURL;
@synthesize largeImageURL       = _largeImageURL;
@synthesize smallImageURL       = _smallImageURL;
@synthesize companyImageURL     = _companyImageURL;
@synthesize daysLeft            = _daysLeft;
@synthesize couponsLeft         = _couponsLeft;
@synthesize reducedImageURL     = _reducedImageURL;

@synthesize category            = _category;

@synthesize endDate             = _endDate;
@synthesize lat                 = _lat;
@synthesize lon                 = _lon;
@synthesize distance            = _distance;

@synthesize isFavourite         = _isFavourite;
@synthesize isRedeemed          = _isRedeemed;
@synthesize imageLoaded         = _imageLoaded;
@synthesize image               = _image;

@synthesize coordinate          = _coordinate;

/*
 "creation_date" = 1355450301;
 "update_date" = 1498089573;
 
 address1 = "";
 address2 = "";
 category =     (
 {
 "category_description" = "Everything for your home and more";
 "category_id" = 1;
 "category_name" = Abode;
 },
 {
 "category_description" = "Trades and services";
 "category_id" = 13;
 "category_name" = "Services in the City";
 }
 );
 company = "Pure Dry";
 "company_address" = ",,NSW";
 "company_thumb" = "http://www.nmags.com/media/images/company/thumbs/510b2a3e796ed_puredry.jpg";
 conditions = "";
 "contact_person" = "";
 "coupon_full_address" = ",,NSW";
 
 description = "";
 distance = "15.075637859611";
 email = "";
 "end_date" = 1501250340;
 id = 556;
 "large_image" = "http://www.nmags.com/media/images/coupon/fullsize/small/594b0864c9235_puerdry_HN110.jpg";
 lat = "-33.72925";
 lon = "151.00401999999997";
 "max_quantity" = 44;
 phone = "1300 363 150";
 postcode = "";
 "reduced_image" = "http://www.nmags.com/media/images/coupon/fullsize/small/594b0864c9235_puerdry_HN110.jpg";
 "small_image" = "http://www.nmags.com/media/images/coupon/reducedsize/large/";
 state = "New South Wales";
 suburb = "";
 "thumb_image" = "http://www.nmags.com/media/images/company/thumbs/510b2a3e796ed_puredry.jpg";
 title = "Professional Carpet Cleaning ";
 
 website = "www.puredry.com.au";
 
 */

/*
 "date_interval" = 17;
 "is_favourite" = 0;
 "is_redeemed" = 0;
  "start_interval" = 160484;
 
 address1 = "Unit 2";
 address2 = "11-13 Foundry Rd";
 "category_description" = "Mixed bargains";
 "category_id" = 3;
 "category_name" = "Bargain Bazaar";
 company = "The Hills Lounge & Sofas (Seven Hills)";
 "company_address" = "Unit 2, 11-13 Foundry Rd, Seven Hills, NSW";
 "company_thumb" = "http://www.nmags.com/media/images/company/thumbs/56159b167434d_the-hills-lounge--sofas.jpg";
 conditions = "";
 "contact_person" = "";
 "coupon_full_address" = "Unit 2, 11-13 Foundry Rd, Seven Hills, NSW";
 
 description = "";
 distance = "11039.33586919949";
 email = "";
 "end_date" = 1501855140;
 id = 4580;
 
 "large_image" = "http://www.nmags.com/media/images/coupon/fullsize/large/595494a00c09c_TheHillsLounge_PEN19.jpg";
 lat = "-33.7681418";
 lon = "150.9573137";
 "max_quantity" = 55;
 phone = "9838 8745";
 postcode = "";
 "reduced_image" = "http://www.nmags.com/media/images/coupon/fullsize/small/595494a00c09c_TheHillsLounge_PEN19.jpg";
 "small_image" = "http://www.nmags.com/media/images/coupon/reducedsize/large/595494a00c09c_TheHillsLounge_PEN19.jpg";

 state = "New South Wales";
 suburb = "Seven Hills";
 "thumb_image" = "";
 title = "Quality Lounges & Sofas";
 website = "thehillsloungeandsofas.com.au";
 
 */

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.couponId           = @"";
        self.couponTitle        = @"";
        self.company            = @"";
        self.category           = [[NSArray alloc] init];
        self.address1           = @"";
        self.address2           = @"";
        self.state              = @"";
        self.suburb             = @"";
        self.postcode           = @"";
        self.description        = @"";
        self.email              = @"";
        self.website            = @"";
        self.phone              = @"";
        self.contact            = @"";
        self.conditions         = @"";
        self.daysLeft           = @"";
        self.couponsLeft        = @"";
        self.thumbImageURL      = @"";
        self.largeImageURL      = @"";
        self.smallImageURL      = @"";
        self.companyImageURL    = @"";
        self.image              = nil;
        self.companyAddress     = @"";
        self.couponFullAddress  = @"";
        self.reducedImageURL    = @"";
        self.endDate            = [[NSDate alloc] init];
        
        self.lat                = 0;
        self.lon                = 0;
        self.distance           = 0;
        
        self.imageLoaded        = false;
        self.isFavourite        = false;
        self.isRedeemed         = false;
    }
    return self;
}

- (id)initWithCouponInfo:(NSDictionary *)info {

    return [self initWithCouponInfo:info isSearch:NO];
}

- (id)initWithCouponInfo:(NSDictionary *)info isSearch:(BOOL)isSearch {
    
    self = [super init];
    if (!self) return nil;

    self.couponId           = [info objectForKey:@"id"];
    self.couponTitle        = [info objectForKey:@"title"];
    self.company            = [info objectForKey:@"company"];
    
    if (isSearch) {
     
        self.category = [Category categoryArrayWithResponse:[info objectForKey:@"category"]];
    }
    else {
    
        self.category = [NSArray arrayWithObject:[[Category alloc] initWithCategoryId:[info objectForKey:@"category_id"] categoryName:[info objectForKey:@"category_name"] categoryDescription:[info objectForKey:@"category_description"]]];
    }
//    self.categoryId         = [info objectForKey:@"category_id"];
//    self.categoryName       = [info objectForKey:@"category_name"];
//    self.categoryDescription= [info objectForKey:@"category_description"];
    
    
    self.address1           = [info objectForKey:@"address1"];
    self.address2           = [info objectForKey:@"address2"];
    self.state              = [info objectForKey:@"state"];
    self.suburb             = [NSString isNilOrEmpty:[info objectForKey:@"suburb"]]? @"" : [info objectForKey:@"suburb"];
    self.postcode           = [NSString isNilOrEmpty:[info objectForKey:@"postcode"]]? @"" : [info objectForKey:@"postcode"];
    self.description        = [info objectForKey:@"description"];
    self.conditions         = [info objectForKey:@"conditions"];
    self.email              = [NSString isNilOrEmpty:[info objectForKey:@"email"]]? @"" :[info objectForKey:@"email"];
    self.website            = [NSString isNilOrEmpty:[info objectForKey:@"website"]]? @"" : [info objectForKey:@"website"];
    self.phone              = [NSString isNilOrEmpty:[info objectForKey:@"phone"]]? @"" :[info objectForKey:@"phone"];
    self.companyAddress     = [NSString isNilOrEmpty:[info objectForKey:@"company_address"]]? @"" : [info objectForKey:@"company_address"];
    self.couponFullAddress  = [NSString isNilOrEmpty:[info objectForKey:@"coupon_full_address"]]? @"" : [info objectForKey:@"coupon_full_address"];
    self.contact            = [NSString isNilOrEmpty:[info objectForKey:@"contact_person"]]? @"" : [info objectForKey:@"contact_person"];
   // self.daysLeft           = [info objectForKey:@"date_interval"];
    self.couponsLeft        = [info objectForKey:@"max_quantity"];
    
    
    
    self.isFavourite        = [info containsKey:@"is_favourite"] ? [[info objectForKey:@"is_favourite"] boolValue] : NO;
    self.isRedeemed         = [info containsKey:@"is_redeemed"] ? [[info objectForKey:@"is_redeemed"] boolValue] : NO;;
    self.thumbImageURL      = [info objectForKey:@"thumb_image"];
    self.reducedImageURL    = [info objectForKey:@"reduced_image"]? [info objectForKey:@"reduced_image"] : @"";
    
    if ([NSString isNilOrEmpty:self.thumbImageURL]) {
        self.thumbImageURL      = [info objectForKey:@"company_thumb"];        
    }
    self.largeImageURL      = [info objectForKey:@"large_image"];
    self.smallImageURL      = [info objectForKey:@"small_image"];
    self.companyImageURL    = [info objectForKey:@"company_thumb"];
    
    self.lat                = [[info objectForKey:@"lat"] doubleValue];
    self.lon                = [[info objectForKey:@"lon"] doubleValue];
    self.distance           = [[info objectForKey:@"distance"] doubleValue];
    double endDateInterval  = [[info objectForKey:@"end_date"] doubleValue];
    self.endDate            = [NSDate dateWithTimeIntervalSince1970:endDateInterval];
        
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.lat;
    coordinate.longitude = self.lon;
    
    [self setCoordinate:coordinate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(setCouponToFavourites:)
                                                 name:@"addedToFavourites"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(removeCouponFromFavourites:)
                                                 name:@"removedFromFavourites"
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self 
//                                             selector:@selector(couponUsed:) 
//                                                 name:@"couponUsed" 
//                                               object:nil];
    
    return self;
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.couponId           = nil;
    self.couponTitle        = nil;
    self.company            = nil;
    self.category           = nil;
    self.address1           = nil;
    self.address2           = nil;
    self.state              = nil;
    self.suburb             = nil;
    self.postcode           = nil;
    self.description        = nil;
    self.email              = nil;
    self.website            = nil;
    self.phone              = nil;
    self.contact            = nil;
    self.conditions         = nil;
    self.daysLeft           = nil;
    self.couponsLeft        = nil;
    self.thumbImageURL      = nil;
    self.largeImageURL      = nil;
    self.smallImageURL      = nil;
    self.companyImageURL    = nil;
    self.image              = nil;
    self.companyAddress     = nil;
    self.couponFullAddress  = nil;
    self.reducedImageURL    = nil;
    self.endDate            = nil;
    
    [super dealloc];
}

- (NSString *)formattedAddress {
    NSMutableString *formattedAddress = [NSMutableString string];
    
    if (![NSString isNilOrEmpty:self.address1]) {
        [formattedAddress appendString:self.address1];
    } else if (![NSString isNilOrEmpty:self.address2]) {
        [formattedAddress appendString:self.address2];
    }
    
    if ([NSString isNilOrEmpty:formattedAddress]) {
        [formattedAddress appendFormat:@"%@, %@ %@", self.suburb, self.state, self.postcode];
    } else {
        [formattedAddress appendFormat:@", %@", self.suburb];
    }
    
    return formattedAddress;
}

- (NSString *)formattedDistance {
    NSUInteger distance = self.distance;
    return [NSString stringWithFormat:@"Distance: %d km", distance];

}

#pragma mark - MKAnnotation methods
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
	_coordinate = newCoordinate;
}

- (NSString *)title {
	return self.couponTitle;
}

//#pragma mark - HJManagedImageDelegate methods
//-(void) managedImageSet:(HJManagedImageV*)mi {
//    
//    if(_imageLoaded == YES) {
//    self.imageLoaded = YES;
//    self.image = mi.image;
//    }
//    else if (mi.tag == 1111) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"largeCouponImageLoaded" 
//                                                            object:nil 
//                                                          userInfo:nil];
//    }
//    
//   else  if (mi.tag == 1112) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"retinaCouponImageLoaded" 
//                                                            object:nil 
//                                                          userInfo:nil];
//    }
//    
//}
//
//-(void) managedImageCancelled:(HJManagedImageV*)mi {
//    self.imageLoaded = NO;
//    self.image = nil;
//}

- (void)setCouponToFavourites:(NSNotification *)aNotif {
    NSDictionary *userInfo = [aNotif userInfo];
    NSString *couponID = [userInfo objectForKey:@"coupon_id"];
    
    if ([couponID isEqualToString:self.couponId]) {
        [self setIsFavourite:YES];
    }
}

- (void)removeCouponFromFavourites:(NSNotification *)aNotif {
    NSDictionary *userInfo = [aNotif userInfo];
    NSString *couponID = [userInfo objectForKey:@"coupon_id"];
    
    if ([couponID isEqualToString:self.couponId]) {
        [self setIsFavourite:NO];
    }
}

- (void)couponUsed:(NSNotification *)aNotif {
    NSDictionary *userInfo = [aNotif userInfo];
    NSString *couponID = [userInfo objectForKey:@"coupon_id"];
    
    if ([couponID isEqualToString:self.couponId]) {
        [self setCouponsLeft:[NSString stringWithFormat:@"%d", [self.couponsLeft intValue] - 1]];
    }
}

@end

@implementation Category

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.categoryId             = @"";
        self.categoryName           = @"";
        self.categoryDescription    = @"";
    }
    return self;
}

- (id)initWithCategoryId:(NSString *)Id categoryName:(NSString *)name categoryDescription:(NSString *)description {

    self.categoryId             = Id;
    self.categoryName           = name;
    self.categoryDescription    = description;
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)info {

    self.categoryId             = [info objectForKey:@"category_id"];
    self.categoryName           = [info objectForKey:@"category_name"];
    self.categoryDescription    = [info objectForKey:@"category_description"];
    
    return self;
}

+ (NSArray*)categoryArrayWithResponse:(NSArray *)array {

    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (NSDictionary *dict in array) {
        
        [resultArray addObject:[[Category alloc] initWithDictionary:dict]];
    }
    
    return resultArray;
}

- (void)dealloc {
    
    self.categoryId             = nil;
    self.categoryName           = nil;
    self.categoryDescription    = nil;
    
    [super dealloc];
}

@end
