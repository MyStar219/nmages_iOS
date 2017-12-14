//
//  CompanyDetailsCell.m
//  negotiator
//
//  Created by Andrei Vig on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CompanyDetailsCell.h"
#import "Coupons.h"
#import "AppDelegate.h"

@implementation CompanyDetailsCell

@synthesize companyImageView    = _companyImageView;
@synthesize companyName         = _companyName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    
    _companyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 5.0, 50.0, 50.0)];
    [_companyImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_companyImageView];
    [_companyImageView release];
    
    _companyName = [[UILabel alloc] initWithFrame:CGRectMake(90.0, 5.0, 200.0, 50.0)];
    [_companyName setBackgroundColor:[UIColor clearColor]];
    [_companyName setTextAlignment:UITextAlignmentCenter];
    [_companyName setFont:[UIFont boldSystemFontOfSize:14.0]];
    [self addSubview:_companyName];
    [_companyName release];
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithCoupon:(Coupons *)coupon {
    [self.companyImageView setImage:nil];
    [self.companyName setText:coupon.company];
    
    NSString *imagePath = nil;
    
    if ([NSString isNilOrEmpty:coupon.companyImageURL ]) {
        if ([NSString isNilOrEmpty:coupon.thumbImageURL]) {
            [self.companyImageView setImage:[UIImage imageNamed:@"no_image.png"]];
            return;
        } else {
            imagePath = coupon.thumbImageURL;
        }
    } else {
        imagePath = coupon.companyImageURL;
    }
    
    [self.companyImageView setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"no_image.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

@end
