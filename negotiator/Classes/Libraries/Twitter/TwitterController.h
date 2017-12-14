//
//  TwitterController.h
//  SmartSaver
//
//  Created by Andrei Vig on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterXAuth.h"
#import "LoadingView.h"

@interface TwitterController : MainController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, TwitterXAuthDelegate> {
    
    UITableView *_tableView;
    
    UITextField *_usernameTextField;
    UITextField *_passwordTextField;
    
    UIView *_loginView;
    UIView *_postView;
    
    UITextView *_twitterPostField;
    UILabel *_remainingCharactersLabel;
    
    TwitterXAuth *_twitterXAuth;
    LoadingView *_loadingView;
    
    UIBarButtonItem *_couponBarBtn;
}

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, retain) UITextField *usernameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;

@property (nonatomic, retain) UIView *loginView;
@property (nonatomic, retain) UIView *postView;

@property (nonatomic, retain) UITextView *twitterPostField;
@property (nonatomic, retain) UILabel *remainingCharactersLabel;


@property (nonatomic, retain) TwitterXAuth *twitterXAuth;

- (void)switchToLogin;
- (void)switchToPost;

- (void)showLoadingView;
- (void)hideloadingView;

- (void)goBackToShare:(id)sender;

- (void)postTweet;
//- (UIView *)titleView;

@end
