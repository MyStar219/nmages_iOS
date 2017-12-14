//
//  NearMeViewController.m
//  negotiator
//
//  Created by Alexandru Chis on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NearMeViewController.h"
#import "RequestManager.h"
#import "Reachability.h"
#import "JSON.h"
#import "RegionManager.h"
#import "CouponDetailsViewController.h"
#import "AppDelegate.h"
#import "FavouritesBadgeManager.h"
#import "ZSPinAnnotation.h"
#import "Annotation.h"
#import "Location.h"
#import "ARViewController.h"

@implementation NearMeViewController

@synthesize tableView           = _tableView;
@synthesize couponsArray        = _couponsArray;
@synthesize couponsRequest      = _couponsRequest;
@synthesize mapButton           = _mapButton;
@synthesize listButton          = _listButton;
@synthesize view360 = _view360;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    UIImage *nearMeImage = [UIImage imageNamed:@"nearMe_icon.png"];
    UITabBarItem *nearMeTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Near Me"
                                                                   image:nearMeImage 
                                                                     tag:0];
    
    // Add the item to the tab bar.
    self.tabBarItem = nearMeTabBarItem;
    [nearMeTabBarItem release];
    
    return self;
}

- (void)dealloc {
    
    self.couponsArray       = nil;
    self.mapButton          = nil;
    self.listButton         = nil;
    
    if (self.couponsRequest) {
        [self.couponsRequest clearDelegatesAndCancel];
        self.couponsRequest = nil;
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

- (void)loadView {
    [super loadView];
    
    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:self.view.frame];
    backgroundView.image = [UIImage imageNamed:@"info_bkgd.png"];
    [self.view addSubview:backgroundView];
    [backgroundView release];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(locationRefused:)
                                                name:@"location_refused"
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(locationSet:)
                                                name:@"location_set"
                                              object:nil];
    
    // Create a label to be displayed when there are no coupons for the selected region
    _noCouponsLabel = [[UILabel alloc] initWithFrame:
                       CGRectMake(0,
                                  100.0, [UIScreen mainScreen].bounds.size.width, 100.0)];
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
    
    // Create the map view
    self.view360 = [[UIButton alloc]initWithFrame:
                    CGRectMake(0.0f, 0.0f,
                               [UIScreen mainScreen].bounds.size.width,
                               40.0f)];
    [self.view360 setBackgroundImage:[UIImage imageNamed:@"view360.png"] forState:UIControlStateNormal];
    [self.view360 addTarget:self action:@selector(view360Map) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.view360];
    [self.view360 setAlpha:0.0f];
    _mapView = [[MKMapView alloc] initWithFrame:
                CGRectMake(0.0, 40.0,
                           [UIScreen mainScreen].bounds.size.width,
                           366.0)];
    [_mapView setDelegate:self];
    [_mapView setShowsUserLocation:YES];
    [_mapView setAlpha:0.0];
    [self.view addSubview:_mapView];
    [_mapView release];
    
    
    _tableView = [[UITableView alloc] initWithFrame:
                  CGRectMake(0.0, 0.0,
                             [UIScreen mainScreen].bounds.size.width,
                             [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
 
    [_tableView setRowHeight:92.0];
    [_tableView setHidden:YES];
    [self.view addSubview:_tableView];
    [_tableView release];
    
    if([[UIScreen mainScreen]bounds].size.height == 568)
    {
        [_mapView setFrame:CGRectMake(_mapView.frame.origin.x, _mapView.frame.origin.y, _mapView.frame.size.width, _mapView.frame.size.height + 90.0f)];
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height + 90.0f)];
    }
    
    // Create the loading view shown when making the request
    _loadingView = [[LoadingView alloc] initWithFrame:self.view.bounds 
                                              message:NSLocalizedString(@"Loading ...", nil) 
                                          messageFont:[UIFont boldSystemFontOfSize:13.0]
                                                style:LoadingViewBlack
                                       roundedCorners:NO];
    [_loadingView setAlpha:0.0];
    [self.view addSubview:_loadingView];
    [_loadingView release];
}

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
}

-(void)view360Map
{
    ARViewController *ar = [[ARViewController alloc]initWithNibName:@"ARViewController" bundle:nil];
    [ar setCouponsArray:self.couponsArray];
    [self presentViewController:ar animated:YES completion:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
        
    NSNumber *badgeNr = [[FavouritesBadgeManager sharedInstance] badgeNumber];
    
    if (badgeNr != nil && [badgeNr intValue] > 0) {
        [[[[self.tabBarController viewControllers] objectAtIndex:3] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%@",  badgeNr]];
    }
    
    _couponsOffset  = 0;
    _totalCoupons   = 0;
    _firstLoad      = YES;
    
    if (self.couponsArray) {
        self.couponsArray = nil;
    }
    
    self.couponsArray = [NSMutableArray array];
    
//    if ([self.couponsArray count]) {
//        [_mapView setAlpha:1.0];
//        [_tableView setAlpha:0.0];
//        [self.navigationItem setRightBarButtonItem:_listButton animated:YES];
//    }
    
    [self requestNearbyCoupons];
    [self.view360 setAlpha:1.0f];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //remove all annotations without the curent users location annotation
    NSMutableArray *toRemove = [NSMutableArray array];
    for (id annotation in _mapView.annotations)
        if (annotation != _mapView.userLocation)
            [toRemove addObject:annotation];
    [_mapView removeAnnotations:toRemove];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showCouponDetailORUsed:(Coupons *)coupon {
    
//    if (!(coupon.isRedeemed) && !([coupon.couponsLeft isEqualToString:@"0"])) {
//        
//        [Utility showCouponRedeemWithCoupon:coupon onTarget:self.navigationController];
//    }
//    else {
    
        [Utility showCouponDetailsWithCoupon:coupon onTarget:self.navigationController];
//    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? [self.couponsArray count] : 0 ;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.row];
    
    // Create the coupon cell
    CouponsCell *cell = (CouponsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CouponsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if ([self.couponsArray count] == 0) {
        [_mapView setAlpha:0.0];
        [_tableView setAlpha:0.0];
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        [self showMessageViewWithContent:NSLocalizedString(@"There are no nearby coupons. Please try again soon!", nil)];
        
        [self.view360 setHidden:YES];
    } else {
        
        [self.view360 setHidden:NO];
        // Extract the coupon object from the dictionary
        Coupons *coupons = [self.couponsArray objectAtIndex:indexPath.row];
        
        // Initialize the cell with the coupon object
        [cell updateWithCoupons:coupons];
    
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Coupons *coupon = [self.couponsArray objectAtIndex:indexPath.row];
    
    [self showCouponDetailORUsed:coupon];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc] initWithFrame:
                          CGRectMake(0.0, 0.0,
                                     [UIScreen mainScreen].bounds.size.width,
                                     40.0)];
    [footerView setBackgroundColor:[UIColor blackColor]];
    [footerView setAlpha:0.8];
    
    UILabel *loadLabel = [[UILabel alloc] initWithFrame:
                          CGRectMake(0.0, 0.0,
                                     [UIScreen mainScreen].bounds.size.width,
                                     20.0)];
    [loadLabel setBackgroundColor:[UIColor clearColor]];
    [loadLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [loadLabel setTextColor:[UIColor whiteColor]];
    [loadLabel setTextAlignment:UITextAlignmentCenter];
    [loadLabel setText:NSLocalizedString(@"Load more coupons...", nil)];
    [footerView addSubview:loadLabel];
    [loadLabel release];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:
                           CGRectMake(0.0, 20.0,
                                      [UIScreen mainScreen].bounds.size.width,
                                      20.0)];
    [countLabel setBackgroundColor:[UIColor clearColor]];
    [countLabel setFont:[UIFont systemFontOfSize:14.0]];
    [countLabel setTextColor:[UIColor whiteColor]];
    [countLabel setTextAlignment:UITextAlignmentCenter];
    [countLabel setText:[NSString stringWithFormat:@"%d results found",_totalCoupons]];
    [footerView addSubview:countLabel];
    [countLabel release];
    
    UIButton *loadMoreBtn = [[UIButton alloc] initWithFrame:footerView.frame];
    [loadMoreBtn setBackgroundColor:[UIColor clearColor]];
    [loadMoreBtn addTarget:self action:@selector(loadMoreDeals:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:loadMoreBtn];
    [loadMoreBtn release];
    
    return [footerView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    CGFloat height = 0.0;
    
    if (section == 1) {
        height = [self.couponsArray count] < _totalCoupons ? 40.0 : 0.0;
    }
    return height;
}

#pragma mark - Switch views - methods

- (void)switchToMap:(id)sender {
    [UIView beginAnimations:@"switchToMap" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
	
	[_tableView setAlpha:0.0];
    [_mapView setAlpha:1.0];
    [_view360 setAlpha:1.0f];
	
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
    
    if ([self.couponsArray count] > 0) {
        
        for(Coupons *coupon in self.couponsArray){
            
            if (![NSString isNilOrEmpty: coupon.address1] || ![NSString isNilOrEmpty: coupon.address2]) {
                
                if (![NSString isNilOrEmpty: coupon.suburb] || ![NSString isNilOrEmpty: coupon.postcode]) {
                    [_mapView addAnnotation:coupon];
                }
            }
        }
        
        //[_mapView addAnnotations:self.couponsArray];
        [_mapView setRegion:[MKMapView regionForAnnotations:_mapView.annotations]];
    }
    
}

- (void)switchToList:(id)sender {
//    [_tableView reloadData];
    
    [UIView beginAnimations:@"switchToList" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
	
    [_view360 setAlpha:0.0f];
	[_mapView setAlpha:0.0];
    [_tableView setAlpha:1.0];
    [_tableView setHidden:NO];
    
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
            id<MKAnnotation> myAnnotation = _mapView.userLocation;
            [_mapView selectAnnotation:myAnnotation animated:YES];
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

    [self showCouponDetailORUsed:selectedCoupon];
}

#pragma mark - ASIHTTPRequst methods

- (void)loadMoreDeals:(id)sender {
    
    _firstLoad = NO;
    
    [self requestNearbyCoupons];
}

-(void)nearbyCouponsRequestFinished:(ASIHTTPRequest *)request{
    
    [_loadingView hide];
    
    NSString *responseString = [request responseString];
    id responseObject = [responseString JSONValue];
    
    // Check if the response object is empty
    if (![NSString isNilOrEmpty:responseString]) {
        if ([responseObject respondsToSelector:@selector(objectForKey:)]) {
            
            int total = [[responseObject objectForKey:@"total_coupons"] intValue];
            
            NSLog(@"Near Me Coupons: %@", responseObject);
            
            if (_couponsOffset == 0) {
                _totalCoupons = total;
            }
            _couponsOffset       += 30;
            
            // Initialize an array that will hold all the coupon objects for displaying them on the map
            NSMutableArray *appendCoupon = [NSMutableArray array];
            
            for (NSDictionary *couponInfo in [responseObject objectForKey:@"coupons"] ) {
                Coupons *coupon = [[Coupons alloc] initWithCouponInfo:couponInfo];
                
                [appendCoupon addObject:coupon];
                
                [coupon release];
            }
            self.couponsArray = [NSMutableArray arrayWithArray:appendCoupon];
        }
    }
    
    // Check if the array contains coupon objects, if so, display the map, otherwise a message
    if ([self.couponsArray count] == 0) {
        [_mapView setAlpha:0.0];
        [_tableView setAlpha:0.0];
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        [self showMessageViewWithContent:NSLocalizedString(@"There are no nearby coupons. Please try again soon!", nil)];
        
        [self.view360 setHidden:YES];
        
    } else {
        
        [self.view360 setHidden:NO];
        
        int size = [self.couponsArray count];
        //NSLog(@"initially, there are %d objects in the array", size);
        
        //KL: maintain only the objects in a 15km radius
        CLLocation *currentLocation = [[LocationUtiliy sharedInstance] currentLocation];
        
//        NSLog(@"\nLatitude: %f, Longitude: %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        NSMutableArray *coupons = [NSMutableArray new];
        for(Coupons *coupon in self.couponsArray)
        {
            CLLocation *cl = [[CLLocation alloc]initWithLatitude:coupon.coordinate.latitude longitude:coupon.coordinate.longitude];
            double d = [cl distanceFromLocation:currentLocation];
//            NSLog(@"d: %.2f", d);
            if(fabsf(d) <= 25000)
            {
                [coupons addObject:coupon];
            }
        }
        [self.couponsArray removeAllObjects];
        [self.couponsArray addObjectsFromArray:coupons];
        NSLog(@"in a 15km radius: %d", self.couponsArray.count);
        
        int i = 0;
        
        for(Coupons *coupon in self.couponsArray){
            
            if (![NSString isNilOrEmpty: coupon.address1] || ![NSString isNilOrEmpty: coupon.address2]) {
                if (![NSString isNilOrEmpty: coupon.suburb] || ![NSString isNilOrEmpty: coupon.postcode]) {
                    i++;
                }
            }
        }
        
        if (i > 0) {                
            if (_firstLoad) {
                [_mapView setAlpha:1.0];
                [_tableView setAlpha:0.0];
                [self.navigationItem setRightBarButtonItem:self.listButton animated:YES];
                if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
                {
                    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                       target:nil action:nil];
                    negativeSpacer.width = -11;// it was -6 in iOS 6
                    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.listButton, nil] animated:NO];
                };
            } else {
                [self.navigationItem setRightBarButtonItem:self.mapButton animated:YES];
                if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
                {
                    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                       target:nil action:nil];
                    negativeSpacer.width = -11;// it was -6 in iOS 6
                    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.mapButton, nil] animated:NO];
                };
                [_tableView setAlpha:1.0];
                [_mapView setAlpha:0.0];
            }
   
            for(Coupons *coupon in self.couponsArray){
                
                if (![NSString isNilOrEmpty: coupon.address1] || ![NSString isNilOrEmpty: coupon.address2]) {
                    
                    if (![NSString isNilOrEmpty: coupon.suburb] || ![NSString isNilOrEmpty: coupon.postcode]) {
                        [_mapView addAnnotation:coupon];
                    }
                }
            }
            
            [self.view360 setHidden:NO];
            [_mapView setRegion:[MKMapView regionForAnnotations:_mapView.annotations]];
            [_tableView reloadData];
            
        } else {
            [self.view360 setHidden:YES];
            [_mapView setAlpha:0.0];
            [_tableView setAlpha:0.0];
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
            [self showMessageViewWithContent:NSLocalizedString(@"There are no nearby coupons. Please try again soon!", nil)];
        }

    } 
    
}

- (void)nearbyCouponsRequestFailed:(ASIHTTPRequest *)request {
    [_loadingView hide];
    
    _firstLoad = YES;
    
    [_mapView setAlpha:0.0];
    [_tableView setAlpha:0.0];
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    [self showMessageViewWithContent:NSLocalizedString(@"The nearby coupons could not be retrieved. Please try again soon!", nil)];
    
    _couponsOffset  = 0;
    _totalCoupons   = 0;
    
    if (self.couponsArray) {
        self.couponsArray = nil;
    }
    
    self.couponsArray = [NSMutableArray array];
    
    NSString *alertMessage = nil;
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        alertMessage = NSLocalizedString(@"It seems you don't have a working internet connection. Please check your Network Settings and try again!", nil);
    } else {
        alertMessage = NSLocalizedString(@"We had a problem retrieving the nearby coupons. Please try again later.", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage
                                                    message:nil 
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark - UIButton actions

-(void)locationSet:(id)sender
{
    /* ASSIHttp request for magazines*/
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // Send the current location to the API
    if ([[LocationUtiliy sharedInstance] userAccepted])
    {
        
        //<wpt lat="-33.5966067" lon="150.7533446">
        // lat = "-33.906969";
        // lon = "150.9189437"
//        CLLocation *currentLocation = [[LocationUtiliy sharedInstance] currentLocation];
//        [parameters setObject:[NSString stringWithFormat:@"%.6f", -33.906969] forKey:@"latitude"];
//        [parameters setObject:[NSString stringWithFormat:@"%.6f", 150.9189437] forKey:@"longitude"];
        
        CLLocation *currentLocation = [[LocationUtiliy sharedInstance] currentLocation];
        [parameters setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude] forKey:@"latitude"];
        [parameters setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude] forKey:@"longitude"];
    }
    
    [parameters setObject:[NSString stringWithFormat:@"%d",_couponsOffset] forKey:@"offset"];
    
    // Check if the iOS has the retina display option
    [parameters setObject:[NSNumber numberWithBool:[UIApplication supportsRetinaDisplay]] forKey:@"retina_support"];
    
    [parameters setObject:@"1" forKey:@"near_me"];
    // Send the region id parameter
    [parameters setObject:[[[RegionManager sharedInstance] region] regionId] forKey:@"region_id"];
    
    self.couponsRequest = [[RequestManager sharedInstance] requestWithMethodName:@"coupons/getCoupons"
                                                                      methodType:@"GET"
                                                                      parameters:parameters
                                                                        delegate:self
                                                                          secure:NO
                                                                  withAuthParams:NO];
    
    [self.couponsRequest setDidFinishSelector:@selector(nearbyCouponsRequestFinished:)];
    [self.couponsRequest setDidFailSelector:@selector(nearbyCouponsRequestFailed:)];
    
    [self.couponsRequest startAsynchronous];

}

-(void)locationRefused:(id)sender
{
    [_loadingView hide];
}

- (void)requestNearbyCoupons
{
    [_loadingView show];
    [[Location singleton] getLocation];
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


@end
