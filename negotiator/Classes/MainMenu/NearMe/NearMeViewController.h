//
//  NearMeViewController.h
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

@interface NearMeViewController : MainController  < ASIHTTPRequestDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate> {
    
    NSMutableArray      *_couponsArray;
    
    UITableView         *_tableView;
    
    MKMapView           *_mapView;  
    
    LoadingView         *_loadingView;
    
    UILabel             *_noCouponsLabel;
    
    UIBarButtonItem     *_mapButton;
    UIBarButtonItem     *_listButton;
    
    int                 _couponsOffset;
    int                 _totalCoupons;
    
    BOOL                _firstLoad;
    
    ASIHTTPRequest      *_couponsRequest;
    
    UIButton *_view360;
}

@property (nonatomic, retain) NSMutableArray        *couponsArray;
@property (nonatomic, retain) UITableView           *tableView;
@property (nonatomic, retain) ASIHTTPRequest        *couponsRequest;
@property (nonatomic, retain) UIBarButtonItem       *mapButton;
@property (nonatomic, retain) UIBarButtonItem       *listButton;
@property (nonatomic, retain) UIButton *view360;

- (void)loadMoreDeals:(id)sender;

- (void)requestNearbyCoupons;
- (void)nearbyCouponsRequestFinished:(ASIHTTPRequest *)request;
- (void)nearbyCouponsRequestFailed:(ASIHTTPRequest *)request;

- (void)goToHomePage:(id)sender;
- (void)showMessageViewWithContent:(NSString *)content;


@end
