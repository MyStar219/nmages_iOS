//
//  IntroController.m
//  pocketmate
//
//  Created by Andrei Vig on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "IntroController.h"
#import "LocationUtiliy.h"
#import "RequestManager.h"
#import "SelectRegionController.h"
#import "RegionManager.h"
#import "FavouritesBadgeManager.h"
#import "UIView+Additions.h"

@implementation IntroController

@synthesize gatherLocationTimer     = _gatherLocationTimer;
@synthesize regionRequestTimeOut    = _regionRequestTimeOut;
@synthesize bestLocation            = _bestLocation;

@synthesize bestRegionRequest   = _bestRegionRequest;
@synthesize regionsRequest      = _regionsRequest;
@synthesize loadingView         = _loadingView;

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userAcceptedUseOfLocation:) 
                                                 name:@"userAcceptedUseOfLocation" 
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDeniedUseOfLocation:) 
                                                 name:@"userDeniedUseOfLocation" 
                                               object:nil];
    
    _gatherLocationIteration = 0;
    
    return self;
}

- (void)dealloc {

    self.bestLocation = nil;
    
    if (self.bestRegionRequest) {
        [self.bestRegionRequest clearDelegatesAndCancel];
        self.bestRegionRequest = nil;
    }
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    NSLog(@"%s", __FUNCTION__);
    [super loadView];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    UIImageView *backgroundView = nil;
    backgroundView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [backgroundView setImage:[UIImage imageNamed:@"Default-568h.png"]];
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];

    /*[backgroundView setFrame:CGRectOffset(backgroundView.frame, 0.0, - CGRectGetHeight(statusBarFrame))];
    CGRect frame = backgroundView.frame;
    frame.origin.y = 0.0f;
    frame.size.height += 20.0f;
    backgroundView.frame = frame;*/

    [self.view addSubview:backgroundView];
    [backgroundView release];    
    
    CGFloat factor = 100.0f;
    if([[UIScreen mainScreen]bounds].size.height == 568)
    {
        factor = 160.0f;
    }
    _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, factor)];
    [_loadingView setClipsToBounds:YES];
    [_loadingView.layer setCornerRadius:15.0];
    [_loadingView.layer setBorderColor:[[UIColor grayColor] CGColor]]; 
    [_loadingView.layer setBorderWidth:1.0];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, factor)];
    [backView setBackgroundColor:[UIColor blackColor]];
    [backView setAlpha:0.9];
    [_loadingView addSubview:backView];
    [backView release];
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, factor)];
    [loadingLabel setBackgroundColor:[UIColor clearColor]];
    [loadingLabel setTextAlignment:UITextAlignmentCenter];
    [loadingLabel setNumberOfLines:5.0];
    [loadingLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
    [loadingLabel setTextColor:[UIColor whiteColor]];
    [loadingLabel setText:NSLocalizedString(@"Detecting your current location \n\r \n\r Please wait", nil)];
    [_loadingView addSubview:loadingLabel];
    [loadingLabel release];
    
    UIActivityIndicatorView *wheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [wheel startAnimating];
    [wheel setCenter:CGPointMake(125.0, factor / 2.0f)];
    [_loadingView addSubview:wheel];
    [wheel release];
    
    [self.view addSubview:_loadingView];
    [_loadingView release];
    
    [_loadingView setAlpha:0.0];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%s", __FUNCTION__);
    [self.loadingView setCenter:CGPointMake(self.view.center.x, self.view.center.y - 16) ];
}

- (void)viewDidUnload {
    [super viewDidUnload];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%s", __FUNCTION__);
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                   {
                       if ([CLLocationManager locationServicesEnabled])
                       {
                           [[LocationUtiliy sharedInstance] start];
                       }
                       else
                       {
                           [self showRegionPicker];
                       }
                   });
}

- (BOOL)detectUserLocation:(NSNotification *)notification {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                   {
                       if ([CLLocationManager locationServicesEnabled])
                       {
                           [[LocationUtiliy sharedInstance] start];
                       }
                       else
                       {
                           [self showRegionPicker];
                       }
                   });
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)userAcceptedUseOfLocation:(NSNotification *)aNotif
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    [self.loadingView setAlpha:1.0];
    
    [UIView commitAnimations];
    
    /* if user accepted use of location we need to get the best location possible */
    //self.gatherLocationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
    //                                                            target:self
    //                                                          selector:@selector(gatherLocation:)
    //                                                          userInfo:nil
    //                                                           repeats:YES];
    
    self.bestLocation = [[LocationUtiliy sharedInstance] currentLocation];
    [self requestRegionForLocation];
}

- (void)userDeniedUseOfLocation:(NSNotification *)aNotif {
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController dismissModalViewControllerAnimated:YES];
    /* if user denied he needs to select the region manually */
}

- (void)gatherLocation:(NSTimer *)aTimer
{
    // increment gather iteration
    _gatherLocationIteration++;
    
    // get new available location
    CLLocation *location = [[LocationUtiliy sharedInstance] currentLocation];
    
    if (nil == self.bestLocation) {
        self.bestLocation = location;
    } else {
        // retain the location which has the best accuracy
        
        if ([location horizontalAccuracy] < [self.bestLocation horizontalAccuracy]) {
            self.bestLocation = location;
        }
    }
    
    // an accuracy of 100m is good enough for us to get the region for the user
    // also if we got to the 10th iteration we need to stop
    if ((100 > [self.bestLocation horizontalAccuracy]) || (_gatherLocationIteration > 10)) {
        
        // stop gather location timer
        if (self.gatherLocationTimer) {
            [self.gatherLocationTimer invalidate];
            self.gatherLocationTimer = nil;
        }
        
        // request region for what location we managed to gather
        [self requestRegionForLocation];
    }
}

- (void)requestRegionForLocation {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // if we don't have a best location user has to pick one
    if (nil == self.bestLocation) {
        [self showRegionPicker];
        return;
    } else {
        CLLocationCoordinate2D coordinates = self.bestLocation.coordinate;
//        CLLocationCoordinate2D coordinates;
        
        [parameters setObject:[NSString stringWithFormat:@"%.6f", coordinates.latitude] forKey:@"latitude"];
        [parameters setObject:[NSString stringWithFormat:@"%.6f", coordinates.longitude] forKey:@"longitude"];
        
        // set type of display
        BOOL retinaDisplay = [UIApplication supportsRetinaDisplay];
        [parameters setObject:retinaDisplay ? @"1" : @"0" forKey:@"retina_support"];
        
    }
    
    self.bestRegionRequest = [[RequestManager sharedInstance] requestWithMethodName:@"regions/getRegionForLocation" 
                                                                       methodType:@"GET"
                                                                       parameters:parameters 
                                                                         delegate:self 
                                                                           secure:NO
                                                                   withAuthParams:NO];
        
    [self.bestRegionRequest setDidFinishSelector:@selector(requestRegionForLocationDidFinish:)];
    [self.bestRegionRequest setDidFailSelector:@selector(requestRegionForLocationDidFail:)];

    [self.bestRegionRequest startAsynchronous];
    
    self.regionRequestTimeOut = [NSTimer scheduledTimerWithTimeInterval:5.5 
                                                                target:self 
                                                              selector:@selector(locationDetectionFailed) 
                                                              userInfo:nil
                                                               repeats:NO];
}

- (void)requestRegionForLocationDidFinish:(ASIHTTPRequest *)request {
    
    [self.regionRequestTimeOut invalidate];
    
//    self.regionRequestTimeOut = nil;
    
    BOOL failedToGetARegion = NO;
    
    NSString *response = [request responseString];
    if (![NSString isNilOrEmpty:response]) {
        id regions = [response JSONValue];
        
        NSLog(@"%s \n", __FUNCTION__);
        NSLog(@"Regions: %@", regions);
        
        if (([regions respondsToSelector:@selector(objectAtIndex:)]) && ([regions count] > 0)) {
            
            NSDictionary *region = [regions lastObject];
            
            RegionObject *regionObject = [[RegionObject alloc] initWithDictionary:region];
            
            NSNumber *favBadgeNumber = [NSNumber numberWithInt: [[region objectForKey:@"favourites_count"] intValue]];
            [[FavouritesBadgeManager sharedInstance] setBadgeNumber:favBadgeNumber];
            [[FavouritesBadgeManager sharedInstance] saveBadgeNumber];
            
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[FavouritesBadgeManager sharedInstance] badgeNumber] intValue]];
            
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            NSDictionary *regionInfo     = [userDefaults objectForKey:kRegionInfoKey];
            NSString *regionId = [regionInfo objectForKey:kRegionIdKey];
            
            BOOL isRegionChanged = NO;
            
            if (regionId != nil && ![regionId isEqualToString:@""]) {
                
                if (regionObject.regionId == regionId) {
                 
                    isRegionChanged = NO;
                }
                else {
                
//                    RegionManager *regionManager = [RegionManager sharedInstance];
//                    
//                    [regionManager setNewRegion:regionObject];

                    
                    isRegionChanged = YES;
                }
            }
            
            [self postNotificationWithRegion:region isRegionChanged:isRegionChanged];
            
            
            return;
        } else {
            failedToGetARegion = YES;
        }
        
    } else {
        failedToGetARegion = YES;
    }
    
    if (failedToGetARegion) {
        [[[RegionManager sharedInstance] region] setRegionId:@""];
        [[RegionManager sharedInstance] saveRegionInfo];
        [self showRegionPicker];
    }
}

- (void)postNotificationWithRegion:(NSDictionary *)region isRegionChanged:(BOOL)isRegionChanged {
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"regionDetected" object:nil userInfo:region];

    [self dismissViewControllerAnimated:YES completion:^{
        
    }];

}

- (void)requestRegionForLocationDidFail:(ASIHTTPRequest *)request {

    [self.regionRequestTimeOut invalidate];
    
    self.regionRequestTimeOut = nil;
    
    [self locationDetectionFailed];
}


- (void)locationDetectionFailed {
    
    [self.loadingView setAlpha:0.0];

    [[[RegionManager sharedInstance] region] setRegionId:@""];
    [[RegionManager sharedInstance] saveRegionInfo];
    
    [self showRegionPicker];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (void)showRegionPicker {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showRegionPicker"
                                                        object:nil];
    
}

@end
