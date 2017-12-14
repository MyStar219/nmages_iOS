//
//  CouponRedeemViewController.m
//  negotiator
//
//  Created by Alexandru Chis on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CouponRedeemViewController.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation CouponRedeemViewController

@synthesize couponsInfo      = _couponsInfo;
@synthesize couponImage      = _couponImage;
@synthesize redeemRequest    = _redeemRequest;
@synthesize scrollView       = _scrollView;
@synthesize loadingViewImage = _loadingViewImage;
@synthesize bottomBarImage   = _bottomBarImage;
@synthesize bottomView       = _bottomView;

- (id)initWithCouponInfo:(Coupons *)coupons {

    self = [super init];
    if (!self) {
        return nil;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideLoadingView) 
                                                 name:@"largeCouponImageLoaded" 
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideActivityView) 
                                                 name:@"retinaCouponImageLoaded" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(failedToLoadCouponImage) 
                                                 name:@"largeCouponImageFailedToLoad" 
                                               object:nil];
    
    self.couponsInfo = coupons;
    
    _failedToLoad = NO;
    
    _optionsShowing = NO;
    
    return self;
}

- (void)dealloc {
    
    [_couponsInfo release];
    
    if (self.redeemRequest) {
        [self.redeemRequest clearDelegatesAndCancel];
        self.redeemRequest = nil;
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView{
    [super loadView];
    
    //back button from details view to hotOffers view
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 30.0)];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"home_btn.png"] forState:UIControlStateNormal];
    [backButton setTitle:NSLocalizedString(@"  Back", nil) forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    _backBarBtn = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton release];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem setLeftBarButtonItem:_backBarBtn animated:YES];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, _backBarBtn, nil] animated:NO];
    };
    
    CGFloat factor = 346.0f;
    if([[UIScreen mainScreen]bounds].size.height == 568)
    {
        factor = 430.0f;
    }
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 22.0, 320.0, factor)];
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 2.5;
    [_scrollView setDelegate:self];
    
    //coupon image view
    _couponImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, factor)];
    [_couponImage setBackgroundColor:[UIColor blackColor]];
    [_couponImage setContentMode:UIViewContentModeScaleAspectFit];
    
    [_scrollView addSubview:_couponImage];
    [_couponImage release]; 
    
    _loadingViewImage = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 40.0)];
    [_loadingViewImage setClipsToBounds:YES];
//    [_loadingViewImage setBackgroundColor:[UIColor blackColor]];
    [_loadingViewImage.layer setCornerRadius:4.0];
    [_loadingViewImage.layer setBorderColor:[[UIColor grayColor] CGColor]]; 
    [_loadingViewImage.layer setBorderWidth:0.0];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 40.0)];
    [backView setBackgroundColor:[UIColor blackColor]];
    [backView setAlpha:0.6];
    [_loadingViewImage addSubview:backView];
    [backView release];
    
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 51.0, 63.0)];
    [loadingLabel setBackgroundColor:[UIColor clearColor]];
    [loadingLabel setTextAlignment:UITextAlignmentCenter];
    [loadingLabel setNumberOfLines:0.0];
    [loadingLabel setFont:[UIFont boldSystemFontOfSize:11.0]];
    [loadingLabel setTextColor:[UIColor whiteColor]];
    [loadingLabel setText:NSLocalizedString(@"Loading", nil)];
    [_loadingViewImage addSubview:loadingLabel];
    [loadingLabel release];
    
    UIActivityIndicatorView   *loadingWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingWheel startAnimating];
    [loadingWheel setCenter:CGPointMake(25.0, 15.0)];
    [_loadingViewImage addSubview:loadingWheel];
    [loadingWheel release];
        
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    
    [_scrollView addGestureRecognizer:doubleTap];
    [_scrollView addGestureRecognizer:singleTap];
    
    [singleTap release];
    [doubleTap release];

    
    [self.view addSubview: _scrollView];
    [_scrollView release];

    [self.view addSubview:_loadingViewImage];
    [_loadingViewImage setAlpha:0.0];
    [_loadingViewImage release];
    
    // Create the loading view shown when making the request
    _loadingView = [[LoadingView alloc] initWithFrame:self.view.bounds 
                                              message:NSLocalizedString(@"Loading ...", nil) 
                                          messageFont:[UIFont boldSystemFontOfSize:13.0]
                                                style:LoadingViewBlack
                                       roundedCorners:NO];
    [self.view addSubview:_loadingView];
    [_loadingView hide];
    [_loadingView release];
    
    //play a sound when a coupon is added to favourites
    NSString *path = [[NSBundle mainBundle] pathForResource:@"useCoupon_sound" ofType:@"wav"];
    _theAudio=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    
    // create the view that will execute our animation
    UIImageView* subHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 22.0)];
    
    // load all the frames of our animation
    subHeaderView.animationImages = [NSArray arrayWithObjects:
                                    [UIImage imageNamed:@"sub_header2.png"],
                                    [UIImage imageNamed:@"sub_header1.png"], nil];
    
    // all frames will execute in 1.75 seconds
    subHeaderView.animationDuration = 3.7;
    // repeat the annimation forever
    subHeaderView.animationRepeatCount = 0;
    // start animating
    [subHeaderView startAnimating];
    // add the animation view to the main window 
    [self.view addSubview:subHeaderView];
    [subHeaderView release]; 

    //set the view that will hold the custom button
    CGFloat factorx = 367.0f;
    if([[UIScreen mainScreen]bounds].size.height == 568)
    {
        factorx = 455.0f;
    }
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0, factorx, 320.0, 71.0)];
    
    UIImageView *bottomViewBkgd = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom_bar.png"]];
    [self.bottomView addSubview:bottomViewBkgd];
    [bottomViewBkgd release];
    
    UIButton *zoomBtn = [[UIButton alloc] initWithFrame:CGRectMake(125.0, -20.0, 71.0, 71.0)];
    [zoomBtn addTarget:self action:@selector(showCouponOptions:) forControlEvents:UIControlEventTouchUpInside];
//    [zoomBtn setBackgroundImage:[UIImage imageNamed:@"nButton.png"] forState:UIControlStateNormal];
    [zoomBtn setImage:[UIImage imageNamed:@"nButton"] forState:UIControlStateNormal];
    [zoomBtn setImage:[UIImage imageNamed:@"nButtonPressed"] forState:UIControlStateHighlighted];
    
    [self.bottomView addSubview:zoomBtn];
    [zoomBtn release];
    
    
    bottomViewBkgd.animationImages = [NSArray arrayWithObjects:
                                    [UIImage imageNamed:@"arrows_animation1.png"],
                                    [UIImage imageNamed:@"arrows_animation2.png"],
                                    [UIImage imageNamed:@"arrows_animation3.png"],
                                    [UIImage imageNamed:@"arrows_animation4.png"],nil];
    
    // all frames will execute in 1.75 seconds
    bottomViewBkgd.animationDuration = 1.7;
    // repeat the annimation forever
    bottomViewBkgd.animationRepeatCount = 0;
    // start animating
    [bottomViewBkgd startAnimating];

    [self.view addSubview:self.bottomView];
    [self.bottomView release];
    
    if([[[UIDevice currentDevice]systemVersion]floatValue] < 7.0f)
    {
        UIButton *qBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 30.0)];
        [qBtn addTarget:self action:@selector(pv:) forControlEvents:UIControlEventTouchUpInside];
        [qBtn setBackgroundImage:[UIImage imageNamed:@"info_btn_square.png"] forState:UIControlStateNormal];
        [qBtn setTitle:NSLocalizedString(@"Help", nil) forState:UIControlStateNormal];
        [qBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        
        UIView *qView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 30.0)];
        [qView addSubview:qBtn];
        [qBtn release];
        
        UIBarButtonItem *qButton = [[UIBarButtonItem alloc] initWithCustomView:qView];
        self.navigationItem.rightBarButtonItem = qButton;
    }
    else 
    {
        UIButton *qBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 30.0)];
        [qBtn addTarget:self action:@selector(pv:) forControlEvents:UIControlEventTouchUpInside];
        [qBtn setBackgroundImage:[UIImage imageNamed:@"info_btn_square.png"] forState:UIControlStateNormal];
        [qBtn setTitle:NSLocalizedString(@"Help", nil) forState:UIControlStateNormal];
        [qBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        
        UIView *qView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 30.0)];
        [qView addSubview:qBtn];
        [qBtn release];
        
        UIBarButtonItem *qButton = [[UIBarButtonItem alloc] initWithCustomView:qView];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, qButton, nil] animated:NO];
    };

}

-(void)pv:(id)param
{
    AppDelegate *adelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [adelegate playVideo:56];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = _couponImage.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    _couponImage.frame = contentsFrame;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad{
    [super viewDidLoad];
    
    /*if([[UIScreen mainScreen]bounds].size.height == 568)
    {
        CGRect frame = _loadingView.frame;
        frame.size.height += 20.0f;
        _loadingView.frame = frame;
    }*/
    [self.loadingViewImage setCenter:CGPointMake(self.view.center.x, self.view.center.y - 16) ];
    
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
        
        NSString *imageURLString = @"";
        
        if ([UIApplication supportsRetinaDisplay]) {
            imageURLString = self.couponsInfo.smallImageURL;
        } else {
            imageURLString = self.couponsInfo.largeImageURL;
        }
        
        if (![imageURLString isEqualToString:@""]) {
           
            [self.couponImage setImageWithURL:[NSURL URLWithString:imageURLString] placeholderImage:[UIImage imageNamed:@"no_image.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        else {
        
            [self.couponImage setImage:[UIImage imageNamed:@"no_image.png"]];
        }
        
    }

}

- (void)hideLoadingView {

    if ([UIApplication supportsRetinaDisplay]) {

        [self.couponImage setImageWithURL:[NSURL URLWithString:self.couponsInfo.largeImageURL] placeholderImage:[UIImage imageNamed:@"no_image.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
}

- (void)hideActivityView {
    [_loadingViewImage setAlpha:0.0];
}

- (void)failedToLoadCouponImage {
    
    _failedToLoad = YES;
    
    [self performSelector:@selector(goBackToCouponDetails:) withObject:nil afterDelay:1];

}


- (void)showCouponOptions:(id)sender {
    
    _optionsShowing = YES;
    
    UIActionSheet *as = [[UIActionSheet alloc]initWithTitle:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:@"Use Coupon Now", nil];

    
    [as setDelegate:self];
    [as showInView:self.view];
}

- (void)goBackToCouponDetails:(id)sender{
   
    if (_failedToLoad) {
        
        [self.couponImage setImage:nil];
        
        NSString *alertMessage = NSLocalizedString(@"It seems you don't have a working internet connection. Please try again later!", nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage
                                                        message:nil 
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)redeemCoupon:(id)sender{
    [_loadingView show];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:self.couponsInfo.couponId forKey:@"coupon_id"];   
    
    self.redeemRequest = [[RequestManager sharedInstance] requestWithMethodName:@"coupons/redeemCoupon" 
                                                                                  methodType:@"GET" 
                                                                                  parameters:parameters
                                                                                    delegate:self 
                                                                                      secure:NO 
                                                                              withAuthParams:NO];
    
    [self.redeemRequest setTimeOutSeconds:20];
    [self.redeemRequest setDidFinishSelector:@selector(redeemRequestFinished:)];
    [self.redeemRequest setDidFailSelector:@selector(redeemRequestFailed:)];
    
    [self.redeemRequest startAsynchronous];
}

#pragma mark - ASIHTTPRequest methods

- (void)redeemRequestFinished:(ASIHTTPRequest *)request{
    
    [_loadingView hide];
    
    NSString *responseString = [request responseString];
    id responseObject = [responseString JSONValue];
    
    if ([responseObject respondsToSelector:@selector(objectForKey:)]) {
        NSDictionary *errors = [responseObject objectForKey:@"errors"];
        if (errors) {
            NSString *errorMessage = [errors objectForKey:@"message"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMessage
                                                            message:nil 
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                                  otherButtonTitles:nil];
            [alert setTag:1113];
            [alert show];
            [alert release];
            return;
        }
        
        int status = [[responseObject objectForKey:@"status"] intValue];
        if (status == 1) {

            [self playAudio];
            [self.couponsInfo setIsRedeemed:YES];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.couponsInfo.couponId forKey:@"coupon_id"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"couponUsed" 
                                                                object:nil
                                                              userInfo:userInfo];
            
            [self performSelector:@selector(goBackToCouponDetails:)];
        }
    } else {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"We had a problem using this coupon. Please try again later.", nil)
                                                        message:nil 
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
        [alert setTag:1115];
        [alert show];
        [alert release];
    }
}

- (void)redeemRequestFailed:(ASIHTTPRequest *)request {
    [_loadingView hide];
    
    NSString *alertMessage = nil;
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        alertMessage = NSLocalizedString(@"It seems you don't have a working internet connection. Please check your Network Settings and try again!", nil);
    } else {
        alertMessage = NSLocalizedString(@"We had a problem using this coupon. Please try again later.", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage
                                                    message:nil 
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                          otherButtonTitles:nil];
    [alert setTag:1111];
    [alert show];
    [alert release];
}

#pragma mark Audio method

-(void)playAudio{
    
//    theAudio.delegate=nil;
    [_theAudio play];
    
} 

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        /*NSString *alertMessage = nil;
        
        alertMessage = NSLocalizedString(@"Are you sure you want to use this coupon now? Coupons can only be used once every 24 hours.", nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:alertMessage 
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                               otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
        [alert setTag:11199];
        [alert show];
        [alert release];*/
        
        [self performSelector:@selector(redeemCoupon:)]; 
        

//        [self performSelector:@selector(redeemCoupon:)];
    } else {
        [self performSelector:@selector(goBackToCouponDetails:)];        
    }
}

#pragma mark - UIScrollView delegate

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)inScroll {
    
    return _couponImage;
}

- (void) handleSingleTap:(UITapGestureRecognizer*)recognizer  {

//    _tapCount = 1;
//    
//    [self performSelector:@selector(countTaps) withObject:nil afterDelay:0.3];
}

- (void) handleDoubleTap:(UITapGestureRecognizer*)recognizer  {
    _tapCount = 2;
    
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale){
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES]; 
    } else {
        [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
    }
}

- (void)countTaps {
//    if (_tapCount == 1 && !_optionsShowing) {
//        [self showCouponOptions:nil];
//    }
}

#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    _optionsShowing = NO;
    
    if (alertView.tag == 11199)
    {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            [self performSelector:@selector(redeemCoupon:)];        
        } else {
            [self performSelector:@selector(goBackToCouponDetails:)]; 
        }
    } else {
        [self performSelector:@selector(goBackToCouponDetails:)];     
    }
}

- (void)goBack:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"stopOpenRedeemSound" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
