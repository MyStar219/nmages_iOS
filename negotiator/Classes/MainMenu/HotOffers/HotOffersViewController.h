//
//  HotOffersViewController.h
//  negotiator
//
//  Created by Vig Andrei on 1/19/12.
//  Copyright (c) 2012 Dot IT Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "LoadingView.h"
#import "NetworkHandler.h"
#import "Coupons.h"
#import <MapKit/MapKit.h>
#import "AppDelegate.h"

@interface HotOffersViewController : MainController < ASIHTTPRequestDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>{
   

    NSArray             *_hotOffersArray;

    MKMapView           *_mapView;  
    
    UITableView         *_tableView;
    
    LoadingView         *_loadingView;
    
    UIBarButtonItem     *_mapButton;
    UIBarButtonItem     *_listButton;
    
    UILabel             *_noCouponsLabel;
    UILabel             *_regionLabel;
    
    ASIHTTPRequest      *_hotOffersRequest;
    
    UIButton *_view360;
}


@property (nonatomic, retain) NSArray           *hotOffersArray;
@property (nonatomic, retain) MKMapView         *mapView;
@property (nonatomic, retain) UITableView       *tableView;
@property (nonatomic, retain) UILabel           *regionLabel;
@property (nonatomic, retain) ASIHTTPRequest    *hotOffersRequest;
@property (nonatomic, retain) UIBarButtonItem   *mapButton;
@property (nonatomic, retain) UIBarButtonItem   *listButton;
@property (nonatomic, retain) UIButton *view360;

- (void)requestHotOffers;
- (void)hotOffersRequestFinished:(ASIHTTPRequest *)request;
- (void)hotOffersRequestFailed:(ASIHTTPRequest *)request;

- (void)goToHomePage:(id)sender;
- (void)changeRegion:(id)sender;
- (void)showMessageViewWithContent:(NSString *)message;

- (void)switchToMap:(id)sender;
- (void)switchToList:(id)sender;

@end
