//
//  MagazinesViewController.m
//  negotiator
//
//  Created by Alexandru Chis on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MagazinesViewController.h"
#import "RequestManager.h"
#import "Reachability.h"
#import "Utility.h"
#import "JSON.h"
#import "MagazinesCell.h"
#import "MagazinesDetailViewController.h"
#import "RegionManager.h"
#import "FavouritesBadgeManager.h"
#import "ARViewController.h"

@implementation MagazinesViewController

@synthesize mapView         = _mapView;
@synthesize magazinesArray  = _magazinesArray;
@synthesize tableView       = _tableView;
@synthesize magazinesRequest = _magazinesRequest;
@synthesize mapButton       = _mapButton;
@synthesize listButton      = _listButton;
@synthesize view360 = _view360;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    UIImage *magazinesImage = [UIImage imageNamed:@"magazines_icon.png"];
    UITabBarItem *magazinesTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Get a Copy"
                                                                       image:magazinesImage 
                                                                         tag:0];
    
    // Add the item to the tab bar.
    self.tabBarItem = magazinesTabBarItem;
    [magazinesTabBarItem release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(regionWasChanged:) 
                                                 name:@"regionWasChanged"
                                               object:nil];
    
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_magazinesArray release];
    self.mapButton  = nil;
    self.listButton = nil;
    
    if (self.magazinesRequest) {
        [self.magazinesRequest clearDelegatesAndCancel];
        self.magazinesRequest = nil;
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
    
    UIImageView *magazineHeader = [[UIImageView alloc] initWithFrame:
                                   CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 47)];
    magazineHeader.contentMode = UIViewContentModeScaleAspectFit;
    magazineHeader.image = [UIImage imageNamed:@"magazine_header.png"];
    [self.view addSubview:magazineHeader];
    [magazineHeader release];
    
    _noMagazinesLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 100.0, 280.0, 100.0)];
    [_noMagazinesLabel setBackgroundColor:[UIColor clearColor]];
    [_noMagazinesLabel setTextAlignment:UITextAlignmentCenter];
    [_noMagazinesLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    [_noMagazinesLabel setNumberOfLines:0.0];
    [_noMagazinesLabel setTextColor:[UIColor whiteColor]];
    [_noMagazinesLabel setShadowColor:[UIColor blackColor]];
    [_noMagazinesLabel setShadowOffset:CGSizeMake(-0.5, 0.5)];
    [_noMagazinesLabel setAlpha:0.0];
    [self.view addSubview:_noMagazinesLabel];
    [_noMagazinesLabel release];
    
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
                  CGRectMake(0.0, 44,
                             [UIScreen mainScreen].bounds.size.width,
                             [UIScreen mainScreen].bounds.size.height - 150) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setRowHeight:92.0];
    [_tableView setAlpha:1.0];
    [self.view addSubview:_tableView];
    [_tableView release];
    
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
    if([[UIScreen mainScreen]bounds].size.height == 568)
    {
        [_loadingView setFrame:CGRectMake(_loadingView.frame.origin.x, _loadingView.frame.origin.y, _loadingView.frame.size.width, _loadingView.frame.size.height + 90.0f)];
    }
    [_loadingView setAlpha:0.0];
    [self.view addSubview:_loadingView];
    [_loadingView release];
}

-(void)view360Map
{
    ARViewController *ar = [[ARViewController alloc]initWithNibName:@"ARViewController" bundle:nil];
    [ar setCouponsArray:self.magazinesArray];
    [self presentViewController:ar animated:YES completion:nil];
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
    
    [self requestMagazines];
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
    
//    [_tableView setAlpha:1.0];
//    [_mapView setAlpha:0.0];
//    [self.navigationItem setRightBarButtonItem:self.mapButton animated:YES];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
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
    return [_magazinesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.row];
    
    MagazinesCell *cell = (MagazinesCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MagazinesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Magazines *magazine = [_magazinesArray objectAtIndex:indexPath.row];    
    [cell updateWithMagazines:magazine];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MagazinesDetailViewController *detailsController = [[MagazinesDetailViewController alloc] initWithNibName:@"MagazinesDetailController" 
                                                                                                       bundle:[NSBundle mainBundle] 
                                                                                                 magazineInfo:[_magazinesArray objectAtIndex:indexPath.row]];
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
    
    if ([self.magazinesArray count] > 0) {
        
        for(Magazines *magazin in _magazinesArray){
            if (![NSString isNilOrEmpty:magazin.address1] ||
                ![NSString isNilOrEmpty:magazin.address2])
            {
                [_mapView addAnnotation:magazin];
            }
        }
       // [_mapView addAnnotations:self.magazinesArray];
        [_mapView setRegion:[MKMapView regionForAnnotations:self.magazinesArray]];
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
    
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	
	if (!annotationView) {
		annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
	}
	
    [annotationView setNeedsDisplay];
    [annotationView setAnimatesDrop:YES];
    [annotationView setPinColor:MKPinAnnotationColorRed];
    [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
    [annotationView setCanShowCallout:YES];
    
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
    [leftView setContentMode:UIViewContentModeScaleAspectFit];
    UIImage *magazineImage = [(Magazines *)annotation image];
    
    if (magazineImage) {
        [leftView setImage:magazineImage];
    } else {
        [leftView setImage:[UIImage imageNamed:@"no_image.png"]];
    }
    
    [annotationView setLeftCalloutAccessoryView:[leftView autorelease]];
    
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	Magazines *selectedMagazine = (Magazines *)view.annotation;
    
    MagazinesDetailViewController *detailsController = [[MagazinesDetailViewController alloc] initWithNibName:@"MagazinesDetailController" 
                                                                                                       bundle:[NSBundle mainBundle] 
                                                                                                 magazineInfo:selectedMagazine];
    [self.navigationController pushViewController:detailsController animated:YES];
    [detailsController release];
}

#pragma mark - ASIHTTPRequst methods

-(void)magazinesRequestFinished:(ASIHTTPRequest *)request{
    
    [_loadingView hide];
    
    NSString *responseString = [request responseString];
    id responseObject = [responseString JSONValue];
    
    if (![NSString isNilOrEmpty:responseString]) {
        if ([responseObject respondsToSelector:@selector(objectAtIndex:)]) {
            NSMutableArray *appendMagazine = [NSMutableArray array];
            
            for (NSDictionary *magazineInfo in responseObject ) {
                Magazines *magazine = [[Magazines alloc] initWithMagazineInfo:magazineInfo];
                [appendMagazine addObject:magazine];
                [magazine release];
            }
            self.magazinesArray = [NSArray arrayWithArray:appendMagazine];
        }
    }
    
    if ([self.magazinesArray count] == 0) {
        [_tableView setHidden:YES];
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        [self showMessageViewWithContent:NSLocalizedString(@"There are no magazine stores yet. Please try again soon!", nil)];
    } else {
        [_tableView setHidden:NO];
        [self.navigationItem setRightBarButtonItem:self.mapButton animated:YES];
        if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
        {
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                               target:nil action:nil];
            negativeSpacer.width = -11;// it was -6 in iOS 6
            [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.mapButton, nil] animated:NO];
        };
        [_tableView reloadData];
    } 

}

- (void)magazinesRequestFailed:(ASIHTTPRequest *)request {
    [_loadingView hide];
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    NSString *alertMessage = nil;
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        alertMessage = NSLocalizedString(@"It seems you don't have a working internet connection. Please check your Network Settings and try again!", nil);
    } else {
        alertMessage = NSLocalizedString(@"We had a problem retrieving the activities list. Please try again later.", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage
                                                    message:nil 
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark Custom methods

- (void)requestMagazines {
    /* ASSIHttp request for magazines*/
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];    
    
    if ([[LocationUtiliy sharedInstance] userAccepted]) {
        CLLocation *currentLocation = [[LocationUtiliy sharedInstance] currentLocation];
        [parameters setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude] forKey:@"latitude"];
        [parameters setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude] forKey:@"longitude"]; 
    }
    
    [parameters setObject:[NSNumber numberWithBool:[UIApplication supportsRetinaDisplay]] forKey:@"retina_support"];
    [parameters setObject:[[[RegionManager sharedInstance] region] regionId] forKey:@"region_id"];
    
    self.magazinesRequest = [[RequestManager sharedInstance] requestWithMethodName:@"stores/getStores" 
                                                                                   methodType:@"GET" 
                                                                                   parameters:parameters
                                                                                     delegate:self 
                                                                                       secure:NO 
                                                                               withAuthParams:NO];
    
    [self.magazinesRequest setDidFinishSelector:@selector(magazinesRequestFinished:)];
    [self.magazinesRequest setDidFailSelector:@selector(magazinesRequestFailed:)];
    
    [self.magazinesRequest startAsynchronous];
}

- (void)showMessageViewWithContent:(NSString *)message {
    
    [_noMagazinesLabel setText:message];
    
    [UIView beginAnimations:@"showNotSignedInView" context:NULL];
    [UIView setAnimationDuration:0.4];
    
    [_noMagazinesLabel setAlpha:1.0];
    
    [UIView commitAnimations];
}

- (void)goToHomePage:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)regionWasChanged:(NSNotification *)aNotif {
    
    [[UIApplication appDelegate] sendTokenToFCMServer:[Utility getFCMToken]];
    [[UIApplication appDelegate] sendRequestForAllCoupons];
    [self requestMagazines];
}

@end
