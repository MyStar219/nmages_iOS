//
//  WebsiteViewController.m
//  negotiator
//
//  Created by Vig Andrei on 1/17/12.
//  Copyright (c) 2012 Dot IT Mobile. All rights reserved.
//

#import "WebsiteViewController.h"

@implementation WebsiteViewController

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
    
    [self.view setBackgroundColor:[UIColor redColor]];
    
    // create web view
    _websiteWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 416.0)];
    [_websiteWebView setDelegate:self];
    [self.view addSubview:_websiteWebView];
    [_websiteWebView release];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    NSString *urlAddress = @"http://www.nmags.com";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_websiteWebView loadRequest:requestObj];
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

@end
