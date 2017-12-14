//
//  LoadingView.m
//  vevoke
//
//  Created by Andrei Vig on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoadingView.h"

#import <QuartzCore/QuartzCore.h>

@implementation LoadingView


- (id)initWithFrame:(CGRect)frame 
			message:(NSString *)message 
		messageFont:(UIFont *)font
			  style:(LoadingViewStyle)style
	 roundedCorners:(BOOL)roundedCorners
{
	self = [super initWithFrame:frame];
	if (!self) return nil;
	
	_style = style;
	
	if (_style == LoadingViewWhite) {
		[self setBackgroundColor:[UIColor whiteColor]];
	} else {
		[self setBackgroundColor:[UIColor darkGrayColor]];
		[self setAlpha:1.0];
	}
	
	[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	
	/* create activity indicator */
	UIActivityIndicatorViewStyle activityIndicatorStyle;
	
	if (_style == LoadingViewWhite) {
		activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
	} else {
		activityIndicatorStyle = UIActivityIndicatorViewStyleWhite;
	}
	
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityIndicatorStyle];
	[activityIndicator startAnimating];
	[activityIndicator setBackgroundColor:[UIColor clearColor]];

	/* calculate loading view content size */
	CGSize messageSize = [message sizeWithFont:font 
									  forWidth:CGRectGetWidth(frame) - CGRectGetWidth(activityIndicator.frame)
								 lineBreakMode:UILineBreakModeTailTruncation];
	
	CGRect loadingContentFrame = CGRectMake(0.0,
											0.0, 
											CGRectGetWidth(activityIndicator.frame) + messageSize.width + 15.0, 
											30.0);
	
	
	_loadingView = [[UIView alloc] initWithFrame:loadingContentFrame];
	[_loadingView setBackgroundColor:[UIColor clearColor]];
	if (roundedCorners) {
		[_loadingView.layer setCornerRadius:20.0];
		[self.layer setCornerRadius:20.0];
	}
	
	[activityIndicator setFrame:CGRectMake(5.0, 
										   (CGRectGetHeight(_loadingView.frame) - CGRectGetHeight(activityIndicator.frame)) / 2, 
										   CGRectGetWidth(activityIndicator.frame), 
										   CGRectGetHeight(activityIndicator.frame))];
	[_loadingView addSubview:activityIndicator];
	[activityIndicator release];

	CGRect loadingMessageFrame = CGRectMake(10.0 + CGRectGetWidth(activityIndicator.frame), 
											(CGRectGetHeight(_loadingView.frame) - 30) / 2, 
											messageSize.width, 
											30.0);
	
	UILabel *loadingLabel = [[UILabel alloc] initWithFrame:loadingMessageFrame];
	[loadingLabel setBackgroundColor:[UIColor clearColor]];
	[loadingLabel setText:message];
	[loadingLabel setFont:font];
	
	if (_style == LoadingViewWhite) {
		[loadingLabel setTextColor:[UIColor lightGrayColor]];
	} else {
		[loadingLabel setTextColor:[UIColor whiteColor]];
	}
	[loadingLabel setTextAlignment:UITextAlignmentLeft];
	[_loadingView addSubview:loadingLabel];
	[loadingLabel release];
	
	
	[self addSubview:_loadingView];
	[_loadingView release];
	
    return self;
}

- (void)dealloc {
	[super dealloc];
}	 

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[_loadingView setCenter:CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0)];
	
}
	 
- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
}

- (void)show {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    
    [self setAlpha:1.0];
    
    [UIView commitAnimations];
}

- (void)hide {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    
    [self setAlpha:0.0];
    
    [UIView commitAnimations];
}


@end
