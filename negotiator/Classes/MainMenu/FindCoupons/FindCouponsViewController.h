//
//  FindCouponsViewController.h
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
#import "FindCouponsCell.h"
#import "AppDelegate.h"
#import "PRARManager.h"

typedef enum CouponCategories {
	Category1 = 0,
    Category2 = 1,
	Category3 = 2,
    Category4 = 3,
    Category5 = 4,
    Category6 = 5,
    Category7 = 6,
    Category8 = 7,
    Category9 = 8,
    Category10 = 9,
    Category11 = 10,
    Category12 = 11,
    Category13 = 12,
    Category14 = 13,
    Category15 = 14,
    Category16 = 15
} CouponCategories;


@interface FindCouponsViewController : MainController < ASIHTTPRequestDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    
    NSMutableDictionary *_couponsDictionary;
    NSMutableDictionary *_searchResultsDictionary;
    
    NSMutableDictionary *_rowsToShow;
    
    NSMutableArray      *_couponsArray;
    NSArray             *_searchResults;
    
    UITableView         *_tableView;
    UISearchDisplayController *_searchController;
    
    UILabel             *_noCouponsLabel;
    UILabel             *_regionNameLabel;
    
    UIBarButtonItem     *_mapButton;
    UIBarButtonItem     *_listButton;
    
    MKMapView           *_mapView;  
    
    LoadingView         *_loadingView;
    
    ASIHTTPRequest      *_couponsRequest;
    
    UIButton *_view360;
}
@property (nonatomic, retain) NSMutableDictionary   *searchResultsDictionary;
@property (nonatomic, retain) NSArray               *searchResults;
@property (nonatomic, retain) NSMutableDictionary   *couponsDictionary;
@property (nonatomic, retain) NSMutableDictionary   *rowsToShow;
@property (nonatomic, retain) NSMutableArray        *couponsArray;
@property (nonatomic, retain) UITableView           *tableView;
@property (nonatomic, retain) UILabel               *regionNameLabel;
@property (nonatomic, retain) ASIHTTPRequest        *couponsRequest;
@property (nonatomic, retain) UIBarButtonItem       *mapButton;
@property (nonatomic, retain) UIBarButtonItem       *listButton;
@property (nonatomic, retain) LoadingView           *loadingView;
@property (nonatomic, retain) UIButton *view360;

@property (nonatomic, retain) UISearchDisplayController *searchController;

- (void)requestCoupons;
- (void)couponsRequestFinished:(ASIHTTPRequest *)request;
- (void)couponsRequestFailed:(ASIHTTPRequest *)request;

- (void)toggleSection:(id)sender;
- (void)goToHomePage:(id)sender;
- (void)changeRegion:(id)sender;

- (void)showMessageViewWithContent:(NSString *)content;

- (void)regionWasChanged:(NSNotification *)aNotif;
- (void)couponUsed:(NSNotification *)aNotif;

@end
