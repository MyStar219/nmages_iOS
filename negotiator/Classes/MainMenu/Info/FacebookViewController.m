//
//  FacebookViewController.m
//  negotiator
//
//  Created by Vig Andrei on 1/17/12.
//  Copyright (c) 2012 Dot IT Mobile. All rights reserved.
//

#import "FacebookViewController.h"

@implementation FacebookViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)loadView{
    
    [super loadView];
    
    //create the loading view
    _loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0.0, 
                                                                 0.0, 
                                                                 320.0, 
                                                                 416.0) 
                                                message:NSLocalizedString(@"Loading ...", nil) 
                                                messageFont:[UIFont boldSystemFontOfSize:13.0]
                                                style:LoadingViewBlack
                                                roundedCorners:NO];
    

    //Add elements to the main view
    [self.view addSubview:_loadingView];
    [_loadingView release];

    
    
    [self.view setBackgroundColor:[UIColor redColor]];
    
    // create web view
    _facebookWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 416.0)];
    [_facebookWebView setDelegate:self];
    [self.view addSubview:_facebookWebView];
    [_facebookWebView release];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    
    if (!_facebookLoaded) {
        [_loadingView show];
    
    NSString *urlAddress = @"http://www.facebook.com/pages/Negotiator-Magazine/135370159818331";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_facebookWebView loadRequest:requestObj];
    }
}


#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    
//    [_loadingView hide];
//    
//    if (webView == _facebookWebView) {
//        _facebookLoaded = YES;
//    } 
//}


@end
