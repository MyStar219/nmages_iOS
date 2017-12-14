//
//  FavouritesViewController.h
//  negotiator
//
//  Created by Alexandru Chis on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "LoadingView.h"
#import "NetworkHandler.h"
#import "Coupons.h"
#import "CouponsCell.h"
#import "AppDelegate.h"

@interface FavouritesViewController : MainController < ASIHTTPRequestDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate> {
    
    NSMutableArray      *_couponsArray;
    
    UITableView         *_tableView;
    
    UILabel             *_noCouponsLabel;
    
    UIBarButtonItem     *_mapButton;
    UIBarButtonItem     *_listButton;
    
    MKMapView           *_mapView;  
    
    LoadingView         *_loadingView;
    
    ASIHTTPRequest      *_removeFavRequest;
    ASIHTTPRequest      *_couponsRequest;
}

@property (nonatomic, retain) NSMutableArray        *couponsArray;
@property (nonatomic, retain) UITableView           *tableView;
@property (nonatomic, retain) ASIHTTPRequest        *removeFavRequest;
@property (nonatomic, retain) ASIHTTPRequest        *couponsRequest;
@property (nonatomic, retain) UIBarButtonItem       *mapButton;
@property (nonatomic, retain) UIBarButtonItem       *listButton;

- (void)requestFavouriteCoupons;

- (void)favouriteCouponsRequestFinished:(ASIHTTPRequest *)request;
- (void)favouriteCouponsRequestFailed:(ASIHTTPRequest *)request;

- (void)removeFavouriteRequestFinished:(ASIHTTPRequest *)request;
- (void)removeFavouriteRequestFailed:(ASIHTTPRequest *)request;

- (void)goToHomePage:(id)sender;
- (void)showMessageViewWithContent:(NSString *)content;

@end
