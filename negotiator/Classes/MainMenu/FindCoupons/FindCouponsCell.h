//
//  FindCouponsCell.h
//  negotiator
//
//  Created by Alexandru Chis on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Coupons.h"

@interface FindCouponsCell : UITableViewCell {
    UILabel         *_couponLabel;
    UILabel         *_companyLabel;
    UILabel         *_distanceLabel;
    UILabel         *_usedLabel;
    UILabel         *_noCouponsLeftLabel;
    
    UIView          *_background;
    
    UIImageView     *_managedImage;
    
    Coupons         *_coupons;
}

@property (nonatomic, retain) UILabel           *couponLabel;
@property (nonatomic, retain) UILabel           *companyLabel;
@property (nonatomic, retain) UILabel           *distanceLabel;
@property (nonatomic, retain) UILabel           *usedLabel;
@property (nonatomic, retain) UILabel           *noCouponsLeftLabel;

@property (nonatomic, retain) UIView            *background;

@property (nonatomic, retain) UIImageView       *managedImage;

@property (nonatomic, retain) Coupons           *coupons;

- (void)updateWithCoupons:(Coupons *)coupons;

@end
