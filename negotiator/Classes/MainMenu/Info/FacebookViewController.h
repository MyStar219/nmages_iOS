//
//  FacebookViewController.h
//  negotiator
//
//  Created by Vig Andrei on 1/17/12.
//  Copyright (c) 2012 Dot IT Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "ASIHTTPRequest.h"
#import "RequestManager.h"
#import "NetworkHandler.h"

@interface FacebookViewController : UIViewController <UIWebViewDelegate> {
    
    UIWebView *_facebookWebView;
    
    LoadingView     *_loadingView;
    
    BOOL            _facebookLoaded;
    
}

@end
