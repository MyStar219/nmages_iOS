//
//  InfoController.h
//  negotiator
//
//  Created by Vig Andrei on 1/17/12.
//  Copyright (c) 2012 Dot IT Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "TabBarController.h"

@interface InfoController : UIViewController <MFMailComposeViewControllerDelegate,UINavigationControllerDelegate> {

    IBOutlet UIButton       *_aboutNegotiatorBtn;    
    IBOutlet UIButton       *_facebookBtn;
    IBOutlet UIButton       *_twitterBtn;
    IBOutlet UIButton       *_websiteBtn;
    IBOutlet UIButton       *_feedbackBtn;
    IBOutlet UIButton       *_advertisingBtn;
//    IBOutlet UIButton       *_termsBtn;
}

- (IBAction)goToAboutNegotiator:(id)sender;
- (IBAction)goToFacebook:(id)sender;
- (IBAction)goToTwitter:(id)sender;
- (IBAction)goToWebsite:(id)sender;
- (IBAction)goToFeedback:(id)sender;
- (IBAction)goToAdvertising:(id)sender;
//- (IBAction)goToTerms:(id)sender;

//- (UIView *)titleView;

@end
