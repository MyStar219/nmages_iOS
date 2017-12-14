//
//  CouponsCell.m
//  negotiator
//
//  Created by Alexandru Chis on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CouponsCell.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation CouponsCell

@synthesize couponLabel         = _couponLabel;
@synthesize companyLabel        = _companyLabel;
@synthesize distanceLabel       = _distanceLabel;
@synthesize managedImage        = _managedImage;
@synthesize coupons             = _coupons;
@synthesize usedLabel           = _usedLabel;
@synthesize background          = _background;
@synthesize noCouponsLeftLabel  = _noCouponsLeftLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    
    _background = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 92.0)];
    [_background setBackgroundColor:[UIColor whiteColor]];
    [self addSubview: _background];
    [_background release];
    
    _managedImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 92.0, 92.0)];
    [_managedImage setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_managedImage];
    [_managedImage release];
    
    _couponLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 0.0, 205.0, 42.0)];
    [_couponLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [_couponLabel setBackgroundColor:[UIColor clearColor]];
    [_couponLabel setNumberOfLines:2];
    [self addSubview:_couponLabel];
    [_couponLabel release];
    
    _companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 47.0, 150.0, 20.0)];
    [_companyLabel setFont:[UIFont systemFontOfSize:14.0]];
    [_companyLabel setTextColor:[UIColor blackColor]];
    [_companyLabel setBackgroundColor:[UIColor clearColor]];
    [_companyLabel setNumberOfLines:1];
    [self addSubview:_companyLabel];
    [_companyLabel release];
    
    _usedLabel = [[UILabel alloc] initWithFrame:CGRectMake(255.0, 39.0, 40.0, 15.0)];
    [_usedLabel setFont:[UIFont boldSystemFontOfSize:11.0]];
    [_usedLabel setTextColor:[UIColor whiteColor]];
    [_usedLabel setTextAlignment:UITextAlignmentCenter];
    [_usedLabel setText:NSLocalizedString(@"Used", nil)];
    [_usedLabel setBackgroundColor:[UIColor redColor]];
    [_usedLabel setNumberOfLines:1];
    [_usedLabel.layer setCornerRadius:4.0];
    [_usedLabel setAlpha:0.0];
    [self addSubview:_usedLabel];
    [_usedLabel release];
    
    _noCouponsLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(255.0, 20.0, 40.0, 15.0)];
    [_noCouponsLeftLabel setFont:[UIFont boldSystemFontOfSize:11.0]];
    [_noCouponsLeftLabel setTextColor:[UIColor whiteColor]];
    [_noCouponsLeftLabel setTextAlignment:UITextAlignmentCenter];
    [_noCouponsLeftLabel setText:NSLocalizedString(@"0 Left", nil)];
    [_noCouponsLeftLabel setBackgroundColor:[UIColor redColor]];
    [_noCouponsLeftLabel setNumberOfLines:1];
    [_noCouponsLeftLabel.layer setCornerRadius:4.0];
    [_noCouponsLeftLabel setAlpha:0.0];
    [self addSubview:_noCouponsLeftLabel];
    [_noCouponsLeftLabel release];
    
    _distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 68.0, 186.0, 15.0)];
    [_distanceLabel setTextAlignment:UITextAlignmentLeft];
    [_distanceLabel setBackgroundColor:[UIColor clearColor]];
    [_distanceLabel setFont:[UIFont systemFontOfSize:12.0]];
    [_distanceLabel setTextColor:[UIColor darkGrayColor]];
    [self addSubview:_distanceLabel];
    [_distanceLabel release];
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc {
    
    [super dealloc];
}

- (void)updateWithCoupons:(Coupons *)coupons{

    
    [self.managedImage setImage:nil];
    self.coupons = coupons;

    if (self.coupons.isRedeemed) {
        [self.usedLabel setAlpha:1.0];
        [self.noCouponsLeftLabel setAlpha:0.0];
        [self.background setBackgroundColor:[UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1.0]];
    } else if (self.coupons.isRedeemed && [self.coupons.couponsLeft intValue] == 0) {
        [self.usedLabel setAlpha:1.0];
        [self.noCouponsLeftLabel setAlpha:0.0];
        [self.background setBackgroundColor:[UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1.0]];
    } else if ([self.coupons.couponsLeft intValue] == 0) {
        [self.usedLabel setAlpha:0.0];
        [self.noCouponsLeftLabel setAlpha:1.0];
        [self.background setBackgroundColor:[UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1.0]];
    } else {
        [self.usedLabel setAlpha:0.0];
        [self.noCouponsLeftLabel setAlpha:0.0];
        [self.background setBackgroundColor:[UIColor whiteColor]];
    }

    [_couponLabel setText:self.coupons.couponTitle];
    [_companyLabel setText:self.coupons.company];
    
    if ([[LocationUtiliy sharedInstance]userAccepted]) {
        if ([self.coupons distance] > 0) {
            [_distanceLabel setText:[self.coupons formattedDistance]];
        } else {
            [_distanceLabel setText:@""];
        }
        
        [_distanceLabel setHidden:YES];
    } else {
        [_distanceLabel setHidden:YES];
    }
    
    if (![NSString isNilOrEmpty: self.coupons.address1] || ![NSString isNilOrEmpty: self.coupons.address2]) {
        if (![NSString isNilOrEmpty: self.coupons.suburb] || ![NSString isNilOrEmpty: self.coupons.postcode]) {
            [_distanceLabel setHidden:NO];
        }
    }
    
    if (!self.coupons.imageLoaded || (nil == self.coupons.image)){
        if ([NSString isNilOrEmpty:self.coupons.thumbImageURL ]) {
            [self.managedImage setImage:[UIImage imageNamed:@"no_image.png"]];
        } else {
            
            [self.managedImage setImageWithURL:[NSURL URLWithString: self.coupons.thumbImageURL] placeholderImage:[UIImage imageNamed:@"no_image.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
    } else {
        [self.managedImage setImage:[UIImage imageNamed:@"no_image.png"]];
    }
}


@end
