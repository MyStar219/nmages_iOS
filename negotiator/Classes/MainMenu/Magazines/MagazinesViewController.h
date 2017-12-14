//
//  MagazinesViewController.h
//  negotiator
//
//  Created by Alexandru Chis on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "LoadingView.h"
#import "NetworkHandler.h"
#import "Magazines.h"
#import <MapKit/MapKit.h>

@interface MagazinesViewController : MainController < ASIHTTPRequestDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>{
    
    NSArray             *_magazinesArray;
    
    UITableView         *_tableView;
    
    MKMapView           *_mapView;  
    
    LoadingView         *_loadingView;
    
    UIBarButtonItem     *_mapButton;
    UIBarButtonItem     *_listButton;
    
    UILabel             *_noMagazinesLabel;
    
    ASIHTTPRequest      *_magazinesRequest;
    
    UIButton *_view360;
}

@property (nonatomic, retain) MKMapView     *mapView;
@property (nonatomic, retain) NSArray       *magazinesArray;
@property (nonatomic, retain) UITableView   *tableView;
@property (nonatomic, retain) ASIHTTPRequest *magazinesRequest;
@property (nonatomic, retain) UIBarButtonItem   *mapButton;
@property (nonatomic, retain) UIBarButtonItem   *listButton;
@property (nonatomic, retain) UIButton *view360;

- (void)requestMagazines;
- (void)magazinesRequestFinished:(ASIHTTPRequest *)request;
- (void)magazinesRequestFailed:(ASIHTTPRequest *)request;

- (void)goToHomePage:(id)sender;
- (void)showMessageViewWithContent:(NSString *)content;

- (void)switchToMap:(id)sender;
- (void)switchToList:(id)sender;

@end
