//
//  InfoController.m
//  negotiator
//
//  Created by Vig Andrei on 1/17/12.
//  Copyright (c) 2012 Dot IT Mobile. All rights reserved.
//

#import "InfoController.h"
#import "RequestManager.h"
#import "ASIHTTPRequest.h"
#import "AboutUSController.h"
#import "TermsViewController.h"
#import "TabBarController.h"

@implementation InfoController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    self.title = @"About Us";
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UINavigationBar *navBar = [[self navigationController] navigationBar];
//    UIImage *backgroundImage = [UIImage imageNamed:@"infoNavBar_bkgd.png"];
//    [navBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 30.0)];
    [homeButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [homeButton setBackgroundImage:[UIImage imageNamed:@"home_btn.png"] forState:UIControlStateNormal];
    [homeButton setTitle:NSLocalizedString(@"  Home", nil) forState:UIControlStateNormal];
    [homeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
    [homeButton release];
    
    [self.navigationItem setLeftBarButtonItem:backButton animated:YES];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, backButton, nil] animated:NO];
    };
    
    [backButton release];

    // Do any additional setup after loading the view from its nib.
}

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

#pragma mark - UIButton - action methods

- (void)goToAboutNegotiator:(id)sender{
    AboutUSController *aboutController = [[AboutUSController alloc] init];
    [self.navigationController pushViewController:aboutController animated:YES];
    [aboutController release];
}

- (IBAction)goToFacebook:(id)sender{
    NSURL *facebookURL = [NSURL URLWithString:LIKE_US_FACEBOOK_URL];
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
        
        [[UIApplication sharedApplication] openURL:facebookURL options:@{} completionHandler:^(BOOL success) {
        }];
#else
        
        [[UIApplication sharedApplication] openURL:facebookURL];
        
#endif
    }
}

- (IBAction)goToTwitter:(id)sender{
    NSURL *twitterURL = [NSURL URLWithString:FOLLOW_US_TWITTER_URL];
    if ([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
        
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
        
        [[UIApplication sharedApplication] openURL:twitterURL options:@{} completionHandler:^(BOOL success) {
        }];
#else
        
        [[UIApplication sharedApplication] openURL:twitterURL];
        
#endif
    }
}

- (IBAction)goToWebsite:(id)sender{
    NSURL *websiteURL = [NSURL URLWithString:WEBSITE_URL];
    if ([[UIApplication sharedApplication] canOpenURL:websiteURL]) {
        
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
        
        [[UIApplication sharedApplication] openURL:websiteURL options:@{} completionHandler:^(BOOL success) {
        }];
#else
        
        [[UIApplication sharedApplication] openURL:websiteURL];
        
#endif
    }
}

- (IBAction)goToFeedback:(id)sender{
  
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        
        [mailComposer setDelegate:self];
        [mailComposer setMailComposeDelegate:self];
        [mailComposer setSubject:NSLocalizedString(@"Negotiator App Feedback", nil)];
        [mailComposer setToRecipients:[NSArray arrayWithObject:EMAIL_ADDRESS]];
        [mailComposer setTitle:@""];
        
        if ([[mailComposer navigationBar] respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
            [[mailComposer navigationBar] setBackgroundImage:[UIImage imageNamed:@"infoNavBar_bkgd.png"] 
                                               forBarMetrics:UIBarMetricsDefault]; 
        }
        
        [[mailComposer navigationBar] setTintColor:[UIColor redNavColor]];
        
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
        
        [self.navigationController presentViewController:mailComposer animated:YES completion:nil];
#else
        
        [self.navigationController presentModalViewController:mailComposer animated:YES];
#endif
        
        [mailComposer release];
    } else {
        NSString *message = NSLocalizedString(@"This device is not configured for sending emails!", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message 
                                                        message:nil 
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:NSLocalizedString(@"Ok", nil), nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)goToAdvertising:(id)sender{
   
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        
        [mailComposer setDelegate:self];
        [mailComposer setMailComposeDelegate:self];
        [mailComposer setSubject:NSLocalizedString(@"Negotiator Advertising Enquiry", nil)];
        [mailComposer setToRecipients:[NSArray arrayWithObject:EMAIL_ADDRESS]];
        [mailComposer setTitle:@""];
        
        if ([[mailComposer navigationBar] respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
            [[mailComposer navigationBar] setBackgroundImage:[UIImage imageNamed:@"infoNavBar_bkgd.png"] 
                                                         forBarMetrics:UIBarMetricsDefault]; 
        }
        
        [[mailComposer navigationBar] setTintColor:[UIColor redNavColor]];
        
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
        
        [self.navigationController presentViewController:mailComposer animated:YES completion:nil];
#else
        
        [self.navigationController presentModalViewController:mailComposer animated:YES];
#endif
        
        [mailComposer release];
    } else {
        NSString *message = NSLocalizedString(@"This device is not configured for sending emails!", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message 
                                                        message:nil 
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:NSLocalizedString(@"Ok", nil), nil];
        [alert show];
        [alert release];
    }
}

//- (IBAction)goToTerms:(id)sender{
//
//    TermsViewController *termsController = [[TermsViewController alloc] init];
//    [self.navigationController pushViewController:termsController animated:YES];
//    [termsController release];
//    
//}

- (void)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//- (UIView *)titleView {
//    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 180.0, 40.0)];
//    
//    UIButton *titleButton = [[UIButton alloc] initWithFrame:titleView.bounds];
//    [titleButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
//    [titleButton setBackgroundColor:[UIColor clearColor]];
//    [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [titleButton setTitle:NSLocalizedString(@"About", nil) forState:UIControlStateNormal];
//    [titleButton setEnabled:NO];
//    [titleView addSubview:titleButton];
//    [titleButton release];
//    
//    return [titleView autorelease];
//}


#pragma mark --- MFMailComposerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
#if defined(__IPHONE_9_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
#else
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
#endif
    
}


@end
