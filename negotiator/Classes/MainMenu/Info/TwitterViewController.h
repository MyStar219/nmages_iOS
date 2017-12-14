//
//  TwitterViewController.h
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


@interface TwitterViewController : UIViewController <UIWebViewDelegate> {
    
    UIWebView *_twitterWebView;
    
    LoadingView     *_loadingView;
    
    BOOL            _twitterLoaded;
    
}

@end
