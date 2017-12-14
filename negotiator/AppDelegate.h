//
//  AppDelegate.h
//  negotiator
//
//  Created by Andrei Vig on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "ASIHTTPRequest.h"
#import "NetworkHandler.h"
#import <CoreData/CoreData.h>
#import "CouponDetailsViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, ASIHTTPRequestDelegate> {
    UINavigationController *_navController;
    LoadingView         *_loadingView;
    
}

@property (nonatomic, retain) ASIHTTPRequest *webRequest;
@property (nonatomic, retain) LoadingView           *loadingView;
@property (nonatomic, retain) NSString *regionName;
@property (nonatomic, retain) NSString *magazineName;
@property (nonatomic, retain) NSString *couponId;

@property (nonatomic, retain) UINavigationController *navController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (strong, nonatomic) UITapGestureRecognizer *tgr;

- (void)regionDetected:(NSNotification *)aNotif;
- (void)showRegionPicker:(NSNotification *)aNotif;

-(void)playVideo:(NSTimeInterval)sec;
- (void)saveContext;
- (void)sendTokenToFCMServer:(NSString *)token;
- (void)sendRequestForAllCoupons;

@end
