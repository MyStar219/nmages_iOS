//
//  CouponFullViewController.m
//  negotiator
//
//  Created by Alexandru Chis on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CouponFullViewController.h"
#import "CouponRedeemViewController.h"
#import "AppDelegate.h"

@implementation CouponFullViewController

@synthesize couponsInfo = _couponsInfo;
@synthesize couponImage = _couponImage;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil couponsInfo:(Coupons *)coupons {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    self.couponsInfo = coupons;
    
    return self;
}

- (void)dealloc {
    
    [_couponsInfo release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_instructionsLabel setText:@"Present phone to store person as shown.\nTap the screen when ready to use."];
    [_instructionsLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 30.0)];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"home_btn.png"] forState:UIControlStateNormal];
    [backButton setTitle:NSLocalizedString(@"  Back", nil) forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton release];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem setLeftBarButtonItem:backBarButton animated:YES];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, backBarButton, nil] animated:NO];
    };
    [backBarButton release];
    
    //coupon image view
    _couponImage = [[UIImageView alloc] initWithFrame:CGRectMake(99.0, 74.0, 152.0, 228.0)];
    [_couponImage setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:_couponImage];
    [_couponImage release]; 
    
    [self displayCouponImage];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UIButton actions

- (void)displayCouponImage{
    if ([NSString isNilOrEmpty:self.couponsInfo.largeImageURL ]) {
        [self.couponImage setImage:[UIImage imageNamed:@"no_image.png"]];
    } else {
        
        [self.couponImage setImageWithURL:[NSURL URLWithString: self.couponsInfo.smallImageURL] placeholderImage:[UIImage imageNamed:@"no_image.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
}

- (void)goBack:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goToRedeemScreen:(id)sender {
    
    
    [Utility showCouponRedeemWithCoupon:self.couponsInfo onTarget:self.navigationController];
}

- (void)couponUsed{

    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:NO];
    
    if (self.couponsInfo.isRedeemed) {
        NSString *alertMessage = nil;
        
        alertMessage = NSLocalizedString(@"Coupon used. Thank you.", nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage
                                                        message:nil 
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];

    }
}

@end
