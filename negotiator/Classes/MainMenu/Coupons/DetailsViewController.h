//
//  DetailsViewController.h
//  negotiator
//
//  Created by Vig Andrei on 1/23/12.
//  Copyright (c) 2012 Dot IT Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "NetworkHandler.h"
#import "Coupons.h"


@interface DetailsViewController : MainController <UITableViewDataSource, UITableViewDelegate>{
    
    Coupons *_couponsInfo;
    
    UITableView         *_tableView;
    NSMutableArray      *_infoData;
    NSMutableArray      *_headerTitles;
    
    UIImageView         *_companyImage;
}

@property (nonatomic, retain) UITableView           *tableView;
@property (nonatomic, retain) NSMutableArray        *infoData;
@property (nonatomic, retain) NSMutableArray        *headerTitles;
@property (nonatomic, retain) UIImageView           *companyImage;
@property (nonatomic, retain) Coupons               *couponsInfo;

- (void)displayCompanyImage;

- (id)initWithCouponsInfo:(Coupons *)coupons;

@end
