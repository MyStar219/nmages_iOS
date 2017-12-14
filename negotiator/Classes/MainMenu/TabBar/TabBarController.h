//
//  TabBarController.h
//  negotiator
//
//  Created by Alexandru Chis on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FindCouponsViewController.h"
#import "NearMeViewController.h"
#import "HotOffersViewController.h"
#import "FavouritesViewController.h"
#import "MagazinesViewController.h"

@interface TabBarController : UITabBarController <UITabBarControllerDelegate>{

}

- (void)initializeTabBarItems;

@end
