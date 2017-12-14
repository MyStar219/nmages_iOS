//
//  FindCouponsViewController.m
//  negotiator
//
//  Created by Alexandru Chis on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HotOffersViewController.h"
#import "RequestManager.h"
#import "Reachability.h"
#import "JSON.h"
#import "RegionManager.h"
#import "Coupons.h"
#import "CouponsCell.h"
#import "CouponDetailsViewController.h"
#import "SelectRegionController.h"
#import "FavouritesBadgeManager.h"
#import "ZSPinAnnotation.h"
#import "Annotation.h"
#import "ARViewController.h"

@implementation HotOffersViewController

@synthesize mapView             = _mapView;
@synthesize hotOffersArray      = _hotOffersArray;
@synthesize tableView           = _tableView;
@synthesize regionLabel         = _regionLabel;
@synthesize hotOffersRequest    = _hotOffersRequest;
@synthesize mapButton           = _mapButton;
@synthesize listButton          = _listButton;
@synthesize view360 = _view360;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    UIImage *couponImage = [UIImage imageNamed:@"hotOffers_icon.png"];
    UITabBarItem *couponTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Hot Coupons"
                                                                   image:couponImage 
                                                                     tag:0];
    
    // Add the item to the tab bar.
    self.tabBarItem = couponTabBarItem;
    [couponTabBarItem release];  
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(regionWasChanged:) 
                                                 name:@"regionWasChanged"
                                               object:nil];
    
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.hotOffersArray = nil;
    self.mapButton      = nil;
    self.listButton     = nil;
    
    
    if (self.hotOffersRequest) {
        [self.hotOffersRequest clearDelegatesAndCancel];
        self.hotOffersRequest = nil;
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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
    
    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:self.view.frame];
    backgroundView.image = [UIImage imageNamed:@"info_bkgd.png"];
    [self.view addSubview:backgroundView];
    [backgroundView release];
    
    // Create the region view containing: region label, button for changing region
    UIView *regionView = [[UIView alloc] initWithFrame:
                          CGRectMake(0.0, 0.0,
                                     [UIScreen mainScreen].bounds.size.width, 43.0)];
    
    UIImageView *regionBackground = [[UIImageView alloc] initWithFrame:
                                     CGRectMake(0, 0,
                                                [UIScreen mainScreen].bounds.size.width, 44)];
    regionBackground.image = [UIImage imageNamed:@"region_bar_bkgd.png"];
    [regionView addSubview:regionBackground];
    [regionBackground release];
    
    UIButton *changeRegionBtn = [[UIButton alloc] initWithFrame:
                                 CGRectMake(([UIScreen mainScreen].bounds.size.width - 116),
                                            7.0,
                                            106.0, 30.0)];
    [changeRegionBtn setBackgroundImage:[UIImage imageNamed:@"changeRegion_btn.png"] forState:UIControlStateNormal];
    [changeRegionBtn addTarget:self action:@selector(changeRegion:) forControlEvents:UIControlEventTouchUpInside];
    [regionView addSubview:changeRegionBtn];
    [changeRegionBtn release];
    
    _regionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10.0, 120.0, 21.0)];
    [_regionLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
    [_regionLabel setTextAlignment:UITextAlignmentLeft];
    [_regionLabel setTextColor:[UIColor whiteColor]];
    [_regionLabel setBackgroundColor:[UIColor clearColor]];
    [_regionLabel setText:[[[RegionManager sharedInstance] region] regionName]];
    [regionView addSubview:_regionLabel];
    [_regionLabel release];
    
    [self.view addSubview:regionView];  
    [regionView release];
    
    _noCouponsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 100.0, 280.0, 100.0)];
    [_noCouponsLabel setBackgroundColor:[UIColor clearColor]];
    [_noCouponsLabel setTextAlignment:UITextAlignmentCenter];
    [_noCouponsLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    [_noCouponsLabel setNumberOfLines:0.0];
    [_noCouponsLabel setTextColor:[UIColor whiteColor]];
    [_noCouponsLabel setShadowColor:[UIColor blackColor]];
    [_noCouponsLabel setShadowOffset:CGSizeMake(-0.5, 0.5)];
    [_noCouponsLabel setAlpha:0.0];
    [self.view addSubview:_noCouponsLabel];
    [_noCouponsLabel release];

    
    _tableView = [[UITableView alloc] initWithFrame:
                  CGRectMake(0.0, 43.0,
                             [UIScreen mainScreen].bounds.size.width,
                             [UIScreen mainScreen].bounds.size.height)
                                              style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setRowHeight:92.0];
    [self.view addSubview:_tableView];
    [_tableView release];
    
    self.view360 = [[UIButton alloc]initWithFrame:
                    CGRectMake(0.0f, 0.0f,
                               [UIScreen mainScreen].bounds.size.width, 40.0f)];
    [self.view360 setBackgroundImage:[UIImage imageNamed:@"view360.png"] forState:UIControlStateNormal];
    [self.view360 addTarget:self action:@selector(view360Map) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.view360];
    [self.view360 setAlpha:0.0f];
    _mapView = [[MKMapView alloc] initWithFrame:
                CGRectMake(0.0, 40.0,
                           [UIScreen mainScreen].bounds.size.width, 326.0)];
    [_mapView setDelegate:self];
    [_mapView setShowsUserLocation:YES];
    [_mapView setAlpha:0.0];
    [self.view addSubview:_mapView];
    [_mapView release];
    
    if([[UIScreen mainScreen]bounds].size.height == 568)
    {
        [_mapView setFrame:CGRectMake(_mapView.frame.origin.x, _mapView.frame.origin.y, _mapView.frame.size.width, _mapView.frame.size.height + 90.0f)];
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height + 90.0f)];
    }
    
    _loadingView = [[LoadingView alloc] initWithFrame:self.view.bounds 
                                              message:NSLocalizedString(@"Loading ...", nil) 
                                          messageFont:[UIFont boldSystemFontOfSize:13.0]
                                                style:LoadingViewBlack
                                       roundedCorners:NO];
    [_loadingView setAlpha:0.0];
    [self.view addSubview:_loadingView];
    [_loadingView release];

}

-(void)view360Map
{
    ARViewController *ar = [[ARViewController alloc]initWithNibName:@"ARViewController" bundle:nil];
    [ar setCouponsArray:self.hotOffersArray];
    [self presentViewController:ar animated:YES completion:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 30.0)];
    [homeButton addTarget:self action:@selector(goToHomePage:) forControlEvents:UIControlEventTouchUpInside];
    [homeButton setBackgroundImage:[UIImage imageNamed:@"home_btn.png"] forState:UIControlStateNormal];
    [homeButton setTitle:NSLocalizedString(@"  Home", nil) forState:UIControlStateNormal];
    [homeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
    [homeButton release];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem setLeftBarButtonItem:backButton animated:YES];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, backButton, nil] animated:NO];
    };
    [backButton release];
        
    
    UIButton *mapBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 30.0)];
    [mapBtn addTarget:self action:@selector(switchToMap:) forControlEvents:UIControlEventTouchUpInside];
    [mapBtn setBackgroundImage:[UIImage imageNamed:@"right_btn.png"] forState:UIControlStateNormal];
    [mapBtn setTitle:NSLocalizedString(@"Map", nil) forState:UIControlStateNormal];
    [mapBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    _mapButton = [[UIBarButtonItem alloc] initWithCustomView:mapBtn];
    [mapBtn release];
    
    UIButton *listBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 30.0)];
    [listBtn addTarget:self action:@selector(switchToList:) forControlEvents:UIControlEventTouchUpInside];
    [listBtn setBackgroundImage:[UIImage imageNamed:@"right_btn.png"] forState:UIControlStateNormal];
    [listBtn setTitle:NSLocalizedString(@"List", nil) forState:UIControlStateNormal];
    [listBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    _listButton = [[UIBarButtonItem alloc] initWithCustomView:listBtn];
    [listBtn release];
    
//    [self requestHotOffers];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNumber *badgeNr = [[FavouritesBadgeManager sharedInstance] badgeNumber];
    
    if (badgeNr != nil && [badgeNr intValue] > 0) {
        [[[[self.tabBarController viewControllers] objectAtIndex:3] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%@",  badgeNr]];
    }
    
    if ([self.hotOffersArray count] > 0) {
        
        [self.tableView reloadData];
        [self.mapView removeAnnotations:self.mapView.annotations];
                
        for(Coupons *coupon in self.hotOffersArray){
            
            if (![NSString isNilOrEmpty: coupon.address1] || ![NSString isNilOrEmpty: coupon.address2]) {
                
                if (![NSString isNilOrEmpty: coupon.suburb] || ![NSString isNilOrEmpty: coupon.postcode]) {
                    [_mapView addAnnotation:coupon];
                }
            }
        }
        
        if (self.tableView.alpha == 1.0) {
            if ([[_mapView annotations] count] >0) {
                [self.navigationItem setRightBarButtonItem:self.mapButton animated:YES];
                if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
                {
                    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                       target:nil action:nil];
                    negativeSpacer.width = -11;// it was -6 in iOS 6
                    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.mapButton, nil] animated:NO];
                };
            } else {
                [self.navigationItem setRightBarButtonItem:nil animated:YES];
            }
        } else{
            [self.navigationItem setRightBarButtonItem:self.listButton animated:YES];
            if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
            {
                UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                   target:nil action:nil];
                negativeSpacer.width = -11;// it was -6 in iOS 6
                [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.listButton, nil] animated:NO];
            };
        }
        
        //[_mapView addAnnotations:self.couponsArray];
        [_mapView setRegion:[MKMapView regionForAnnotations:self.hotOffersArray]];
    } else {
        [self requestHotOffers];    
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [_mapView removeAnnotations:_mapView.annotations];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [self.hotOffersArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.row];
    
    CouponsCell *cell = (CouponsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CouponsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
        @try {
            if ([self.hotOffersArray count]) {
                Coupons *coupons = [self.hotOffersArray objectAtIndex:indexPath.row];
                [cell updateWithCoupons:coupons];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception");
            NSLog(@"name:%@", exception.name);
            NSLog(@"reason:%@", exception.reason);
        }
        @finally {
        }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
    
   }

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CouponDetailsViewController *detailsController = [[CouponDetailsViewController alloc] initWithNibName:@"CouponDetailsViewController" 
                                                                                                   bundle:[NSBundle mainBundle]
                                                                                               couponsInfo:[_hotOffersArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detailsController animated:YES];
    [detailsController release];
}

#pragma mark - Switch views - methods

- (void)switchToMap:(id)sender {
    [UIView beginAnimations:@"switchToMap" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];

	[_tableView setAlpha:0.0];
    [_view360 setAlpha:1.0f];
    [_mapView setAlpha:1.0];  
	
	[UIView commitAnimations];
    
    [self.navigationItem setRightBarButtonItem:self.listButton animated:NO];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.listButton, nil] animated:NO];
    };
    
    if ([self.hotOffersArray count] > 0) {
        
        for(Coupons *coupon in self.hotOffersArray){
            
            if (![NSString isNilOrEmpty: coupon.address1] || ![NSString isNilOrEmpty: coupon.address2]) {
                
                if (![NSString isNilOrEmpty: coupon.suburb] || ![NSString isNilOrEmpty: coupon.postcode]) {
                    [_mapView addAnnotation:coupon];
                }
            }
        }
        [_mapView setRegion:[MKMapView regionForAnnotations:_mapView.annotations]];
    }
}

- (void)switchToList:(id)sender {
    [UIView beginAnimations:@"switchToList" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
	
    [_view360 setAlpha:0.0f];
	[_mapView setAlpha:0.0];
    [_tableView setAlpha:1.0];
    
	[UIView commitAnimations];
    [self.navigationItem setRightBarButtonItem:self.mapButton animated:NO];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.mapButton, nil] animated:NO];
    };
}

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
    int couponsLeftNone = [[(Coupons *)annotation couponsLeft]intValue];
    
    if (redeemedCoupon || couponsLeftNone == 0) {
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

    
//    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
//    [leftView setContentMode:UIViewContentModeScaleAspectFit];
//    UIImage *couponImage = [(Coupons *)annotation image];
//    
//    if (couponImage) {
//        [leftView setImage:couponImage];
//    } else {
//        [leftView setImage:[UIImage imageNamed:@"no_image.png"]];
//    }
//    
//    [annotationView setLeftCalloutAccessoryView:[leftView autorelease]];

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
    
    [annotationView setLeftCalloutAccessoryView:[leftView autorelease]];
    
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
	Coupons *selectedCoupon = (Coupons *)view.annotation;
    CouponDetailsViewController *detailsController = [[CouponDetailsViewController alloc] initWithNibName:@"CouponDetailsViewController" 
                                                                                                   bundle:[NSBundle mainBundle] 
                                                                                              couponsInfo:selectedCoupon];
    [self.navigationController pushViewController:detailsController animated:YES];
    [detailsController release];
}

#pragma mark - ASIHTTPRequst methods

- (void)requestHotOffers {

    [_loadingView show];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];    
    
    if ([[LocationUtiliy sharedInstance] userAccepted]) {
        CLLocation *currentLocation = [[LocationUtiliy sharedInstance] currentLocation];
        [parameters setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude] forKey:@"latitude"];
        [parameters setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude] forKey:@"longitude"]; 
    }
    
    [parameters setObject:[NSNumber numberWithBool:[UIApplication supportsRetinaDisplay]] forKey:@"retina_support"];
    [parameters setObject:[[[RegionManager sharedInstance] region] regionId] forKey:@"region_id"];
    [parameters setObject:@"1" forKey:@"hot_offers"];
    
    self.hotOffersRequest = [[RequestManager sharedInstance] requestWithMethodName:@"coupons/getCoupons" 
                                                                                 methodType:@"GET" 
                                                                                 parameters:parameters
                                                                                   delegate:self 
                                                                                     secure:NO 
                                                                             withAuthParams:NO];
    
    [self.hotOffersRequest setDidFinishSelector:@selector(hotOffersRequestFinished:)];
    [self.hotOffersRequest setDidFailSelector:@selector(hotOffersRequestFailed:)];
    
    [self.hotOffersRequest startAsynchronous];
}


-(void)hotOffersRequestFinished:(ASIHTTPRequest *)request{
    
    [_loadingView hide];
    
    NSString *responseString = [request responseString];
    id responseObject = [responseString JSONValue];
    
    if (![NSString isNilOrEmpty:responseString]) {
        if ([responseObject respondsToSelector:@selector(objectAtIndex:)]) {
            NSMutableArray *appendCoupon = [NSMutableArray array];
            
            for (NSDictionary *couponInfo in responseObject ) {
                Coupons *coupon = [[Coupons alloc] initWithCouponInfo:couponInfo];
                [appendCoupon addObject:coupon];
                [coupon release];
            }
            self.hotOffersArray = [NSArray arrayWithArray:appendCoupon];
        }
    }
    
    if ([self.hotOffersArray count] == 0) {
        [self.tableView setAlpha:0.0];
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        [self showMessageViewWithContent:NSLocalizedString(@"There are no hot offers yet. Please try again soon!", nil)];
    } else {
        int size = [self.hotOffersArray count];
        NSLog(@"there are %d objects in the array", size);

        [self.tableView setAlpha:1.0];
        
        int i = 0;
        
        for(Coupons *coupon in self.hotOffersArray){
            
            if (![NSString isNilOrEmpty: coupon.address1] || ![NSString isNilOrEmpty: coupon.address2]) {
                if (![NSString isNilOrEmpty: coupon.suburb] || ![NSString isNilOrEmpty: coupon.postcode]) {
                    i++;
                }
            }
        }
        
        if (i > 0) {
            [self.navigationItem setRightBarButtonItem:self.mapButton animated:YES];
            if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
            {
                UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                   target:nil action:nil];
                negativeSpacer.width = -11;// it was -6 in iOS 6
                [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.mapButton, nil] animated:NO];
            };
        } else {
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
        }

        [_tableView reloadData];
    } 

}


- (void)hotOffersRequestFailed:(ASIHTTPRequest *)request {
    [_loadingView hide];
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    NSString *alertMessage = nil;
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        alertMessage = NSLocalizedString(@"It seems you don't have a working internet connection. Please check your Network Settings and try again!", nil);
    } else {
        alertMessage = NSLocalizedString(@"We had a problem retrieving the hot coupons list. Please try again later.", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage
                                                    message:nil 
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [_tableView setAlpha:0.0];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    [self showMessageViewWithContent:NSLocalizedString(@"There are no hot offers yet. Please try again soon!", nil)];
}

- (void)showMessageViewWithContent:(NSString *)message {
    
    [_noCouponsLabel setText:message];
    
    [UIView beginAnimations:@"showNotSignedInView" context:NULL]; 
    [UIView setAnimationDuration:0.4];
    
    [_noCouponsLabel setAlpha:1.0];
    
    [UIView commitAnimations];
}

- (void)goToHomePage:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)changeRegion:(id)sender{
    NSString *message = NSLocalizedString(@"PPlease select a region", nil);
    SelectRegionController *regionPicker = [[SelectRegionController alloc] initWithMessage:message forceSelect:NO];
    [self.navigationController pushViewController:regionPicker animated:YES];
    //[regionPicker release];
}

- (void)regionWasChanged:(NSNotification *)aNotif {
    
    [[UIApplication appDelegate] sendTokenToFCMServer:[Utility getFCMToken]];
    [[UIApplication appDelegate] sendRequestForAllCoupons];
    // set region name
    [self.regionLabel setText:[[[RegionManager sharedInstance] region] regionName]];

    [self requestHotOffers];
}

@end
