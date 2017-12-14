//
//  UIButton-Additions.m
//  vevoke
//
//  Created by Andrei Vig on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIButton-Additions.h"


@implementation UIButton (UIButton_Additions)

//+ (UIButton *)tabBarButtonWithTitle:(NSString *)title {
//	
//	UIImage *tabImageActive = [UIImage imageNamed:@"tab_button_act.png"];
//	UIImage *backgroundActive = [tabImageActive stretchableImageWithLeftCapWidth:30.0 topCapHeight:15.0];
//	
//	UIImage *tabImageInactive = [UIImage imageNamed:@"tab_button_inact.png"];
//	UIImage *backgroundInactive = [tabImageInactive stretchableImageWithLeftCapWidth:30.0 topCapHeight:15.0];
//	
//	UIButton *tabButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 30.0)];
//	[tabButton setBackgroundImage:backgroundInactive forState:UIControlStateNormal];
//	[tabButton setBackgroundImage:backgroundActive forState:UIControlStateHighlighted];
//	
//	[tabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//	[tabButton setTitleColor:[UIColor vevDarkColor] forState:UIControlStateHighlighted];
//	
//	[[tabButton titleLabel] setFont:[UIFont boldSystemFontOfSize:10.0]];
//	[[tabButton titleLabel] setTextColor:[UIColor vevDarkColor]];
//	[[tabButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
//	[tabButton setTitle:title forState:UIControlStateNormal];
//	
//	[tabButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth];
//	
//	return [tabButton autorelease];
//}
//
//- (void)activatTab {
//	UIImage *tabImageActive = [UIImage imageNamed:@"tab_button_act.png"];
//	UIImage *backgroundActive = [tabImageActive stretchableImageWithLeftCapWidth:30.0 topCapHeight:15.0];
//	
//	[self setBackgroundImage:backgroundActive forState:UIControlStateNormal];
//	[self setBackgroundImage:backgroundActive forState:UIControlStateHighlighted];
//	
//	[self setTitleColor:[UIColor vevDarkColor] forState:UIControlStateNormal];
//	[self setTitleColor:[UIColor vevDarkColor] forState:UIControlStateHighlighted];
//}
//
//- (void)deactivateTab {
//	UIImage *tabImageActive = [UIImage imageNamed:@"tab_button_act.png"];
//	UIImage *backgroundActive = [tabImageActive stretchableImageWithLeftCapWidth:30.0 topCapHeight:15.0];
//	
//	UIImage *tabImageInactive = [UIImage imageNamed:@"tab_button_inact.png"];
//	UIImage *backgroundInactive = [tabImageInactive stretchableImageWithLeftCapWidth:30.0 topCapHeight:15.0];
//	
//	[self setBackgroundImage:backgroundInactive forState:UIControlStateNormal];
//	[self setBackgroundImage:backgroundActive forState:UIControlStateHighlighted];
//	
//	[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//	[self setTitleColor:[UIColor vevDarkColor] forState:UIControlStateHighlighted];
//}


@end
