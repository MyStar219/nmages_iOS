//
//  CompanyDetailsCell.h
//  negotiator
//
//  Created by Andrei Vig on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Coupons;

@interface CompanyDetailsCell : UITableViewCell {
    UIImageView *_companyImageView;
    UILabel *_companyName;
}

@property (nonatomic, retain) UIImageView *companyImageView;
@property (nonatomic, retain) UILabel *companyName;

- (void)updateWithCoupon:(Coupons *)coupon;

@end
