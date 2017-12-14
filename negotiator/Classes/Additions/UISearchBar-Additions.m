//
//  UISearchBar-Additions.m
//  PocketMate
//
//  Created by Andrei Vig on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UISearchBar-Additions.h"


@implementation UISearchBar (UISearchBar_Additions)

- (void)drawRect:(CGRect)rect {
	UIImage *image = [UIImage imageNamed: @"search_background.png"];
	[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
