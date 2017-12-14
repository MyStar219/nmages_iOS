//
//  FavouritesViewController.m
//  negotiator
//
//  Created by Alexandru Chis on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavouritesViewController.h"
#import "RequestManager.h"
#import "Reachability.h"
#import "JSON.h"
#import "CouponDetailsViewController.h"
#import "FavouritesBadgeManager.h"
#import "ZSPinAnnotation.h"
#import "Annotation.h"

@implementation FavouritesViewController

@synthesize tableView           = _tableView;
@synthesize couponsArray        = _couponsArray;
@synthesize removeFavRequest    = _removeFavRequest;
@synthesize couponsRequest      = _couponsRequest;
@synthesize mapButton           = _mapButton;
@synthesize listButton          = _listButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    UIImage *favouritesImage = [UIImage imageNamed:@"favourites_icon.png"];
    UITabBarItem *favouritesTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Favourites"
                                                                      image:favouritesImage 
                                                                        tag:0];
    
    // Add the item to the tab bar.
    self.tabBarItem = favouritesTabBarItem;
    [favouritesTabBarItem release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(requestFavouriteCoupons) 
                                                 name:@"addedToFavourites" 
                                               object:nil];    
    
    return self;
}

- (void)dealloc {
    
    self.couponsArray       = nil;
    self.mapButton  = nil;
    self.listButton = nil;
    
    if (self.removeFavRequest) {
        [self.removeFavRequest clearDelegatesAndCancel];
        self.removeFavRequest = nil;
    }
    
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
    
    UIImageView *magazineHeader = [[UIImageView alloc] initWithFrame:
                                   CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 22)];
    magazineHeader.image = [UIImage imageNamed:@"favourites_header.png"];
    [self.view addSubview:magazineHeader];
    [magazineHeader release];
    
    // Create a label to be displayed when there are no favourite coupons
    _noCouponsLabel = [[UILabel alloc] initWithFrame:
                       CGRectMake(0,
                                  100.0,
                                  [UIScreen mainScreen].bounds.size.width,
                                  100.0)];
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
    _mapView = [[MKMapView alloc] initWithFrame:
                CGRectMake(0.0, 40.0,
                           [UIScreen mainScreen].bounds.size.width, 366.0)];
    [_mapView setDelegate:self];
    [_mapView setShowsUserLocation:YES];
    [_mapView setAlpha:0.0];
    [self.view addSubview:_mapView];
    [_mapView release];
    
    
    _tableView = [[UITableView alloc] initWithFrame:
                  CGRectMake(0.0, 22.0,
                             [UIScreen mainScreen].bounds.size.width,
                             [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    //    [_tableView setBackgroundView:backgroundView];
    [_tableView setRowHeight:92.0];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self.couponsArray count] > 0) {
        
        [self.tableView reloadData];
        
        NSMutableArray *toRemove = [NSMutableArray array];
        for (id annotation in _mapView.annotations)
            if (annotation != _mapView.userLocation)
                [toRemove addObject:annotation];
        [_mapView removeAnnotations:toRemove];
        
        for(Coupons *coupon in self.couponsArray){
            
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
        [_mapView setRegion:[MKMapView regionForAnnotations:_mapView.annotations]];
    } else {
        [self requestFavouriteCoupons];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.couponsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.row];
    
    // Create the coupon cell
    CouponsCell *cell = (CouponsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CouponsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Extract the coupon object from the dictionary 
    Coupons *coupons = [self.couponsArray objectAtIndex:indexPath.row];
    
    // Initialize the cell with the coupon object
    [cell updateWithCoupons:coupons];
    
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [_loadingView show];
    
    Coupons *selectedCoupon = [self.couponsArray objectAtIndex:indexPath.row];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:selectedCoupon.couponId forKey:@"coupon_id"];
    
    self.removeFavRequest = [[RequestManager sharedInstance] requestWithMethodName:@"coupons/removeFromFavourites" 
                                                                                   methodType:@"GET" 
                                                                                   parameters:parameters
                                                                                     delegate:self 
                                                                                       secure:NO 
                                                                               withAuthParams:YES];
    [self.removeFavRequest setDidFinishSelector:@selector(removeFavouriteRequestFinished:)];
    [self.removeFavRequest setDidFailSelector:@selector(removeFavouriteRequestFailed:)];
    
    [self.removeFavRequest startAsynchronous];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CouponDetailsViewController *detailsController = [[CouponDetailsViewController alloc] initWithNibName:@"CouponDetailsViewController" 
                                                                                                   bundle:[NSBundle mainBundle]
                                                                                              couponsInfo:[self.couponsArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detailsController animated:YES];
    [detailsController release];
}

#pragma mark - Switch views - methods

- (void)switchToMap:(id)sender {
    [UIView beginAnimations:@"switchToMap" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
	
	[_tableView setAlpha:0.0];
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
    [_tableView reloadData];
    
    [UIView beginAnimations:@"switchToList" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
	
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
    
    if (redeemedCoupon  || couponsLeftNone == 0) {
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

-(void)favouriteCouponsRequestFinished:(ASIHTTPRequest *)request{
    
    [_loadingView hide];
    
    NSString *responseString = [request responseString];
    id responseObject = [responseString JSONValue];
    
    // Check if the response object is empty
    if (![NSString isNilOrEmpty:responseString]) {
        if ([responseObject respondsToSelector:@selector(objectAtIndex:)]) {
            
            // Initialize an array that will hold all the coupon objects for displaying them on the map
            NSMutableArray *appendCoupon = [NSMutableArray array];
            
            for (NSDictionary *couponInfo in responseObject ) {
                Coupons *coupon = [[Coupons alloc] initWithCouponInfo:couponInfo];
                
                [appendCoupon addObject:coupon];
                
                [coupon release];
            }
            self.couponsArray = [NSArray arrayWithArray:appendCoupon];
            
            [[FavouritesBadgeManager sharedInstance] setBadgeNumber:[NSNumber numberWithInt:[self.couponsArray count]]];
            [[FavouritesBadgeManager sharedInstance] saveBadgeNumber];
            
            if ([[[FavouritesBadgeManager sharedInstance] badgeNumber] intValue] > 0) {
                [[[[self.tabBarController viewControllers] objectAtIndex:3] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%@",  [[FavouritesBadgeManager sharedInstance] badgeNumber]]];
                
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[FavouritesBadgeManager sharedInstance] badgeNumber] intValue]];
            } else {
                [[[[self.tabBarController viewControllers] objectAtIndex:3] tabBarItem] setBadgeValue:nil];
                
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            }
            
        }
    }
    
    if ([self.couponsArray count] == 0) {
        [_tableView setAlpha:0.0];
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        [self showMessageViewWithContent:NSLocalizedString(@"You have not added any favourite coupons yet!", nil)];
    } else {
        [_tableView setAlpha:1.0];
        
        int i = 0;
        
        for(Coupons *coupon in self.couponsArray){
            
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

- (void)favouriteCouponsRequestFailed:(ASIHTTPRequest *)request {
    [_loadingView hide];
    
    [_tableView setAlpha:0.0];
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    [self showMessageViewWithContent:NSLocalizedString(@"You have not added any favourite coupons yet!", nil)];
    
    [[FavouritesBadgeManager sharedInstance] setBadgeNumber:[NSNumber numberWithInt:0]];
    [[FavouritesBadgeManager sharedInstance] saveBadgeNumber];
        
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[[[self.tabBarController viewControllers] objectAtIndex:3] tabBarItem] setBadgeValue:nil];
    
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


- (void)removeFavouriteRequestFinished:(ASIHTTPRequest *)request {
    id response = [[request responseString] JSONValue];
    
    if ([response respondsToSelector:@selector(objectForKey:)]) {
        NSDictionary *errors = [response objectForKey:@"errors"];
        if (errors) {
            NSString *errorMessage = [errors objectForKey:@"message"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMessage
                                                            message:nil 
                                                           delegate:nil 
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        } else {
            
            NSNumber *badgeNumber = [[FavouritesBadgeManager sharedInstance] badgeNumber];
            
            if ([badgeNumber intValue] > 1) {
                NSNumber *decrementedBadgeNumber = [NSNumber numberWithInt:[badgeNumber intValue] - 1];
                
                [[FavouritesBadgeManager sharedInstance] setBadgeNumber:[NSString stringWithFormat:@"%@",decrementedBadgeNumber]];
                
                [[[[self.tabBarController viewControllers] objectAtIndex:3] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%@",  [[FavouritesBadgeManager sharedInstance] badgeNumber]]];
                
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[FavouritesBadgeManager sharedInstance] badgeNumber] intValue]];
            } else {
                [[FavouritesBadgeManager sharedInstance] setBadgeNumber:[NSNumber numberWithInt:0]];
                [[[[self.tabBarController viewControllers] objectAtIndex:3] tabBarItem] setBadgeValue:nil];      
                
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            }
            
            [[FavouritesBadgeManager sharedInstance] saveBadgeNumber];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"removedFromFavourites" 
                                                                object:nil 
                                                              userInfo:response];
        }
    }
    
    [self requestFavouriteCoupons];
}

- (void)removeFavouriteRequestFailed:(ASIHTTPRequest *)request {
    NSString *alertMessage = nil;
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        alertMessage = NSLocalizedString(@"It seems you don't have a working internet connection. Please check your Network Settings and try again!", nil);
    } else {
        alertMessage = NSLocalizedString(@"We could not remove this coupon from your favourites. Please try again later.", nil);
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

- (void)requestFavouriteCoupons {
    
    [_loadingView show];
    
    /* ASSIHttp request for magazines*/
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];    
    
    // Send the current location to the API
    if ([[LocationUtiliy sharedInstance] userAccepted]) {
        CLLocation *currentLocation = [[LocationUtiliy sharedInstance] currentLocation];
        [parameters setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude] forKey:@"latitude"];
        [parameters setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude] forKey:@"longitude"]; 
    }
    
    // Check if the iOS has the retina display option
    [parameters setObject:[NSNumber numberWithBool:[UIApplication supportsRetinaDisplay]] forKey:@"retina_support"];
    
    [parameters setObject:@"1" forKey:@"favourites"];
    
    self.couponsRequest = [[RequestManager sharedInstance] requestWithMethodName:@"coupons/getCoupons" 
                                                                                 methodType:@"GET" 
                                                                                 parameters:parameters
                                                                                   delegate:self 
                                                                                     secure:NO 
                                                                             withAuthParams:NO];
    
    [self.couponsRequest setDidFinishSelector:@selector(favouriteCouponsRequestFinished:)];
    [self.couponsRequest setDidFailSelector:@selector(favouriteCouponsRequestFailed:)];
    
    [self.couponsRequest startAsynchronous];
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
