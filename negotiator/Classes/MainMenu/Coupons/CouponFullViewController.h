//
//  CouponFullViewController.h
//  negotiator
//
//  Created by Alexandru Chis on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Coupons.h"


@interface CouponFullViewController : MainController {
    IBOutlet UILabel        *_instructionsLabel;

    IBOutlet UIButton       *_tapButton;    
    
    IBOutlet UIImageView    *_backgroundImageView;
    IBOutlet UIImageView    *_instructionsImageView;
    
    Coupons                 *_coupons;
    
    UIBarButtonItem         *_backButton;

    UIImageView             *_couponImage;
}

@property (nonatomic, retain) Coupons               *couponsInfo;
@property (nonatomic, retain) UIImageView           *couponImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil couponsInfo:(Coupons *)coupons;

- (IBAction)goToRedeemScreen:(id)sender;

- (void)goBack:(id)sender;

- (void)displayCouponImage;

- (void)couponUsed;

@end
