//
//  TwitterController.m
//  SmartSaver
//
//  Created by Andrei Vig on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TwitterController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@implementation TwitterController

@synthesize tableView   = _tableView;

@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;

@synthesize loginView   = _loginView;
@synthesize postView    = _postView;

@synthesize twitterPostField = _twitterPostField;
@synthesize remainingCharactersLabel = _remainingCharactersLabel;

@synthesize twitterXAuth = _twitterXAuth;

- (id)init {
    self = [super init];
    if (!self) return nil;
    
//    [self.navigationItem setTitleView:[self titleView]];

    
    _twitterXAuth = [[TwitterXAuth alloc] init];
    //Neg
    self.twitterXAuth.consumerKey = @"Y0spzIDU0ssdOCASGscpA";
    self.twitterXAuth.consumerSecret = @"hTNS4N6LUPdze2Dmi6TlZmfqHOtafcmhByAfQZ8oY4";

    //Coff
//    self.twitterXAuth.consumerKey = @"hnVKNt0osN7f6xQjfow";
//    self.twitterXAuth.consumerSecret = @"6bL61aOhPbb4UMN8RvymcxHdop4M39XzqElpj0e94U";
    
    if ([UIApplication loggedInToTwitter]) {
        [self.twitterXAuth setToken:[UIApplication twitterToken]];
        [self.twitterXAuth setTokenSecret:[UIApplication twitterTokenSecret]];
    }
    
    [_twitterXAuth setDelegate:self];
    
    return self;
}

- (void)dealloc {
    self.twitterXAuth = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    
    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:self.view.frame];
    backgroundView.image = [UIImage imageNamed:@"info_bkgd.png"];
    [self.view addSubview:backgroundView];
    [backgroundView release];
    
    _loginView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_loginView setAlpha:0.0];
    [self.view addSubview:_loginView];
    [_loginView release];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setBackgroundView:backgroundView];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_loginView addSubview:_tableView];
    [_tableView release];
    
    _postView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_postView setAlpha:0.0];
    [self.view addSubview:_postView];
    [_postView release];
    
    NSUserDefaults *twitterDefaults = [NSUserDefaults standardUserDefaults ];
	NSString *message = [twitterDefaults objectForKey:@"TwitterDefaults" ];
    if ([message length] > 140) {
        message = [message substringToIndex:140];
    }
    
    _twitterPostField = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, 150.0)];
    [_twitterPostField setDelegate:self];
    [_twitterPostField setFont:[UIFont systemFontOfSize:16.0]];
    [_twitterPostField.layer setCornerRadius:4.0];
    [_twitterPostField setText:message];
    [_postView addSubview:_twitterPostField];
    [_twitterPostField release];
    
    _remainingCharactersLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 170.0, 280.0, 15.0)];
    [_remainingCharactersLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [_remainingCharactersLabel setTextAlignment:UITextAlignmentRight];
    [_remainingCharactersLabel setBackgroundColor:[UIColor clearColor]];
    [_remainingCharactersLabel setTextColor:[UIColor whiteColor]];
    //[_remainingCharactersLabel setText:@"140"];
    [_remainingCharactersLabel setText:[NSString stringWithFormat:@"%d", 140 - [_twitterPostField.text length]]];
    [_postView addSubview:_remainingCharactersLabel];
    [_remainingCharactersLabel release];
    
    _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(30.0, 9.0, 280.0, 30.0)];
    [_usernameTextField setDelegate:self];
    [_usernameTextField setPlaceholder:NSLocalizedString(@"Username / Email", nil)];
    [_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_usernameTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    [_usernameTextField setReturnKeyType:UIReturnKeyGo];
    
    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(30.0, 9.0, 280.0, 30.0)];
    [_passwordTextField setDelegate:self];
    [_passwordTextField setSecureTextEntry:YES];
    [_passwordTextField setPlaceholder:NSLocalizedString(@"Password", nil)];
    [_passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_passwordTextField setSecureTextEntry:YES];
    [_passwordTextField setReturnKeyType:UIReturnKeyGo];
    
    _loadingView = [[LoadingView alloc] initWithFrame:self.view.bounds 
                                              message:NSLocalizedString(@"Loading ...", nil) 
                                          messageFont:[UIFont systemFontOfSize:16.0] 
                                                style:LoadingViewTranslucent 
                                       roundedCorners:NO];
    [_loadingView setAlpha:0.0];
    [self.view addSubview:_loadingView];
    [_loadingView release];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTintColor:[UIColor redColor]];
    
    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 30.0)];
    [homeButton addTarget:self action:@selector(goBackToShare:) forControlEvents:UIControlEventTouchUpInside];
    [homeButton setBackgroundImage:[UIImage imageNamed:@"home_btn.png"] forState:UIControlStateNormal];
    [homeButton setTitle:NSLocalizedString(@"  Back", nil) forState:UIControlStateNormal];
    [homeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
    [homeButton release];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
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

}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([UIApplication loggedInToTwitter]) {
        [self switchToPost];
    } else {
        [self switchToLogin];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)postTweet {
    NSString *tweet = [_twitterPostField text];
    if ([NSString isNilOrEmpty:tweet]) return;
    
    [_twitterPostField resignFirstResponder];
    [self showLoadingView];
    
    [self.twitterXAuth tweet:tweet];
}

- (void)switchToLogin {
    [UIView beginAnimations:@"showLogin" context:NULL];
    [UIView setAnimationDuration:0.5];
    
    [_loginView setAlpha:1.0];
    [_postView setAlpha:0.0];
    
    [UIView commitAnimations];
    
    [_usernameTextField becomeFirstResponder];
}

- (void)switchToPost {
    [UIView beginAnimations:@"showPost" context:NULL];
    [UIView setAnimationDuration:0.5];
    
    [_loginView setAlpha:0.0];
    [_postView setAlpha:1.0];
    
    [UIView commitAnimations];
    
    [_twitterPostField becomeFirstResponder];
    
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Post", nil) 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(postTweet)];
    
    [self.navigationItem setRightBarButtonItem:postButton animated:YES];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, postButton, nil] animated:NO];
    };
    [postButton release];
}

- (UIView *)titleView {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 180.0, 40.0)];
    
    UIButton *titleButton = [[UIButton alloc] initWithFrame:titleView.bounds];
    [titleButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [titleButton setBackgroundColor:[UIColor clearColor]];
    [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [titleButton setTitle:NSLocalizedString(@"Twitter", nil) forState:UIControlStateNormal];
    [titleButton setEnabled:NO];
    [titleView addSubview:titleButton];
    [titleButton release];
    
    return [titleView autorelease];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (0 == indexPath.row) {
        [cell addSubview:_usernameTextField];
    } else if (1 == indexPath.row) {
        [cell addSubview:_passwordTextField];
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *stubView = [[UIView alloc] initWithFrame:
                        CGRectMake(0.0, 0.0,
                                   [UIScreen mainScreen].bounds.size.width,
                                   60.0)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(10.0, 10.0,
                                       300.0,
                                       50.0)];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setTextAlignment:UITextAlignmentCenter];
    [headerLabel setText:NSLocalizedString(@"Enter your details to share on Twitter", nil)];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [headerLabel setNumberOfLines:0.0];
    [stubView addSubview:headerLabel];
    [headerLabel release];
    
    return [stubView autorelease];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *stubView = [[UIView alloc] initWithFrame:
                        CGRectMake(0.0, 0.0,
                                   [UIScreen mainScreen].bounds.size.width,
                                   60.0)];
    return [stubView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 60.0;
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    [self showLoadingView];
    
    NSString *username = _usernameTextField.text;
    NSString *password = _passwordTextField.text;

    [self.twitterXAuth setUsername:username];
    [self.twitterXAuth setPassword:password];
    
    [self.twitterXAuth authorize];
    
    return YES;
}

#pragma mark - UITextView Delegate
- (void)textViewDidChange:(UITextView *)textView {
    NSString *text = textView.text;
    
    if ([text length] > 140) {
        [textView setText:[text substringToIndex:140]];
    }
    
    [_remainingCharactersLabel setText:[NSString stringWithFormat:@"%d", 140 - [textView.text length]]];
}

#pragma mark - TwitterXAuth Delegate
- (void) twitterXAuthAuthorizationDidFail:(TwitterXAuth *)twitterXAuth {
    [self hideloadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"We could not log you into twitter. Please try again.", nil) 
                                                    message:nil 
                                                   delegate:nil 
                                          cancelButtonTitle:nil 
                                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alert show];
    [alert release];
}

- (void) twitterXAuthDidAuthorize:(TwitterXAuth *)twitterXAuth {
    [self hideloadingView];    
    [UIApplication setTwitterToken:twitterXAuth.token];
    [UIApplication setTwitterTokenSecret:twitterXAuth.tokenSecret];
    
    [self switchToPost];
}

- (void) twitterXAuthTweetDidFail:(TwitterXAuth *)twitterXAuth {
    [self hideloadingView];    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"We could not post your tweet. Please try again.", nil) 
                                                    message:nil 
                                                   delegate:nil 
                                          cancelButtonTitle:nil 
                                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alert show];
    [alert release];
}

- (void) twitterXAuthDidTweet:(TwitterXAuth *)twitterXAuth {
    [self hideloadingView];  
    
//    [_remainingCharactersLabel setText:@"140"];
//      [_remainingCharactersLabel setText:[NSString stringWithFormat:@"%d", 140 - [_twitterPostField.text length]]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Your tweet was posted.", nil) 
                                                    message:nil 
                                                   delegate:nil 
                                          cancelButtonTitle:nil 
                                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alert show];
    [alert release];
}

#pragma mark - LoadingView methods

- (void)showLoadingView {
    [UIView beginAnimations:@"showLoading" context:NULL];
    [UIView setAnimationDuration:0.5];
    
    [_loadingView setAlpha:1.0];
    
    [UIView commitAnimations];
}

- (void)hideloadingView {
    [UIView beginAnimations:@"hideLoading" context:NULL];
    [UIView setAnimationDuration:0.5];
    
    [_loadingView setAlpha:0.0];
    
    [UIView commitAnimations];
}

- (void)goBackToShare:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
