//
//  CouponRedeemViewController.h
//  negotiator
//
//  Created by Alexandru Chis on 1/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Coupons.h"
#import "LoadingView.h"
#import "ASIHTTPRequest.h"
#import "NetworkHandler.h"
#import "RequestManager.h"
#import "Reachability.h"
#import "JSON.h"
#import "CouponDetailsViewController.h"
#import <AVFoundation/AVAudioPlayer.h> 

@interface CouponRedeemViewController : MainController <UIActionSheetDelegate, ASIHTTPRequestDelegate, UIScrollViewDelegate, UIAlertViewDelegate, AVAudioPlayerDelegate>{
    
    id                      _delegate;
    
    SEL                     _action;
    
    UIImageView             *_couponImage;
    
    Coupons                 *_coupons;
    
    LoadingView             *_loadingView;

    ASIHTTPRequest          *_redeemRequest;    
    
    AVAudioPlayer           *_theAudio;
    
    BOOL                    _failedToLoad;

    BOOL                    _optionsShowing;
    
    UIScrollView            *_scrollView;
    
    int                     _tapCount;
    
    UIView                  *_loadingViewImage;
    
    BOOL                    _loaded;
    
    UIBarButtonItem         *_backBarBtn;
    
    UIView                  *_bottomView;
    UIImageView             *_bottomBarImage;
    
    UIButton                *_redeemButton;
}

@property (nonatomic, retain) Coupons               *couponsInfo;
@property (nonatomic, retain) UIImageView           *couponImage;
@property (nonatomic, retain) ASIHTTPRequest        *redeemRequest;
@property (nonatomic, retain) UIScrollView          *scrollView;
@property (nonatomic, retain) UIView                *loadingViewImage;
@property (nonatomic, retain) UIImageView           *bottomBarImage;
@property (nonatomic, retain) UIView                *bottomView;


- (id)initWithCouponInfo:(Coupons *)coupons;

- (void)displayCouponImage;

- (void)failedToLoadCouponImage;

- (void)hideLoadingView;

- (void)hideActivityView; 

- (void)goBackToCouponDetails:(id)sender;
- (void)goBack:(id)sender;

- (void)redeemCoupon:(id)sender;
    
- (void)redeemRequestFinished:(ASIHTTPRequest *)request;
- (void)redeemRequestFailed:(ASIHTTPRequest *)request;
    
- (void) handleSingleTap:(UITapGestureRecognizer*)recognizer ;
- (void) handleDoubleTap:(UITapGestureRecognizer*)recognizer ;
    
- (void)countTaps;

-(void)playAudio;

@end
