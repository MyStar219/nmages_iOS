//
//  TabBarController.m
//  negotiator
//
//  Created by Alexandru Chis on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TabBarController.h"

@implementation TabBarController

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self initializeTabBarItems];
    [self setDelegate:self];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(goToFavourites:) 
                                                 name:@"selectFavouritesView" 
                                               object:nil];
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {

    [super dealloc];
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

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

- (void)initializeTabBarItems {  
    
    FindCouponsViewController *findCouponsController = [[FindCouponsViewController alloc] init];
    UINavigationController *findCouponsNavController = [[UINavigationController alloc] initWithRootViewController:findCouponsController];
    [findCouponsController release];
    if ([[findCouponsNavController navigationBar] respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [[findCouponsNavController navigationBar] setBackgroundImage:[UIImage imageNamed:@"infoNavBar_bkgd.png"] 
                                                        forBarMetrics:UIBarMetricsDefault]; 
    }
    
    NearMeViewController *nearMeController = [[NearMeViewController alloc] init];
    UINavigationController *nearMeNavController = [[UINavigationController alloc] initWithRootViewController:nearMeController];
    [nearMeController release];
    if ([[nearMeNavController navigationBar] respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [[nearMeNavController navigationBar] setBackgroundImage:[UIImage imageNamed:@"infoNavBar_bkgd.png"] 
                                                        forBarMetrics:UIBarMetricsDefault]; 
    }
    
    HotOffersViewController *hotOffersController = [[HotOffersViewController alloc] init];
    UINavigationController *hotOffersNavController = [[UINavigationController alloc] initWithRootViewController:hotOffersController];
    [hotOffersController release];
    if ([[hotOffersNavController navigationBar] respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [[hotOffersNavController navigationBar] setBackgroundImage:[UIImage imageNamed:@"infoNavBar_bkgd.png"] 
                                                   forBarMetrics:UIBarMetricsDefault]; 
    }
    
    FavouritesViewController *favouritesController = [[FavouritesViewController alloc] init];
    UINavigationController *favouritesNavController = [[UINavigationController alloc] initWithRootViewController:favouritesController];
    [favouritesController release];
    if ([[favouritesNavController navigationBar] respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [[favouritesNavController navigationBar] setBackgroundImage:[UIImage imageNamed:@"infoNavBar_bkgd.png"] 
                                                   forBarMetrics:UIBarMetricsDefault]; 
    }
    
    MagazinesViewController *magazinesController = [[MagazinesViewController alloc] init];
    UINavigationController *magazinesNavController = [[UINavigationController alloc] initWithRootViewController:magazinesController];
    [magazinesController release];
    if ([[magazinesNavController navigationBar] respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [[magazinesNavController navigationBar] setBackgroundImage:[UIImage imageNamed:@"infoNavBar_bkgd.png"] 
                                                   forBarMetrics:UIBarMetricsDefault]; 
    }
    
    NSMutableArray *tabBarArray = [[NSMutableArray alloc] init];    
    
    [tabBarArray addObject:findCouponsNavController];
    [findCouponsNavController release];
    
    [tabBarArray addObject:nearMeNavController];
    [nearMeNavController release];
    
    [tabBarArray addObject:hotOffersNavController];
    [hotOffersNavController release];
    
    [tabBarArray addObject:favouritesNavController];
    [favouritesNavController release];
    
    [tabBarArray addObject:magazinesNavController];
    [magazinesNavController release];

    
    self.viewControllers = [NSArray arrayWithArray:tabBarArray];
    [tabBarArray release];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{

        UINavigationController *navController = (UINavigationController *)viewController;
        [navController popToRootViewControllerAnimated:NO];
    
}

- (void)goToFavourites:(id)sender {
    [self setSelectedIndex:3];
}

@end
