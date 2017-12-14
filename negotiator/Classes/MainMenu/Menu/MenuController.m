//
//  MenuController.m
//  negotiator
//
//  Created by Andrei Vig on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuController.h"
#import "FindCouponsViewController.h"
#import "NearMeViewController.h"
#import "HotOffersViewController.h"
#import "FavouritesViewController.h"
#import "MagazinesViewController.h"
#import "InfoController.h"
#import "RegionManager.h"
#import "AppDelegate.h"
#import "SelectRegionController.h"



@interface MenuController()

@property (nonatomic, strong) NSDictionary *detectedRegion;

@end

@implementation MenuController

@synthesize homeImageView   = _homeImageView;

@synthesize regionLabel     = _regionLabel;

@synthesize changeRegionBtn = _changeRegionBtn;
@synthesize findCouponsBtn  = _findCouponsBtn;
@synthesize nearMeBtn       = _nearMeBtn;
@synthesize hotOffersBtn    = _hotOffersBtn;
@synthesize favouritesBtn   = _favouritesBtn;
@synthesize magazinesBtn    = _magazinesBtn;
@synthesize regionImageBtn  = _regionImageBtn;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(regionWasChanged:) name:@"regionWasChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToFavourites:) name:@"selectFavouritesView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRegionAlert:) name:@"regionAlertShow" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRegion) name:@"regionSelectFirstTime" object:nil];

        _regionAlertDisplayed = NO;
    }
    return self;
}

- (void)dealloc
{
    self.homeImageView = nil;
    self.regionLabel = nil;
    
    self.changeRegionBtn = nil;
    self.findCouponsBtn = nil;
    self.nearMeBtn = nil;
    self.hotOffersBtn = nil;
    self.favouritesBtn = nil;
    self.magazinesBtn = nil;
    self.regionImageBtn = nil;
    
    [_homeImageView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    RegionManager* regionManager = [RegionManager sharedInstance];
    
    [self.homeImageView setTag:9999];
    
    if (![NSString isNilOrEmpty:[[regionManager region] regionId]] && ![NSString isNilOrEmpty:[[regionManager region] regionName]])
    {
        // set homescreen image
        [self.homeImageView setImageWithURL:[regionManager regionImageURL] placeholderImage:[UIImage imageNamed:@"default-homescreen.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        // set region name
        [self.regionLabel setText:[[regionManager region] regionName]];
        
    } else {
    
        [self.regionLabel setText:@""];

        [self.homeImageView setImage:[UIImage imageNamed:@"default-homescreen.png"]];
        
        if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
            [self showReachabilityError];
        }
    }

    
    if([[[UIDevice currentDevice]systemVersion]floatValue] < 7.0f)
    {
        UIButton *infoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 30.0)];
        [infoBtn addTarget:self action:@selector(goToInfoPage:) forControlEvents:UIControlEventTouchUpInside];
        [infoBtn setBackgroundImage:[UIImage imageNamed:@"info_btn_square.png"] forState:UIControlStateNormal];
        [infoBtn setTitle:NSLocalizedString(@"Info", nil) forState:UIControlStateNormal];
        [infoBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 30.0)];
        [buttonView addSubview:infoBtn];
        [infoBtn release];
        UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
        self.navigationItem.leftBarButtonItem = infoButton;
        [buttonView release];
        [infoButton release];
    }
    else 
    {
        UIButton *refButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0f, 40.0, 30.0)];
        [refButton addTarget:self action:@selector(goToInfoPage:) forControlEvents:UIControlEventTouchUpInside];
        [refButton setBackgroundImage:[UIImage imageNamed:@"info_btn_square.png"] forState:UIControlStateNormal];
        [refButton setTitle:NSLocalizedString(@"Info", nil) forState:UIControlStateNormal];
        [refButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        UIBarButtonItem *refBBI = [[UIBarButtonItem alloc] initWithCustomView:refButton];
        self.navigationItem.leftBarButtonItem = refBBI;
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, refBBI, nil] animated:NO];
    };
    
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
    
        UIBarButtonItem *refBBI = [[UIBarButtonItem alloc] initWithCustomView:qBtn];
        self.navigationItem.rightBarButtonItem = refBBI;
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, refBBI, nil] animated:NO];
    };

    if([UIScreen mainScreen].bounds.size.height >= 568.0f)
    {
        //spawn banner
        
        UIButton *bb = [[UIButton alloc]initWithFrame:
                        CGRectMake(
                                   ([UIScreen mainScreen].bounds.size.width - 300)/2,
                                   [UIScreen mainScreen].bounds.size.height - 150, 300.0f, 80.0f)];
        [bb setBackgroundImage:[UIImage imageNamed:@"home_banner.png"] forState:UIControlStateNormal];
        [bb addTarget:self
               action:@selector(bb:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:bb];
    }
    
//    [self animateSplasher];
}


- (void)animateSplasher
{
    NSMutableArray *arraya = [NSMutableArray array];
    for (int i=1; i<=55; i++) {
        NSString *imageName = [NSString stringWithFormat:@"nmags_splash%d",i];
        [arraya addObject:[UIImage imageNamed:imageName]];
    }
    
    UIImageView *animationView = [[UIImageView alloc]initWithFrame:self.view.frame];
    animationView.backgroundColor      = [UIColor clearColor];
    animationView.animationImages      = arraya;
    animationView.animationDuration    = 4;
    animationView.animationRepeatCount = 1;
    [animationView startAnimating];
    [self.view addSubview:animationView];
}

-(void)bb:(id)param
{
    //play full movie
    AppDelegate *adelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [adelegate playVideo:0];
}

- (void)pv:(id)param
{
    AppDelegate *adelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [adelegate playVideo:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showReachabilityError {

}

#pragma mark - UIButton - action methods

- (void)goToInfoPage:(id)sender{
    InfoController *infoViewController = [[InfoController alloc] init];
    [self.navigationController pushViewController:infoViewController animated:YES];
    [infoViewController release];

}

- (void)showReachabilityErro
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"It seems you don't have a working internet connection. Please check your Network Settings and try again!", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)  otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (IBAction)changeRegion:(id)sender{
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        [self showReachabilityError];
    } else {
        NSString *message = NSLocalizedString(@"Please select a region", nil);
        SelectRegionController *regionPicker = [[SelectRegionController alloc] initWithMessage:message forceSelect:NO];
        [self.navigationController pushViewController:regionPicker animated:YES];
        //[regionPicker release];    
    }
}

- (IBAction)goToFindCoupons:(id)sender{
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        [self showReachabilityError];
    } else {
        TabBarController *tabBarController = [[TabBarController alloc] init];
        [tabBarController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];

        [tabBarController setSelectedIndex:0];
        [self.navigationController presentModalViewController: tabBarController animated:YES];

//        tabBarController.view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.8];
//        self.navigationController.view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.8];

        [tabBarController release];
    }
}

- (IBAction)goToNearMe:(id)sender{
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        [self showReachabilityError];
    } else {
        TabBarController *tabBarController = [[TabBarController alloc] init];
        [tabBarController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        [tabBarController setSelectedIndex:1];
        [self.navigationController presentModalViewController: tabBarController animated:YES];
        
        [tabBarController release];
    }
}

- (IBAction)goToHotOffers:(id)sender{
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        [self showReachabilityError];
    } else {
        TabBarController *tabBarController = [[TabBarController alloc] init];
        [tabBarController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        [tabBarController setSelectedIndex:2];
        [self.navigationController presentModalViewController: tabBarController animated:YES];
        
        [tabBarController release];
    }
}

- (IBAction)goToFavourites:(id)sender{
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        [self showReachabilityError];
    } else {
        TabBarController *tabBarController = [[TabBarController alloc] init];
        [tabBarController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        [tabBarController setSelectedIndex:3];
        [self.navigationController presentModalViewController: tabBarController animated:YES];
        
        [tabBarController release];
    }
}

- (IBAction)goToMagazines:(id)sender{
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        [self showReachabilityError];
    } else {
        TabBarController *tabBarController = [[TabBarController alloc] init];
        [tabBarController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        [tabBarController setSelectedIndex:4];
        [self.navigationController presentModalViewController: tabBarController animated:YES];
        
        [tabBarController release];
    }
}

- (IBAction)openImageURL:(id)sender {
    RegionManager *regionManager = [RegionManager sharedInstance];

    if (![NSString isNilOrEmpty:[[regionManager region] regionImagePath]]) {
            
        NSURL *appStoreUrl = nil;
        NSRange foundHTTP = [[[regionManager region] regionImagePath] rangeOfString:@"http://"];
        
        if (NSNotFound == foundHTTP.location) {
            appStoreUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [[regionManager region] regionImagePath]]];
        } else {
            appStoreUrl = [NSURL URLWithString:[[regionManager region] regionImagePath]];
        }
        
        [[UIApplication sharedApplication] openURL:appStoreUrl];
    } 
}


- (void)regionWasChanged:(NSNotification *)aNotif {
    
    RegionManager *regionManager = [RegionManager sharedInstance];
    
    // set homescreen image

    [self.homeImageView setImageWithURL:[regionManager regionImageURL] placeholderImage:[UIImage imageNamed:@"default-homescreen.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [self.regionLabel setText:[[regionManager region] regionName]];
    
    [[UIApplication appDelegate] sendTokenToFCMServer:[Utility getFCMToken]];
    [[UIApplication appDelegate] sendRequestForAllCoupons];
}

- (void)showRegionAlert:(NSNotification *)aNotif
{
    _regionAlertDisplayed = YES;
    
    self.detectedRegion = [aNotif userInfo];

    RegionManager *regionManager = [RegionManager sharedInstance];    
    NSString *message = [NSString stringWithFormat:@"We detected your current location is ‘%@’. Is this correct?", [[regionManager region] regionName]];

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Change", nil)  otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        
        [alertView show];
        [alertView release];
}

#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex])
    {
        [self showRegion];
        //[regionPicker release];
    }
    else if (buttonIndex == [alertView firstOtherButtonIndex]) {
    
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"regionDetected" object:nil userInfo:self.detectedRegion];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"regionWasChanged" object:nil];
    }
}

- (void)showRegion {

    NSString* message = NSLocalizedString(@"Please select a region", nil);
    SelectRegionController *regionPicker = [[SelectRegionController alloc] initWithMessage:message forceSelect:YES];
    [self.navigationController pushViewController:regionPicker animated:NO];
}

@end
