//
//  MenuController.h
//  negotiator
//
//  Created by Andrei Vig on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarController.h"

@interface MenuController : MainController {
//    TabBarController        *_tabBarController;
    
    UILabel        *_regionLabel;
    
    UIImageView     *_homeImageView;
    UIButton       *_changeRegionBtn;    
    UIButton       *_findCouponsBtn;
    UIButton       *_nearMeBtn;
    UIButton       *_hotOffersBtn;
    UIButton       *_favouritesBtn;
    UIButton       *_magazinesBtn;
    UIButton       *_regionImageBtn;
    
    BOOL           _regionAlertDisplayed;
}

@property (retain, nonatomic) IBOutlet UIImageView *homeImageView;

@property (nonatomic, retain) IBOutlet UILabel *regionLabel;
@property (nonatomic, retain) IBOutlet UIButton *changeRegionBtn;
@property (nonatomic, retain) IBOutlet UIButton *findCouponsBtn;
@property (nonatomic, retain) IBOutlet UIButton *nearMeBtn;
@property (nonatomic, retain) IBOutlet UIButton *hotOffersBtn;
@property (nonatomic, retain) IBOutlet UIButton *favouritesBtn;
@property (nonatomic, retain) IBOutlet UIButton *magazinesBtn;
@property (nonatomic, retain) IBOutlet UIButton *regionImageBtn;

- (void)goToInfoPage:(id)sender;
- (void)showReachabilityError;

- (IBAction)changeRegion:(id)sender;

- (IBAction)goToFindCoupons:(id)sender;
- (IBAction)goToNearMe:(id)sender;
- (IBAction)goToHotOffers:(id)sender;
- (IBAction)goToFavourites:(id)sender;
- (IBAction)goToMagazines:(id)sender;
- (IBAction)openImageURL:(id)sender;

- (void)regionWasChanged:(NSNotification *)aNotif;
- (void)showRegionAlert:(NSNotification *)aNotif;

@end
