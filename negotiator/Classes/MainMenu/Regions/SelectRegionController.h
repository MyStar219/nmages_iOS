//
//  SelectRegionController.h
//  negotiator
//
//  Created by Andrei Vig on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "Reachability.h"
#import "Utility.h"

@class LoadingView;

@interface SelectRegionController : MainController <UITableViewDelegate, UITableViewDataSource, ASIHTTPRequestDelegate> {

    UITableView *_tableView;
    NSString *_headerMessage;
    
    LoadingView *_loadingView;
    
    ASIHTTPRequest *_regionsRequest;
    NSMutableArray *_regions;
    
    BOOL _forceSelect;
    
    UIBarButtonItem *_backButton;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSString *headerMessage;
@property (nonatomic, retain) LoadingView *loadingView;
@property (nonatomic, retain) ASIHTTPRequest *regionsRequest;
@property (nonatomic, retain) NSMutableArray *regions;
@property (nonatomic, assign) BOOL forceSelect;
@property (nonatomic, retain) UIBarButtonItem *backButton;

- (id)initWithMessage:(NSString *)message forceSelect:(BOOL)forceSelect;

- (void)requestRegions;
- (void)regionsRequestDidFinish:(ASIHTTPRequest *)request;
- (void)regionsRequestDidFail:(ASIHTTPRequest *)request;

- (void)goBack:(id)sender;

@end
