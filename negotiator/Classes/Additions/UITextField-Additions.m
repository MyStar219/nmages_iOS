//
//  UITextField-Additions.m
//  PointZone
//
//  Created by Andrei Vig on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UITextField-Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UITextField (UITextField_Additions)

+ (UITextField *)createTextFieldWithLeftViewName:(NSString *)name frame:(CGRect)frame delegate:(id <UITextFieldDelegate>)delegate; {
	UITextField *loginTextField = [[UITextField alloc] initWithFrame:frame];
	[loginTextField setDelegate:delegate];
    [loginTextField setFont:[UIFont systemFontOfSize:13.0]];
    [loginTextField setTextAlignment:UITextAlignmentLeft];
	[loginTextField.layer setCornerRadius:7.0];
	[loginTextField setBackgroundColor:[UIColor clearColor]];
	[loginTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[loginTextField setLeftViewMode:UITextFieldViewModeAlways];
    [loginTextField setRightViewMode:UITextFieldViewModeAlways];
	
	UILabel *leftViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 28.0)];
	[leftViewLabel setTextAlignment:UITextAlignmentLeft];
	[leftViewLabel setBackgroundColor:[UIColor clearColor]];
	[leftViewLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
	[leftViewLabel setTextColor:[UIColor blackColor]];
	[leftViewLabel setText:name];
	[loginTextField setLeftView:leftViewLabel];
	[leftViewLabel release];
	
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 28.0)];
    [loginTextField setRightView:rightView];
    [rightView release];
    
	return loginTextField;
}

@end
