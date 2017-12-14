//
//  CouponDetailsViewController.m
//  negotiator
//
//  Created by Vig Andrei on 1/23/12.
//  Copyright (c) 2012 Dot IT Mobile. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>
#import "CouponDetailsViewController.h"
#import "AppDelegate.h"
#import "HotOffersViewController.h"
#import "DetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "FavouritesBadgeManager.h"
#import "ZSPinAnnotation.h"
#import "Annotation.h"
#import "CouponRedeemViewController.h"
#import "TwitterController.h"
#import "ARViewController.h"
#import "RegionManager.h"


@import FirebaseMessaging;

@interface CouponDetailsViewController() <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>

@end

@implementation CouponDetailsViewController

@synthesize couponsInfo         = _couponsInfo;
@synthesize mapView             = _mapView;
@synthesize couponImage         = _couponImage;
@synthesize companyImage        = _companyImage;
@synthesize couponsDetailsView  = _couponsDetailsView;
@synthesize favouritesBtn       = _favoritesBtn;
@synthesize timer               = _timer;
@synthesize addToFavRequest     = _addToFavRequest;
@synthesize loadingView         = _loadingView;
@synthesize backBarBtn          = _backBarBtn;
@synthesize backToDetails       = _backToDetails;
@synthesize addressHeaderView   = _addressHeaderView;
@synthesize calendar            = _calendar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil couponsInfo:(Coupons *)coupons {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    self.couponsInfo = coupons;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(refreshCouponsLeft) 
                                                 name:@"couponUsed" 
                                               object:nil];  
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(setCouponToFavourites:)
                                                 name:@"addedToFavourites"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(removeCouponFromFavourites:)
                                                 name:@"removedFromFavourites"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopOpenRedeemSound)
                                                 name:@"stopOpenRedeemSound"
                                               object:nil];

    
    return self;
}
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.couponsInfo = nil;
    self.mapView = nil;
    self.favouritesBtn = nil;
    self.backBarBtn = nil;
    self.backToDetails = nil;
    self.couponsDetailsView = nil;
    self.mapView = nil;
        
    _couponsLeftLabel = nil;
    _couponTitle = nil;
    _companyName = nil;
    _distanceLabel = nil;
    _dayLeft = nil;
    _hoursLeft = nil;
    _minLeft = nil;
    _secLeft = nil;
    
    _useBtn = nil;
    _detailsBtn = nil;
    _locationBtn = nil;
    _shareBtn = nil;
    
    _backgroundImageView = nil;
    
    self.calendar = nil;
    
    [_theAudio release];
    
    if (self.timer && ([self.timer isValid])) {
        [self.timer invalidate];
        //        self.timer = nil;
    }
    
    if (self.addToFavRequest) {
        [self.addToFavRequest clearDelegatesAndCancel];
        self.addToFavRequest = nil;
    }
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
//- (void)loadView {
//    [super loadView];  
//}


-(void)onTimer : (NSTimer *) timer{
    
        NSUInteger components = NSDayCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit;
        
        NSDateComponents *dateComponents = [self.calendar components:components
                                                            fromDate:[NSDate date]
                                                              toDate:[self.couponsInfo endDate]
                                                             options:0];
        
        _dayLeft.text = [NSString stringWithFormat:@"%d",  [dateComponents day]];
        _hoursLeft.text = [NSString stringWithFormat:@"%d",[dateComponents hour]];
        _minLeft.text  = [NSString stringWithFormat:@"%d", [dateComponents minute]];
        _secLeft.text  = [NSString stringWithFormat:@"%d", [dateComponents second]];

    if(self.couponsInfo.endDate == [self.couponsInfo.endDate earlierDate:[NSDate date]]) {
   
        
        NSString *alertMessage = nil;
        
        alertMessage = NSLocalizedString(@"Sorry, this coupon has expired.", nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage
                                                        message:nil 
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
        alert.tag = 10;
        
        [alert show];
        [alert release];
        [self.timer invalidate];
    }

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL hasAddress = NO;
    
    if (![NSString isNilOrEmpty: self.couponsInfo.address1] || ![NSString isNilOrEmpty: self.couponsInfo.address2]) {
        if (![NSString isNilOrEmpty: self.couponsInfo.suburb] || ![NSString isNilOrEmpty: self.couponsInfo.postcode]) {
            hasAddress = YES;
        }
    }
    if (!hasAddress) {
        [_locationBtn setHidden:YES];
        [_distanceLabel setHidden:YES];
        [_useBtn setFrame:CGRectMake(207.0, 180.0, 99.0, 50.0)];
        [_detailsBtn setFrame:CGRectMake(207.0, 230.0, 99.0, 50.0)];
        [_shareBtn setFrame:CGRectMake(207.0, 280.0, 99.0, 50.0)];
    }

    //coupon image view
    _couponImage = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 145.0, 172.0, 211.0)];
    [_couponImage setContentMode:UIViewContentModeScaleAspectFit];
    [self.couponsDetailsView addSubview:_couponImage];
    [_couponImage release]; 
    
    //company image view
    _companyImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 43.0, 92.0, 92.0)];
    [_companyImage setContentMode:UIViewContentModeScaleAspectFit];
    [_companyImage setBackgroundColor:[UIColor clearColor]];
    [self.couponsDetailsView addSubview:_companyImage];
    [_companyImage release];   
    
    [_companyName setText: self.couponsInfo.company];
    [_couponTitle setText: self.couponsInfo.title];
    [_distanceLabel setText: self.couponsInfo.formattedDistance];
    
    if ([self.couponsInfo.couponsLeft isEqualToString:@"0"]) {
        [_couponsLeftLabel setAlpha:0.0];
        [_couponsNumberLeftLabel setAlpha:0.0];
        [_noCouponsLeft setAlpha:1.0];
    } else {
        [_couponsLeftLabel setAlpha:1.0];
        [_couponsNumberLeftLabel setAlpha:1.0];
        [_noCouponsLeft setAlpha:0.0];
//        [_couponsLeftLabel setText:[NSString stringWithFormat:@"Coupons Left"]];
        [_couponsNumberLeftLabel setText:[NSString stringWithFormat:@"%@", self.couponsInfo.couponsLeft]];
        
        NSString *string = _couponsNumberLeftLabel.text;
        NSLog(@"%u", string.length);
        
        if (string.length == 1) {
            [_couponsNumberLeftLabel setFrame:CGRectMake(190.0, 9.0, 26.0, 26.0)];
            [_couponsLeftLabel setText:[NSString stringWithFormat:@"Coupon Left"]];
            [_couponsLeftLabel setFrame:CGRectMake(220.0, 15.0, 80.0, 18.0)];
        } else if (string.length == 2) {
            [_couponsNumberLeftLabel setFrame:CGRectMake(197.0, 9.0, 26.0, 26.0)];
            [_couponsLeftLabel setText:[NSString stringWithFormat:@"Coupons Left"]];
            [_couponsLeftLabel setFrame:CGRectMake(225.0, 15.0, 80.0, 18.0)];
        } else if (string.length == 3) {
            [_couponsNumberLeftLabel setFrame:CGRectMake(197.0, 9.0, 30.0, 30.0)];
            [_couponsLeftLabel setText:[NSString stringWithFormat:@"Coupons Left"]];
            [_couponsLeftLabel setFrame:CGRectMake(230.0, 16.0, 80.0, 18.0)];
        } 
    }
    
    _addressHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 43.0)];
    
    UIImageView *addressBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"region_bar_bkgd.png"]];
    [_addressHeaderView addSubview:addressBackground];
    [addressBackground release];
    
    UILabel *fullAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0.0, 280.0, 43.0)];
    [fullAddressLabel setTextColor:[UIColor whiteColor]];
    [fullAddressLabel setTextAlignment:UITextAlignmentCenter];
    [fullAddressLabel setBackgroundColor:[UIColor clearColor]];
    [fullAddressLabel setNumberOfLines:2];
    [fullAddressLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [fullAddressLabel setText:self.couponsInfo.couponFullAddress];
    [_addressHeaderView addSubview:fullAddressLabel];
    [fullAddressLabel release];
    
    [_addressHeaderView setAlpha:0.0];
    //[self.view addSubview:_addressHeaderView];
    //[_addressHeaderView release];
    
    // hide map view
    [self.mapView setAlpha:0.0];
    [self.mapView setCenterCoordinate:self.couponsInfo.coordinate];
    [self.mapView setShowsUserLocation:YES];

    UIButton *favBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 30.0)];
    [favBtn addTarget:self action:@selector(addToFavourites:) forControlEvents:UIControlEventTouchUpInside];
    [favBtn setBackgroundImage:[UIImage imageNamed:@"heart_btn.png"] forState:UIControlStateNormal];
    
    _favoritesBtn = [[UIBarButtonItem alloc] initWithCustomView:favBtn];
    [favBtn release];
    
    if (!self.couponsInfo.isFavourite) 
    {
        [self.navigationItem setRightBarButtonItem:self.favouritesBtn animated:YES];
        if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
        {
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                               target:nil action:nil];
            negativeSpacer.width = -11;// it was -6 in iOS 6
            [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.favouritesBtn, nil] animated:NO];
        };
    }
    
    UIButton *zoomBtn = [[UIButton alloc] initWithFrame:CGRectMake(15.0, 145.0, 172.0, 211.0)];
    [zoomBtn addTarget:self action:@selector(goToCouponViewScreen:) forControlEvents:UIControlEventTouchUpInside];
    [zoomBtn setBackgroundImage:[UIImage imageNamed:@"magnifying_glass.png"] forState:UIControlStateNormal];
    [zoomBtn setShowsTouchWhenHighlighted:YES];
    [zoomBtn setAlpha:0.9];
    
    [self.couponsDetailsView addSubview:zoomBtn];
    [zoomBtn release];
    
    
    //back button from details view to hotOffers view
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 30.0)];
    [backButton addTarget:self action:@selector(goBackToList:) forControlEvents:UIControlEventTouchUpInside];
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
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.backBarBtn, nil] animated:NO];
    };
    
    UIButton *backToDetailsButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 30.0)];
    [backToDetailsButton addTarget:self action:@selector(switchToCouponDetails:) forControlEvents:UIControlEventTouchUpInside];
    [backToDetailsButton setBackgroundImage:[UIImage imageNamed:@"right_btn.png"] forState:UIControlStateNormal];
    [backToDetailsButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    [backToDetailsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    _backToDetails = [[UIBarButtonItem alloc] initWithCustomView:backToDetailsButton];
    [backToDetailsButton release];
    
    
    // Create the loading view shown when making the request
    _loadingView = [[LoadingView alloc] initWithFrame:self.view.bounds 
                                              message:NSLocalizedString(@"Loading ...", nil) 
                                          messageFont:[UIFont boldSystemFontOfSize:13.0]
                                                style:LoadingViewBlack
                                       roundedCorners:NO];
    [_loadingView setAlpha:0.0];
    [self.view addSubview:_loadingView];
    [_loadingView release];
    
    [self displayCouponImage];
    [self displayCompanyImage];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"favAnimation_sound" ofType:@"wav"];
    _theAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
    
    
    NSString *openRedeemScreenSoundPath = [[NSBundle mainBundle] pathForResource:@"openRedeemScreenSound" ofType:@"m4a"];
    _openRedeemSound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:openRedeemScreenSoundPath] error:NULL];

    self.calendar = [NSCalendar currentCalendar];

    if([UIScreen mainScreen].bounds.size.height >= 568.0f)
    {
        //spawn banner
        UIButton *bb = [[UIButton alloc]initWithFrame:
                        CGRectMake(([UIScreen mainScreen].bounds.size.width - 300)/2,
                                   [UIScreen mainScreen].bounds.size.height - 200,
                                   300.0f, 80.0f)];
        [bb setBackgroundImage:[UIImage imageNamed:@"coupon_banner.png"] forState:UIControlStateNormal];
        [bb addTarget:self
               action:@selector(bb:) forControlEvents:UIControlEventTouchUpInside];
        [bb setTag:-1944];
        [self.view addSubview:bb];
    }
    
    //gd
    UIButton *gd = [[UIButton alloc]initWithFrame:CGRectMake(10.0f, [UIScreen mainScreen].bounds.size.height - 205.0f, 300.0f, 60.0f)];
    [gd setBackgroundImage:[UIImage imageNamed:@"gd.png"] forState:UIControlStateNormal];
    [gd setTitle:@"GET DIRECTIONS TO HERE" forState:UIControlStateNormal];
    [gd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [gd addTarget:self
           action:@selector(gd:) forControlEvents:UIControlEventTouchUpInside];
    [gd setTag:-1945];
    [self.view addSubview:gd];
    [gd setHidden:YES];

    [self.view360 setAlpha:0.0f];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    if ([UIApplication.appDelegate.regionName isEqualToString:@""]) {
//     
//        NSString *regionId = [Utility getRegionIdFromRegionName:UIApplication.appDelegate.regionName];
//        
//        if ([[[RegionManager sharedInstance] region] regionId] != regionId) {
//            
//            
//        }
//    }
}

-(IBAction)view360Map
{
    ARViewController *ar = [[ARViewController alloc]initWithNibName:@"ARViewController" bundle:nil];
    [ar setCouponsArray:[NSArray arrayWithObject:self.couponsInfo]];
    UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:ar];
    [nc setNavigationBarHidden:YES];
    [self presentViewController:nc animated:YES completion:nil];
}

-(IBAction)gd:(id)sender
{
    if(!self.mapView.userLocation)
        return;
    
    //open Maps from where we are to this group
    double lat = self.couponsInfo.lat;
    double lng = self.couponsInfo.lon;
    NSString *googleMapUrlString = [NSString stringWithFormat:@"maps://maps.google.com/maps?saddr=%.6f,%.6f&daddr=%.6f,%.6f", self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude, lat, lng];
    NSLog(@"gmurl: %@", googleMapUrlString);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapUrlString]];
}

-(void)bb:(id)param
{
    //play full movie
    AppDelegate *adelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [adelegate playVideo:56];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if (self.couponsInfo.isRedeemed || [self.couponsInfo.couponsLeft isEqualToString:@"0"]) {
        [_useBtn setImage:[UIImage imageNamed:@"used_btn.png"] forState: UIControlStateNormal];
    }
    
    if ([self.couponsInfo.couponsLeft isEqualToString:@"0"]) {
        [_couponsLeftLabel setAlpha:0.0];
        [_couponsNumberLeftLabel setAlpha:0.0];
        [_noCouponsLeft setAlpha:1.0];
    } else {
        [_couponsLeftLabel setAlpha:1.0];
        [_couponsNumberLeftLabel setAlpha:1.0];
        [_noCouponsLeft setAlpha:0.0];
        [_couponsLeftLabel setText:[NSString stringWithFormat:@"Coupons Left"]];
        [_couponsNumberLeftLabel setText:[NSString stringWithFormat:@"%@", self.couponsInfo.couponsLeft]];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(onTimer:) 
                                                userInfo:nil 
                                                 repeats:YES];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    if (self.timer && ([self.timer isValid])) {
        [self.timer invalidate];
        //        self.timer = nil;
    }
}

- (void)viewDidUnload {
                    
    [super viewDidUnload];
}

- (void)displayCouponImage {
    
    if ([NSString isNilOrEmpty:self.couponsInfo.smallImageURL ]) {
        [self.couponImage setImage:[UIImage imageNamed:@"no_image.png"]];
    } else {

        [self.couponImage setImageWithURL:[NSURL URLWithString: self.couponsInfo.smallImageURL] placeholderImage:[UIImage imageNamed:@"no_image.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
    }
}


- (void)displayCompanyImage {
    
    NSString *imagePath = nil;
    
    if ([NSString isNilOrEmpty:self.couponsInfo.companyImageURL ]) {
        if ([NSString isNilOrEmpty:self.couponsInfo.thumbImageURL]) {
            [self.companyImage setImage:[UIImage imageNamed:@"no_image.png"]];
            return;
        } else {
            imagePath = self.couponsInfo.thumbImageURL;
        }
    } else {
        imagePath = self.couponsInfo.companyImageURL;
    }
        
    [self.companyImage setImageWithURL:[NSURL URLWithString: imagePath] placeholderImage:[UIImage imageNamed:@"no_image.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

- (void)refreshCouponsLeft {
    
     [self.couponsInfo setCouponsLeft:[NSString stringWithFormat:@"%d", [self.couponsInfo.couponsLeft intValue] - 1]];
    
    [_couponsLeftLabel setText:[NSString stringWithFormat:@"%d Coupons Left", [self.couponsInfo.couponsLeft intValue]]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:NSClassFromString(@"MKUserLocation")]) {
        return nil;
    }
    
	NSString *identifier = nil;
    
    if (![annotation isKindOfClass:NSClassFromString(@"MKUserLocation")]) {
        identifier = @"activitiesIdentifier";
    } else {
        identifier = @"userIdentifier";
    }
    
	MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	
	if (!annotationView) {
		annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
	}
	
    Annotation *a = (Annotation *)annotation;
    
    BOOL redeemedCoupon = [(Coupons *)annotation isRedeemed];
    
    if (redeemedCoupon || [self.couponsInfo.couponsLeft isEqualToString:@"0"]) {
        annotationView.image = [ZSPinAnnotation pinAnnotationWithColor:[UIColor grayColor]];// ZSPinAnnotation Being Used
    } else {
        annotationView.image = [ZSPinAnnotation pinAnnotationWithColor:[UIColor redColor]];// ZSPinAnnotation Being Used
    }
    
    annotationView.annotation = a;
    annotationView.enabled = YES;
    annotationView.calloutOffset = CGPointMake(-11,0);
    [annotationView setNeedsDisplay];
    [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
    [annotationView setCanShowCallout:YES];
    
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
    [leftView setClipsToBounds:YES];
    [leftView setContentMode:UIViewContentModeScaleAspectFit];
    Coupons *coupon = (Coupons *)annotation;
    
    NSString *imagePath = nil;
    
    if ([NSString isNilOrEmpty:coupon.companyImageURL ]) {
        if ([NSString isNilOrEmpty:coupon.thumbImageURL]) {
            [leftView setImage:[UIImage imageNamed:@"no_image.png"]];
        } else {
            imagePath = coupon.thumbImageURL;
        }
    } else {
        imagePath = coupon.companyImageURL;
    }

    
    [leftView setImageWithURL:[NSURL URLWithString: imagePath] placeholderImage:[UIImage imageNamed:@"no_image.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    
	MKAnnotationView *aV; 
	
    for (aV in views) {
		
        // Don't pin drop if annotation is user location
        if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
		
        // Check if current annotation is inside visible map rect, else go to next one
        MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
        if (!MKMapRectContainsPoint(_mapView.visibleMapRect, point)) {
            continue;
        }
		
        CGRect endFrame = aV.frame;
		
        // Move annotation out of view
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - self.view.frame.size.height, aV.frame.size.width, aV.frame.size.height);
		
        // Animate drop
        [UIView animateWithDuration:0.5 delay:0.04*[views indexOfObject:aV] options:UIViewAnimationCurveLinear animations:^{
			
            aV.frame = endFrame;
			
			// Animate squash
        }completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    aV.transform = CGAffineTransformMakeScale(1.0, 0.8);
					
                }completion:^(BOOL finished){
                    if (finished) {
                        [UIView animateWithDuration:0.1 animations:^{
                            aV.transform = CGAffineTransformIdentity;
                        }];
                    }
                }];
            }
        }];
    }
}//end


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    DetailsViewController *detailsController = [[DetailsViewController alloc]initWithCouponsInfo:self.couponsInfo];
    [self.navigationController pushViewController:detailsController animated:YES];
    [detailsController release];
}


#pragma mark - ASIHTTPRequest methods

- (void)addToFavourites:(id)sender {
    [self.loadingView show];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:self.couponsInfo.couponId forKey:@"coupon_id"];   
    
    self.addToFavRequest = [[RequestManager sharedInstance] requestWithMethodName:@"coupons/addToFavourites" 
                                                                                  methodType:@"GET" 
                                                                                  parameters:parameters
                                                                                    delegate:self 
                                                                                      secure:NO 
                                                                              withAuthParams:NO];
    
    [self.addToFavRequest setDidFinishSelector:@selector(addToFavRequestFinished:)];
    [self.addToFavRequest setDidFailSelector:@selector(addToFavRequestFailed:)];
    
    [self.addToFavRequest startAsynchronous];
}

- (void)addToFavRequestFinished:(ASIHTTPRequest *)request{
    
    [self.loadingView hide];
    
    NSString *responseString = [request responseString];
    id responseObject = [responseString JSONValue];
    
    if ([responseObject respondsToSelector:@selector(objectForKey:)]) {
        NSDictionary *errors = [responseObject objectForKey:@"errors"];
        NSString *deviceChannel = [responseObject objectForKey:@"channel"];
        
        if (errors) {
            NSString *errorMessage = [errors objectForKey:@"message"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMessage
                                                            message:nil 
                                                           delegate:nil 
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                                  otherButtonTitles:nil];
            alert.tag = 11;
            [alert show];
            [alert release];
            return;
        }
        
        if (![NSString isNilOrEmpty:deviceChannel]) {
            
            [[FIRMessaging messaging] subscribeToTopic:deviceChannel];
//            [PFPush subscribeToChannelInBackground:deviceChannel];
            // http://www.nmags.com/index.php/api/firebasenotification/getSelectedCattoken?tokennumber=ePsBnjjfmy8:APA91bFc8SLb-hprAc-QuPsC7D1fh8Q9qN0THNvKpsjZ8PIzTLivfkNnc_irx0ty26PV7gFLW3OHUs6kPxg5RqtPGFU6qH-hYTEfclUooNYDZY30I35fYCgHw6cjcB0GMj3leNluZYkl&coupan_id=4790
        }
    }
    
    self.couponsInfo.isFavourite = YES;
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    //animating the add to favourites part
    UIImageView *transformView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 416)];
    [transformView setBackgroundColor:[UIColor redColor]];
    [transformView setImage:[self screenshot]];
    [self.couponsDetailsView addSubview:transformView];
    [transformView release];
    
#if TARGET_OS_SIMULATOR 
    
#else 
    
    [self playAudio];
    
#endif
    
    
    
    NSNumber *incrementedBadgeNumber = [NSNumber numberWithInt:[[[FavouritesBadgeManager sharedInstance] badgeNumber] intValue] + 1];
    
    [[FavouritesBadgeManager sharedInstance] setBadgeNumber:[NSString stringWithFormat:@"%@",incrementedBadgeNumber]];
    [[FavouritesBadgeManager sharedInstance] saveBadgeNumber];
    
    [[[[self.tabBarController viewControllers] objectAtIndex:3] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%@",  [[FavouritesBadgeManager sharedInstance] badgeNumber]]];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[FavouritesBadgeManager sharedInstance] badgeNumber] intValue]];
    
    [UIView animateWithDuration:1.0 animations:^{
        [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];        
        transformView.transform = CGAffineTransformMakeRotation(M_PI * 0.45);
        transformView.frame = CGRectMake(235.0, 416.0, 0.0, 0.0);
    } completion:^(BOOL finished){
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.couponsInfo.couponId forKey:@"coupon_id"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addedToFavourites" 
                                                            object:nil 
                                                          userInfo:userInfo];
                
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"This coupon has been added to your favourites", nil)
                                                            message:nil 
                                                           delegate:nil 
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                                  otherButtonTitles:nil];
        [alertView setTag:12];
        [alertView show];
        [alertView release];   
    }];
    
}



- (void)addToFavRequestFailed:(ASIHTTPRequest *)request {
    [self.loadingView hide];
    
    NSString *alertMessage = nil;
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        alertMessage = NSLocalizedString(@"It seems you don't have a working internet connection. Please check your Network Settings and try again!", nil);
    } else {
        alertMessage = NSLocalizedString(@"We had a problem adding this coupon to favourites. Please try again later.", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage
                                                    message:nil 
                                                   delegate:nil 
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                          otherButtonTitles:nil];
    [alert setTag:13];
    [alert show];
    [alert release];
}

#pragma mark - UIButton - action methods

- (void)goBackToList:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goToCouponViewScreen:(id)sender {
    
    if (self.couponsInfo.isRedeemed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"You have already used this coupon today. Coupons can only be used once every 24hrs." 
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
        [alert setTag:14];
        [alert show];
        [alert release];
    } else if ([self.couponsInfo.couponsLeft isEqualToString:@"0"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"All coupons have been used. Please try again soon."
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    } else {
        //[self playOpenRedeemSreenSound];
        
        [Utility showCouponRedeemWithCoupon:self.couponsInfo onTarget:self.navigationController];
    }
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

- (IBAction)goToCompanyDetails:(id)sende{    
    DetailsViewController *detailsController = [[DetailsViewController alloc]initWithCouponsInfo:self.couponsInfo];
    [self.navigationController pushViewController:detailsController animated:YES];
    [detailsController release];
}

- (IBAction)goToShareCoupon:(id)sender
{

#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Sharing Options" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *facebookAction = [UIAlertAction actionWithTitle:@"Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self shareMessageToSocial:0];
    }];
    
    UIAlertAction *twitterAction = [UIAlertAction actionWithTitle:@"Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self shareMessageToSocial:1];
    }];
    
    UIAlertAction *emailAction = [UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self shareMessageToSocial:2];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:facebookAction];
    [alertController addAction:twitterAction];
    [alertController addAction:emailAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:true completion:nil];

#else

    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Sharing Options"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil otherButtonTitles:
                         @"Facebook",
                         @"Twitter",
                         @"Email",
                         nil];
    
    [as showInView:self.view];
    
#endif

}

#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

#else

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self shareMessageToSocial:buttonIndex];
}

#endif

- (void)shareMessageToSocial:(NSInteger)buttonIndex {
    
    //http://www.nmags.com/blacktown/chow/2814
    //http://www.nmags.com/camden-picton/chow/4348
    //http://www.nmags.com/the-shire/chow/4228
    //http://nmags.com/penrith/chow/3540
    //http://www.nmags.com/mtdruitt-stmarys/chow/1933
    

    [Utility getDynamicLinkWithCoupons:self.couponsInfo completion:^(NSURL * _Nullable shortURL, NSString * _Nullable shortStringURL, NSError * _Nullable error) {
        
        NSLog(@"Dynamic Link: %@", shortStringURL);
        
        if(buttonIndex == 0)
        {
            
            SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [fbSheet setCompletionHandler:^(SLComposeViewControllerResult result)
             {
                 switch (result)
                 {
                     case SLComposeViewControllerResultCancelled:
                         break;
                     case SLComposeViewControllerResultDone:
                     {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Successfully shared"
                                                                            delegate:self
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles:nil];
                         [alertView show];
                     }
                         break;
                     default:
                         break;
                 }
             }];
            
            NSString *description = [NSString stringWithFormat:@"Get the free Negotiator iPhone App to find coupons near you and to follow the latest news. Go to %@.", shortStringURL];
            [fbSheet setInitialText:description];
            [fbSheet addURL:[NSURL URLWithString:SERVER_URL]];
            
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

            [self presentViewController:fbSheet animated:YES completion:Nil];
#else
            [self presentModalViewController:fbSheet animated:YES];
#endif
            
        }
        else if(buttonIndex == 1)
        {
            
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result)
             {
                 switch (result)
                 {
                     case SLComposeViewControllerResultCancelled:
                         break;
                     case SLComposeViewControllerResultDone:
                     {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Successfully tweeted"
                                                                            delegate:self
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles:nil];
                         [alertView show];
                     }
                         break;
                     default:
                         break;
                 }
             }];
            
            //NSString *description = [NSString stringWithFormat:@"Get the free Negotiator iPhone App to find coupons near you and to follow the latest news. Go to %@.", WEBSITE_URL];
            NSString *description = [NSString stringWithFormat:@"Check out this great coupon I found on the free Negotiator App: %@", shortStringURL];
            [tweetSheet setInitialText:description];
            [tweetSheet addURL:[NSURL URLWithString:SERVER_URL]];
            
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
            
            [self presentViewController:tweetSheet animated:YES completion:Nil];
#else
            [self presentModalViewController:tweetSheet animated:YES];
            
#endif
        }
        else if(buttonIndex == 2)
        {
            //mail
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
                [mailComposer setDelegate:self];
                [mailComposer setMailComposeDelegate:self];
                [mailComposer setSubject:NSLocalizedString(@"Coupon from Negotiator Magazine App", nil)];
                [mailComposer setToRecipients:[NSArray arrayWithObject:@""]];
                [mailComposer setTitle:@""];
                [mailComposer setMessageBody:[NSString stringWithFormat:@" I found a great coupon from %@ on the Negotiator iPhone App.<br/><br/><b>%@</b><br/><br/>Get the free Negotiator iPhone App to find coupons near you and to follow the latest news. Go to %@.", self.couponsInfo.company, self.couponsInfo.title, shortStringURL]
                                      isHTML:YES];
                
                if ([[mailComposer navigationBar] respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
                    [[mailComposer navigationBar] setBackgroundImage:[UIImage imageNamed:@"infoNavBar_bkgd.png"]
                                                       forBarMetrics:UIBarMetricsDefault];
                }
                
                [[mailComposer navigationBar] setTintColor:[UIColor redNavColor]];
                
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
                
                [self.navigationController presentViewController:mailComposer animated:true completion:nil];
#else
                
                [self.navigationController presentModalViewController:mailComposer animated:YES];
#endif
                
                [mailComposer release];
                
                
            } else {
                NSString *message = NSLocalizedString(@"This device is not configured for sending emails!", nil);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                [alert show];
                [alert release];
            }
        }
    }];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
#else
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
#endif
}

//Switch between the map view and the details view
- (IBAction)switchToCouponLocation:(id)sender
{
    [UIView beginAnimations:@"switchToMap" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
	
    
    [self.mapView setAlpha:1.0];
    [self.addressHeaderView setAlpha:1.0];
	[self.couponsDetailsView setAlpha:0.0];
    [self.view360 setAlpha:1.0f];
    
	[UIView commitAnimations];
        
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem setLeftBarButtonItem:self.backToDetails animated:YES];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.backToDetails, nil] animated:NO];
        
        [[self.view viewWithTag:-1944] setHidden:YES];
        [[self.view viewWithTag:-1945] setHidden:NO];
    };
    
    [self.mapView addAnnotation:self.couponsInfo];
    [self.mapView setRegion:[MKMapView regionForAnnotations:[NSArray arrayWithObject:self.couponsInfo]]];
    [self.mapView selectAnnotation:self.couponsInfo animated:YES];
}

- (void)switchToCouponDetails:(id)sender{
    [UIView beginAnimations:@"switchToList" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:NO];
	
    [self.addressHeaderView setAlpha:0.0];
	[self.mapView setAlpha:0.0];
    [self.couponsDetailsView setAlpha:1.0];
	[self.view360 setAlpha:0.0f];
    
	[UIView commitAnimations];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem setLeftBarButtonItem:self.backBarBtn animated:YES];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.backBarBtn, nil] animated:NO];
        
        [[self.view viewWithTag:-1944] setHidden:NO];
        [[self.view viewWithTag:-1945] setHidden:YES];
    };
}

- (void)setCouponToFavourites:(NSNotification *)aNotif {
    NSDictionary *userInfo = [aNotif userInfo];
    NSString *couponID = [userInfo objectForKey:@"coupon_id"];
    
    if ([couponID isEqualToString:self.couponsInfo.couponId]) {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
}

- (void)removeCouponFromFavourites:(NSNotification *)aNotif {
    NSDictionary *userInfo = [aNotif userInfo];
    NSString *couponID = [userInfo objectForKey:@"coupon_id"];
    
    if ([couponID isEqualToString:self.couponsInfo.couponId]) {
        [self.navigationItem setRightBarButtonItem:self.favouritesBtn animated:YES];
        if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
        {
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                               target:nil action:nil];
            negativeSpacer.width = -11;// it was -6 in iOS 6
            [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.favouritesBtn, nil] animated:NO];
        };
    }
}

- (UIImage *)screenshot {
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) 
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark Audio method

-(void)playAudio{
    
    //play a sound when a coupon is added to favourite
    [_theAudio play];
}

- (void)playOpenRedeemSreenSound {
    _openRedeemSound.currentTime = 0;
    [_openRedeemSound play];
}

- (void)stopOpenRedeemSound {
    [_openRedeemSound stop];
}

#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == 10){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
