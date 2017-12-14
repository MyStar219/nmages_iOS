//
//  FindCouponsViewController.m
//  negotiator
//
//  Created by Alexandru Chis on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
// 

#import "FindCouponsViewController.h"
#import "UIApplication-Additions.h"
#import "RequestManager.h"
#import "Reachability.h"
#import "JSON.h"
#import "RegionManager.h"
#import "CouponDetailsViewController.h"
#import "SelectRegionController.h"
#import "FavouritesBadgeManager.h"
#import "ZSPinAnnotation.h"
#import "Annotation.h"
#import "Coupons.h"
#import "Utility.h"
#import "ARViewController.h"

@implementation FindCouponsViewController

@synthesize couponsDictionary   = _couponsDictionary;
@synthesize searchResultsDictionary = _searchResultsDictionary;
@synthesize searchResults       = _searchResults;
@synthesize tableView           = _tableView;
@synthesize rowsToShow          = _rowsToShow;
@synthesize couponsArray        = _couponsArray;
@synthesize regionNameLabel     = _regionNameLabel;
@synthesize couponsRequest      = _couponsRequest;
@synthesize mapButton           = _mapButton;
@synthesize listButton          = _listButton;
@synthesize loadingView         = _loadingView;
@synthesize view360 = _view360;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    UIImage *couponImage = [UIImage imageNamed:@"coupon_icon.png"];
    UITabBarItem *couponTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Coupons"
                                                                   image:couponImage 
                                                                     tag:0];
    
    // Add the item to the tab bar.
    self.tabBarItem = couponTabBarItem;
    [couponTabBarItem release];
    
    // Initialize the dictionary that will hold the rows to be displayed
    self.rowsToShow  = [NSMutableDictionary dictionary] ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(regionWasChanged:) 
                                                 name:@"regionWasChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(couponUsed:) 
                                                 name:@"couponUsed" 
                                               object:nil];
    
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.couponsDictionary = nil;
    self.rowsToShow = nil;
    self.couponsArray = nil;
    self.mapButton  = nil;
    self.listButton = nil;
    
    if (self.couponsRequest) {
        [self.couponsRequest clearDelegatesAndCancel];
        self.couponsRequest = nil;
    }
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    
    if (self.couponsDictionary) {
        self.couponsDictionary = nil;
    }
    
    if (self.couponsArray) {
        self.couponsArray = nil;
    }
    
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
    UIView *regionView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 43.0)];
    
    //esto remplaza barra gris!
    regionView.backgroundColor = [UIColor colorWithRed:93/255.0f green:93/255.0f blue:93/255.0f alpha:1];
   
    UIButton *changeRegionBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-120, 7.0, 106.0, 30.0)];
    [changeRegionBtn setBackgroundImage:[UIImage imageNamed:@"changeRegion_btn.png"] forState:UIControlStateNormal];
    [changeRegionBtn addTarget:self action:@selector(changeRegion:) forControlEvents:UIControlEventTouchUpInside];
    [regionView addSubview:changeRegionBtn];
    [changeRegionBtn release];
    
    _regionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10.0, 120.0, 21.0)];
    [_regionNameLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
    [_regionNameLabel setTextAlignment:UITextAlignmentLeft];
    [_regionNameLabel setTextColor:[UIColor whiteColor]];
    [_regionNameLabel setBackgroundColor:[UIColor clearColor]];
    [_regionNameLabel setText:[[[RegionManager sharedInstance] region] regionName]];
    [regionView addSubview:_regionNameLabel];
    [_regionNameLabel release];
    
    [self.view addSubview:regionView];  
    [regionView release];
    
    // Create a label to be displayed when there are no coupons for the selected region
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
    
    // Create the map view
    self.view360 = [[UIButton alloc]initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 40.0f)];
    [self.view360 setBackgroundImage:[UIImage imageNamed:@"view360.png"] forState:UIControlStateNormal];
    [self.view360 addTarget:self action:@selector(view360Map) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.view360];
    [self.view360 setAlpha:0.0f];
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 40.0f, [UIScreen mainScreen].bounds.size.width, 326.0)];
    [_mapView setDelegate:self];
    [_mapView setShowsUserLocation:YES];
    [_mapView setAlpha:0.0];
    [self.view addSubview:_mapView];
    [_mapView release];
    
    _tableView = [[UITableView alloc] initWithFrame:
                  CGRectMake(0.0, 43.0,
                             [UIScreen mainScreen].bounds.size.width,
                             [UIScreen mainScreen].bounds.size.height)
                                              style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setRowHeight:50.0];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1)];
    
    // Add Search Bar on tableView
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    searchBar.delegate = self;
    searchBar.placeholder = @"Search Coupons";
    
    
    _tableView.tableHeaderView = searchBar;
    
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsDelegate = self;
    _searchController.delegate = self;
    
    _searchController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1)];
    
    _searchResults = [[NSArray alloc] init];
    
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
    
    //any persisted expanded sections?
    NSData *rp = [[NSUserDefaults standardUserDefaults]objectForKey:@"sections_persisted"];
    if(rp)
    {
        self.rowsToShow = [NSKeyedUnarchiver unarchiveObjectWithData:rp];
        [self.tableView reloadData];
    }
}

-(void)view360Map
{
    ARViewController *ar = [[ARViewController alloc]initWithNibName:@"ARViewController" bundle:nil];
    [ar setCouponsArray:self.couponsArray];
    [self presentViewController:ar animated:YES completion:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the home button from the navigation bar
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

- (void)viewDidUnload {

    [super viewDidUnload];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.couponsArray && [self.couponsArray count] > 0)
        return;
    
    self.couponsArray = [NSMutableArray array];
    
    NSNumber *badgeNr = [[FavouritesBadgeManager sharedInstance] badgeNumber];
    
    if (badgeNr != nil && [badgeNr intValue] > 0) {
        [[[[self.tabBarController viewControllers] objectAtIndex:3] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%@",  badgeNr]];
    }
    
    /*if ([[self.couponsDictionary allKeys] count] > 0) 
    {
        [self.tableView reloadData];
        
        if ([self.couponsArray count] > 0) {
            //remove all annotations without the curent users location annotation
            NSMutableArray *toRemove = [NSMutableArray array];
            for (id annotation in _mapView.annotations)
                if (annotation != _mapView.userLocation)
                    [toRemove addObject:annotation];
            [_mapView removeAnnotations:toRemove];
            
            for(Coupons *coupon in _couponsArray)
            {
                
                if (![NSString isNilOrEmpty: coupon.address1] || ![NSString isNilOrEmpty: coupon.address2]) {
                    
                    if (![NSString isNilOrEmpty: coupon.suburb] || ![NSString isNilOrEmpty: coupon.postcode]) {
                        [_mapView addAnnotation:coupon];
                    }
                }
            }
            
            if (self.tableView.alpha == 1.0 ) {
                if ([[_mapView annotations] count] > 0) {
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
            [_mapView setRegion:[MKMapView regionForAnnotations:self.couponsArray]];
            
        }        
    } 
    else
    {
        /*NSDate *last = [[NSUserDefaults standardUserDefaults]objectForKey:@"last_time_coupons"];
        if(last)
        {
            if([[NSDate date]timeIntervalSinceDate:last] < 60)//3600)
            {
                //already fetched coupons less than 1h ago
                return;
            }
        }
        [[NSUserDefaults standardUserDefaults]setObject:[NSDate date] forKey:@"last_time_coupons"];
        
        [_loadingView show];
        
        [self requestCoupons];
    }*/

    [_loadingView show];
    [self requestCoupons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    //remove all annotations without the curent users location annotation
//    NSMutableArray *toRemove = [NSMutableArray array];
//    for (id annotation in _mapView.annotations)
//        if (annotation != _mapView.userLocation)
//            [toRemove addObject:annotation];
//    [_mapView removeAnnotations:toRemove];

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

    if (tableView == _searchController.searchResultsTableView) {
        
        if ([[self.searchResultsDictionary allKeys] count] == 0) {
            
            for (UIView *view in _searchController.searchResultsTableView.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    ((UILabel *)view).text = @"No Coupons Found";
                }
            }
        }
        else {
        
            for (UIView *view in _searchController.searchResultsTableView.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    ((UILabel *)view).text = @"";
                }
            }
        }
        
        return [[self.searchResultsDictionary allKeys] count];
        
    } else {
    
        // Return the number of sections depending on the number of objects in the category dictionary
        return [[self.couponsDictionary allKeys] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    
    NSMutableDictionary *numberOfRows = [[NSMutableDictionary alloc] init];
    
    if (tableView == _searchController.searchResultsTableView) {
        
        numberOfRows = self.searchResultsDictionary;
        
    } else {
     
        numberOfRows = self.couponsDictionary;
    }
    
    // Get the category key from the dictionary depending on the section
    NSString *categoryID = [[[numberOfRows allKeys] sortedArrayUsingSelector:@selector(compareAsNumbers:)] objectAtIndex:section];
    
    /* Check if the object from the _rowsToShow dictionary has the bool value set to YES for
     this section, if so, return the number of objects from the coupons dictionary for this section*/
    BOOL showRows = [[self.rowsToShow objectForKey:categoryID] boolValue];
    NSInteger count = (showRows) ? [[numberOfRows objectForKey:categoryID] count] : 0;
    
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.row];
    
    // Create the coupon cell
    FindCouponsCell *cell = (FindCouponsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[FindCouponsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSMutableDictionary *cellForRow = [[NSMutableDictionary alloc] init];
    
    if (tableView == _searchController.searchResultsTableView) {
        
        cellForRow = self.searchResultsDictionary;
        
    } else {
        
        cellForRow = self.couponsDictionary;
    }
    
    // Get the category key for this section from the coupons dictionary
    NSString *categoryID = [[[cellForRow allKeys] sortedArrayUsingSelector:@selector(compareAsNumbers:)] objectAtIndex:indexPath.section];
    
    // Extract the coupon object from the dictionary
    Coupons *coupons = [[cellForRow objectForKey:categoryID] objectAtIndex:indexPath.row];
    
    // Initialize the cell with the coupon object
    if ([[cellForRow allKeys]count]) {
        [cell updateWithCoupons:coupons];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *didSelectRow = [[NSMutableDictionary alloc] init];
    
    if (tableView == _searchController.searchResultsTableView) {
        
        didSelectRow = self.searchResultsDictionary;
        
    } else {
        
        didSelectRow = self.couponsDictionary;
    }
    
    NSString *categoryID = [[[didSelectRow allKeys] sortedArrayUsingSelector:@selector(compareAsNumbers:)] objectAtIndex:indexPath.section];
    NSArray *couponArray  = [didSelectRow objectForKey:categoryID];
    
    [Utility showCouponDetailsWithCoupon:[couponArray objectAtIndex:indexPath.row] onTarget:self.navigationController];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 43.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {  
    return 55.0;
}  

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    NSMutableDictionary *viewForHeader = [[NSMutableDictionary alloc] init];
    
    if (tableView == _searchController.searchResultsTableView) {
        
        viewForHeader = self.searchResultsDictionary;
        
    } else {
        
        viewForHeader = self.couponsDictionary;
    }
    
    // Get the category key for this section from the coupons dictionary
    NSString *categoryID = [[[viewForHeader allKeys] sortedArrayUsingSelector:@selector(compareAsNumbers:)]
                                                                         objectAtIndex:section];
    
    /* Check if the object from the _rowsToShow dictionary has the bool value set to YES for 
     this section, if so, return the number of objects from the coupons dictionary for this section*/
    BOOL showRows = [[self.rowsToShow objectForKey:categoryID] boolValue]; 
    
    // Create the view for the table view header
    UIView *categoryHeader = [[UIView alloc] initWithFrame:
                              CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 43.0)];
    
    // Create the label that displays the category name
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(65.0, 5.0, 260.0, 20.0)];
    [categoryLabel setBackgroundColor:[UIColor clearColor]];
    [categoryLabel setTextColor:[UIColor blackColor]];
    [categoryLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    [categoryLabel setNumberOfLines:1];

    // Create the label that displays the category description
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(65.0, 25.0, 260.0, 15.0)];
    [descriptionLabel setBackgroundColor:[UIColor clearColor]];
    [descriptionLabel setTextColor:[UIColor blackColor]];
    [descriptionLabel setFont:[UIFont systemFontOfSize:14.0]];
    [descriptionLabel setNumberOfLines:1];

    // Create the label that displays the number of coupons for this section
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(290.0, 5.0, 40.0, 15.0)];
    [countLabel setBackgroundColor:[UIColor clearColor]];
    [countLabel setTextColor:[UIColor blackColor]];
    [countLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
    [countLabel setNumberOfLines:1];
    [countLabel setAlpha:showRows ? 0.0 : 1.0];
    
    
    // Create a hidden button for displaying and hiding the coupons for a category
    UIButton *toggleButton = [[UIButton alloc] initWithFrame:categoryHeader.frame];
    [toggleButton addTarget:self action:@selector(toggleSection:) forControlEvents:UIControlEventTouchUpInside];
    [toggleButton setTag:[categoryID intValue]];

    // Extract the coupon array from the dictionary
    NSArray *couponArray  = [viewForHeader objectForKey:categoryID];
    
    // Extract the coupon object from the array
    Coupons *coupon         = [couponArray objectAtIndex:0];
   
    // Create the image for each category header
    UIImage *categoryImage  = [UIImage imageNamed:[NSString stringWithFormat:@"category%@_bkgd.png",categoryID]];

    Category *category = coupon.category[0];
    
    // Feed the labels in the header view with information from the coupon
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:
                                   CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 43)];
    backgroundView.image = categoryImage;

    [categoryLabel setText:[category categoryName]];
    [descriptionLabel setText:[category categoryDescription]];
    [countLabel setText:[NSString stringWithFormat:@"(%d)",[couponArray count]]];
    
    // Add all the UI elements to the header view
    [categoryHeader addSubview:backgroundView];  
    [backgroundView release];
    [categoryHeader addSubview:categoryLabel];
    [categoryLabel release];
    [categoryHeader addSubview:descriptionLabel];
    [descriptionLabel release];
    [categoryHeader addSubview:countLabel];
    [countLabel release];
    [categoryHeader addSubview:toggleButton];
    [toggleButton release];
    
    return [categoryHeader autorelease];
}

//- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
//{
//    NSPredicate *resultPredicate = [NSPredicate
//                                    predicateWithFormat:@"SELF contains[cd] %@",
//                                    searchText];
//
//    searchResults = [self.couponsArray filteredArrayUsingPredicate:resultPredicate];
//}

#pragma mark - UISearchBarDelegate

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.view endEditing:YES];
    // do search here
    
    [self requestSearchCoupons:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

    //[self removeTableHeader];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {

    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
   // [self setTableHeader];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //[self setTableHeader];
    
}

- (void)setTableHeader {
    UIView *headerView = [[UIView alloc] initWithFrame:_searchController.searchResultsTableView.frame];
    headerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    
    [_searchController.searchResultsTableView setBackgroundColor:[UIColor whiteColor]];
    [_searchController.searchResultsTableView setScrollEnabled:NO];
    [_searchController.searchResultsTableView setTableHeaderView:headerView];
    
    [headerView release];
}

- (void)removeTableHeader {
    [_searchController.searchResultsTableView setBackgroundColor:[UIColor whiteColor]];
    [_searchController.searchResultsTableView setScrollEnabled:YES];
    [_searchController.searchResultsTableView setTableHeaderView:nil];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {

    for (UIView *view in _searchController.searchResultsTableView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            ((UILabel *)view).text = @"";
        }
    }
}
    
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
//  [self filterContentForSearchText:searchString
//                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
//                                      objectAtIndex:[self.searchDisplayController.searchBar
//                                                     selectedScopeButtonIndex]]];
//
    return NO;
}

#pragma mark - Switch views - methods

- (void)switchToMap:(id)sender {
    
    [UIView beginAnimations:@"switchToMap" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
	
	[_tableView setAlpha:0.0];
    [_mapView setAlpha:1.0];
    [self.view360 setAlpha:1.0f];
    
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
        
        for(Coupons *coupon in _couponsArray){
            
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
	
    [self.view360 setAlpha:0.0f];
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
    int expiredCoupon = [[(Coupons *)annotation couponsLeft]intValue];
    
    if (redeemedCoupon || expiredCoupon == 0) {
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
    
    NSLog(@"view :: %@", view.annotation);
    Coupons *selectedCoupon = (Coupons *)view.annotation;

    NSLog(@"view2 :: %@", selectedCoupon);

    
    CouponDetailsViewController *detailsController = [[CouponDetailsViewController alloc] initWithNibName:@"CouponDetailsViewController" 
                                                                                                       bundle:[NSBundle mainBundle] 
                                                                                                  couponsInfo:selectedCoupon];
    [self.navigationController pushViewController:detailsController animated:YES];
    [detailsController release];
}


#pragma mark - ASIHTTPRequst methods

-(void)searchCouponsRequestFinished:(ASIHTTPRequest *)request {

    [_loadingView hide];
    
    NSString *responseString = [request responseString];
    
    NSLog(@"Coupons String: %@", responseString);
    
    id responseObject = [responseString JSONValue];
    NSLog(@"coupons: %@", responseObject);
    
    // Check if the response object is empty
    if (![NSString isNilOrEmpty:responseString]) {
        
        if ([responseObject isKindOfClass:[NSArray class]]) {
            
            if ([responseObject respondsToSelector:@selector(objectAtIndex:)]) {
                
                // Initialize the coupon dictionary
                self.searchResultsDictionary = [NSMutableDictionary dictionary];
                
                // Initialize an array that will hold all the coupon objects for displaying them on the map
                NSMutableArray *appendCoupon = [NSMutableArray array];
                
                /* For each dictionary from the response, initialize a coupon object, check it's category id,
                 and add it to the coupons dictionary for the coresponding category key */
                for (NSDictionary *couponInfo in responseObject ) {
                    Coupons *coupon = [[Coupons alloc] initWithCouponInfo:couponInfo isSearch:YES];
                    
                    [appendCoupon addObject:coupon];
                    
                    // Sort the coupons by category id
                    for (int i=0; i<=16; i++) {
                        NSString *categoryID = [NSString stringWithFormat:@"%d",i];
                        
                        if ([coupon.category[0].categoryId isEqualToString:categoryID]) {
                            NSMutableArray *catArray = [NSMutableArray arrayWithArray:[self.searchResultsDictionary objectForKey:categoryID]];
                            
                            /* If the coupon dictionary already contains an object for a category,
                             append it to that one, otherwise initialize the object with the coupon */
                            if ([catArray count]) {
                                [catArray addObject:coupon];
                            } else {
                                catArray = [NSMutableArray arrayWithObject:coupon];
                            }
                            
                            // Set the coupon objects for the coresponding category id in the coupons dictionary
                            [self.searchResultsDictionary setObject:catArray forKey:categoryID];
                            if(![[NSUserDefaults standardUserDefaults]objectForKey:@"sections_persisted"])
                                [self.rowsToShow setObject:[NSNumber numberWithBool:NO] forKey:categoryID];
                        }
                    }
                    [coupon release];
                }
                self.searchResults = [NSArray arrayWithArray:appendCoupon];
            }
        }
    }
    
    // Check if the dictionary contains coupon objects, if so, display the tableview, otherwise a message
    if ([self.searchResultsDictionary count] == 0) {
        //[self.tableView setAlpha:0.0];
        //[_mapView setAlpha:0.0];
        //[_view360 setAlpha:0.0f];
        //[self.navigationItem setRightBarButtonItem:nil animated:YES];
        //[self showMessageViewWithContent:NSLocalizedString(@"There are no coupons yet. Please try again soon!", nil)];
        
        [_searchController.searchResultsTableView reloadData];
        
    } else {
        int size = [self.searchResults count];
        NSLog(@"there are %d objects in the array", size);
        
        [_view360 setAlpha:0.0f];
        [_mapView setAlpha:0.0];
        [self.tableView setAlpha:1.0];
        
        int i = 0;
        
        for(Coupons *coupon in self.searchResults){
            
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
        
        [_searchController.searchResultsTableView reloadData];
    }
}

-(void)searchCouponsRequestFailed:(ASIHTTPRequest *)request {

    [_loadingView hide];
    
    [self.tableView setAlpha:0.0];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    //    [self showMessageViewWithContent:NSLocalizedString(@"There are no coupons yet. Please try again soon!", nil)];

    NSString *alertMessage = nil;
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        alertMessage = NSLocalizedString(@"It seems you don't have a working internet connection. Please check your Network Settings and try again!", nil);
    } else {
        alertMessage = NSLocalizedString(@"We had a problem retrieving the coupons list. Please try again later.", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:NSLocalizedString(@"Try again", nil), nil];
    alert.tag = 111;
    [alert show];
    [alert release];
}

-(void)couponsRequestFinished:(ASIHTTPRequest *)request {
    [_loadingView hide];
    
    
    //NSLog(@"REGION NAME: %@", [Utility getRegionIdFromRegionName:@"the-shire"]);
    
    NSString *responseString = [request responseString];
    id responseObject = [responseString JSONValue];
    NSLog(@"coupons: %@", responseObject);

    // Check if the response object is empty
    if (![NSString isNilOrEmpty:responseString]) {
        if ([responseObject respondsToSelector:@selector(objectAtIndex:)]) {
            
            // Initialize the coupon dictionary
            self.couponsDictionary = [NSMutableDictionary dictionary];

            // Initialize an array that will hold all the coupon objects for displaying them on the map
            NSMutableArray *appendCoupon = [NSMutableArray array];
            
            /* For each dictionary from the response, initialize a coupon object, check it's category id,
             and add it to the coupons dictionary for the coresponding category key */
            for (NSDictionary *couponInfo in responseObject ) {
                Coupons *coupon = [[Coupons alloc] initWithCouponInfo:couponInfo];
            
                [appendCoupon addObject:coupon];
                
                // Sort the coupons by category id
                for (int i=0; i<=16; i++) {
                    NSString *categoryID = [NSString stringWithFormat:@"%d",i];
                    
                    if ([coupon.category[0].categoryId isEqualToString:categoryID]) {
                        NSMutableArray *catArray = [NSMutableArray arrayWithArray:[self.couponsDictionary objectForKey:categoryID]];

                        /* If the coupon dictionary already contains an object for a category,
                        append it to that one, otherwise initialize the object with the coupon */
                        if ([catArray count]) {
                            [catArray addObject:coupon];
                        } else {
                            catArray = [NSMutableArray arrayWithObject:coupon];
                        }
                        
                        // Set the coupon objects for the coresponding category id in the coupons dictionary
                        [self.couponsDictionary setObject:catArray forKey:categoryID];
                        if(![[NSUserDefaults standardUserDefaults]objectForKey:@"sections_persisted"])
                            [self.rowsToShow setObject:[NSNumber numberWithBool:NO] forKey:categoryID];
                    }
                }
                [coupon release];
            }
            self.couponsArray = [NSArray arrayWithArray:appendCoupon];
        }
    }

    // Check if the dictionary contains coupon objects, if so, display the tableview, otherwise a message
    if ([self.couponsDictionary count] == 0) {
        [self.tableView setAlpha:0.0];
        [_mapView setAlpha:0.0];
        [_view360 setAlpha:0.0f];
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        [self showMessageViewWithContent:NSLocalizedString(@"There are no coupons yet. Please try again soon!", nil)];
    } else {
        int size = [self.couponsArray count];
        NSLog(@"there are %d objects in the array", size);

        [_view360 setAlpha:0.0f];
        [_mapView setAlpha:0.0];
        [self.tableView setAlpha:1.0];
        
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

- (void)couponsRequestFailed:(ASIHTTPRequest *)request {
    
    [_loadingView hide];
    
    [self.tableView setAlpha:0.0];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
//    [self showMessageViewWithContent:NSLocalizedString(@"There are no coupons yet. Please try again soon!", nil)];
    
    NSString *alertMessage = nil;
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        alertMessage = NSLocalizedString(@"It seems you don't have a working internet connection. Please check your Network Settings and try again!", nil);
    } else {
        alertMessage = NSLocalizedString(@"We had a problem retrieving the coupons list. Please try again later.", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage
                                                    message:nil 
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                          otherButtonTitles:NSLocalizedString(@"Try again", nil), nil];
    alert.tag = 111;
    [alert show];
    [alert release];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == 111) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            
        } else {
            [self requestCoupons];
        }
    }
}

#pragma mark - UIButton actions

- (void)requestSearchCoupons:(NSString *)title {
    
    /* ASSIHttp request for magazines*/
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // Send the current location to the API
    if ([[LocationUtiliy sharedInstance] userAccepted]) {
        CLLocation *currentLocation = [[LocationUtiliy sharedInstance] currentLocation];
    
        [parameters setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude] forKey:@"latitude"];
        [parameters setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude] forKey:@"longitude"];
    }
    
    // Check if the iOS has the retina display option
    //[parameters setObject:[NSNumber numberWithBool:[UIApplication supportsRetinaDisplay]] forKey:@"retina_support"];
    
    // Send the region name parameter
    [parameters setObject:[[[RegionManager sharedInstance] region] regionName] forKey:@"location"];
    
    [parameters setObject:title forKey:@"Title"];
    
    // http://www.nmags.com/index.php/api/coupons/searchTitle?Title=nkgm testing&latitude=-31.2532183&longitude=146.92109900000003
    
    self.couponsRequest = [[RequestManager sharedInstance] requestWithMethodName:@"coupons/searchTitle"
                                                                      methodType:@"GET"
                                                                      parameters:parameters
                                                                        delegate:self
                                                                          secure:NO
                                                                  withAuthParams:NO];
    
    [self.couponsRequest setDidFinishSelector:@selector(searchCouponsRequestFinished:)];
    [self.couponsRequest setDidFailSelector:@selector(searchCouponsRequestFailed:)];
    
    [self.couponsRequest startAsynchronous];
}

- (void)requestCoupons {
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
    // Send the region id parameter
    [parameters setObject:[[[RegionManager sharedInstance] region] regionId] forKey:@"region_id"];
    
    self.couponsRequest = [[RequestManager sharedInstance] requestWithMethodName:@"coupons/getCoupons" 
                                                                                   methodType:@"GET" 
                                                                                   parameters:parameters
                                                                                     delegate:self 
                                                                                       secure:NO 
                                                                               withAuthParams:NO];
    
    [self.couponsRequest setDidFinishSelector:@selector(couponsRequestFinished:)];
    [self.couponsRequest setDidFailSelector:@selector(couponsRequestFailed:)];
    
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

- (void)changeRegion:(id)sender {
    NSString *message = NSLocalizedString(@"Please select a region", nil);
    SelectRegionController *regionPicker = [[SelectRegionController alloc] initWithMessage:message forceSelect:NO];
    [self.navigationController pushViewController:regionPicker animated:YES];
    //[regionPicker release];
}

- (void)toggleSection:(UIButton *)sender {
    
    // Get the category id from the dictionary depending on the button that was pressed
    NSString *categoryID = [NSString stringWithFormat:@"%d", [sender tag]];
    
    // Change the bool value for the object in the rowsToShow dictionary to show/hide rows
    BOOL showRows = [[self.rowsToShow objectForKey:categoryID] boolValue];
    [self.rowsToShow setObject:[NSNumber numberWithBool:!showRows] forKey:categoryID];
    
    
    [self.searchController.searchResultsTableView reloadData];
    [self.tableView reloadData];
    
    //persist which rows are opened
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.rowsToShow];
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"sections_persisted"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)regionWasChanged:(NSNotification *)aNotif {
    
    // set region name
    if([self isViewLoaded]) {
        
        [[UIApplication appDelegate] sendTokenToFCMServer:[Utility getFCMToken]];
        [[UIApplication appDelegate] sendRequestForAllCoupons];
        
        [self.regionNameLabel setText:[[[RegionManager sharedInstance] region] regionName]];
        [self requestCoupons];
    }
}

- (void)couponUsed:(NSNotification *)aNotif {
    
    if ([self isViewLoaded]) {
        [self requestCoupons];
    } 
}

@end
