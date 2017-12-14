//
//  LoadingView.h
//  vevoke
//
//  Created by Andrei Vig on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum LoadingViewStyle {
	LoadingViewWhite = 0,
    LoadingViewBlack = 1,
	LoadingViewTranslucent
} LoadingViewStyle;

@class LoadingAnimationView;

@interface LoadingView : UIView {
	UIView *_loadingView;
	LoadingViewStyle _style;
}

- (id)initWithFrame:(CGRect)frame 
			message:(NSString *)message 
		messageFont:(UIFont *)font
			  style:(LoadingViewStyle)style
	 roundedCorners:(BOOL)roundedCorners;
		
- (void)show;
- (void)hide;

@end
