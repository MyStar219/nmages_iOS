//
//  UIColor-Additions.m
//  vevoke
//
//  Created by Andrei Vig on 11/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIColor-Additions.h"


@implementation UIColor (UIColor_Additions)

+ (UIColor *)backgroundColor {
	return [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]];
}

+ (UIColor *)blackNavColor {
	return [UIColor blackColor];
}

+ (UIColor *)tealGreenColor {
	return [UIColor colorWithRed:0.0 green:0.5 blue:0.5 alpha:1.0];
}

+ (UIColor *)lightAppColor {
    return [UIColor colorWithRed:0.900 green:0.898 blue:0.898 alpha:1.0];
}

+ (UIColor *)navAppColor {
    //return [UIColor colorWithRed:0.216 green:0.365 blue:0.573 alpha:1.0];
    return [UIColor colorWithRed:0.0 green:0.525 blue:0.502 alpha:1.0];    
}

+ (UIColor *)redNavColor {
    return [UIColor colorWithRed:0.769 green:0.059 blue:0.078 alpha:1.0];    
}


@end

