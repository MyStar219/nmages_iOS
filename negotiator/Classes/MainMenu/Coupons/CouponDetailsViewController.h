//
//  CouponDetailsViewController.h
//  negotiator
//
//  Created by Vig Andrei on 1/23/12.
//  Copyright (c) 2012 Dot IT Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Coupons.h"
#import "LoadingView.h"
#import "ASIHTTPRequest.h"
#import "NetworkHandler.h"
#import "RequestManager.h"
#import "Reachability.h"
#import "JSON.h"
#import "Utility.h"
#import "UIViewAdditions.h"
#import <AVFoundation/AVAudioPlayer.h>

@import Social;

@interface CouponDetailsViewController : MainController <MKMapViewDelegate, ASIHTTPRequestDelegate, AVAudioPlayerDelegate> {
    
    IBOutlet UILabel        *_couponsLeftLabel;
    IBOutlet UILabel        *_couponsNumberLeftLabel;
    IBOutlet UILabel        *_noCouponsLeft;
    IBOutlet UILabel        *_couponTitle;
    IBOutlet UILabel        *_companyName;
    IBOutlet UILabel        *_distanceLabel;
    IBOutlet UILabel        *_dayLeft;
    IBOutlet UILabel        *_hoursLeft;
    IBOutlet UILabel        *_minLeft;
    IBOutlet UILabel        *_secLeft;
    
    
    IBOutlet UIButton       *_useBtn;    
    IBOutlet UIButton       *_detailsBtn;
    IBOutlet UIButton       *_locationBtn;
    IBOutlet UIButton       *_shareBtn;
    
    IBOutlet UIImageView    *_backgroundImageView;
    
    Coupons                 *_couponsInfo;
    
    UIBarButtonItem         *_favoritesBtn;
    UIBarButtonItem         *_backBarBtn;
    UIBarButtonItem         *_backToDetails;
    
    UIView                  *_couponsDetailsView;    
    MKMapView               *_mapView;     
    UIImageView             *_couponImage;
    UIImageView             *_companyImage;
        
    LoadingView             *_loadingView;
    
    NSTimer                 *_timer;
    
    ASIHTTPRequest          *_addToFavRequest;
    
    UIView                  *_addressHeaderView;
    
    AVAudioPlayer           *_theAudio;
    AVAudioPlayer           *_openRedeemSound;

    
    NSCalendar              *_calendar;
    
    UIButton *_view360;
}

@property (nonatomic, retain) Coupons               *couponsInfo;
@property (nonatomic, retain) IBOutlet MKMapView    *mapView;
@property (nonatomic, retain) IBOutlet UIView       *couponsDetailsView;
@property (nonatomic, retain) UIImageView           *couponImage;
@property (nonatomic, retain) UIImageView           *companyImage;
@property (nonatomic, retain) UIBarButtonItem       *favouritesBtn;
@property (nonatomic, retain) UIBarButtonItem       *backBarBtn;
@property (nonatomic, retain) UIBarButtonItem       *backToDetails;
@property (nonatomic, retain) NSTimer               *timer;
@property (nonatomic, retain) ASIHTTPRequest        *addToFavRequest;
@property (nonatomic, retain) LoadingView           *loadingView;
@property (nonatomic, retain) UIView                *addressHeaderView;
@property (nonatomic, retain) NSCalendar            *calendar;
@property (nonatomic, retain) IBOutlet UIButton *view360;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil couponsInfo:(Coupons *)coupons;

- (IBAction)goToCouponViewScreen:(id)sender;
- (IBAction)goToCompanyDetails:(id)sender;
- (IBAction)goToShareCoupon:(id)sender;

- (IBAction)switchToCouponLocation:(id)sender;
- (void)switchToCouponDetails:(id)sender;

- (void)displayCouponImage;
- (void)displayCompanyImage;
- (void)refreshCouponsLeft;

- (void)goBackToList:(id)sender;
- (void)addToFavourites:(id)sender;

- (void)addToFavRequestFinished:(ASIHTTPRequest *)request;
- (void)addToFavRequestFailed:(ASIHTTPRequest *)request;
- (UIImage *)screenshot;

-(void)playAudio;

-(void)onTimer : (NSTimer *) timer;

-(IBAction)view360Map;

@end
