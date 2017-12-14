//
//  IntroController.h
//  pocketmate
//
//  Created by Andrei Vig on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface IntroController : UIViewController <ASIHTTPRequestDelegate, UIAlertViewDelegate> {
    NSTimer *_gatherLocationTimer;
    NSTimer *_regionRequestTimeOut;
    NSUInteger _gatherLocationIteration;
    CLLocation *_bestLocation;

    ASIHTTPRequest *_bestRegionRequest;
    
    UIView *_loadingView;
}

@property (nonatomic, retain) NSTimer *gatherLocationTimer;
@property (nonatomic, retain) NSTimer *regionRequestTimeOut;
@property (nonatomic, retain) CLLocation *bestLocation;
@property (nonatomic, retain) ASIHTTPRequest *bestRegionRequest;
@property (nonatomic, retain) ASIHTTPRequest *regionsRequest;
@property (nonatomic, retain) UIView *loadingView;

- (void)requestRegionForLocation;
- (void)requestRegionForLocationDidFinish:(ASIHTTPRequest *)request;
- (void)requestRegionForLocationDidFail:(ASIHTTPRequest *)request;

- (void)showRegionPicker;
- (void)locationDetectionFailed;

- (void)userAcceptedUseOfLocation:(NSNotification *)aNotif;
- (void)userDeniedUseOfLocation:(NSNotification *)aNotif;

- (void)gatherLocation:(NSTimer *)aTimer;

@end
