//
//  MainController.m
//  pocketmate
//
//  Created by Andrei Vig on 10/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainController.h"


@implementation MainController

- (id)init {
    self = [super init];
    
    if (!self) return nil;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitleView:[self logoView]];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (UIView *)logoView
{
    UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navLogo"]];
    titleView.contentMode = UIViewContentModeScaleAspectFit;
    [titleView setFrame:CGRectMake(0.0, 0.0, 159.0, 39.0)];
    return [titleView autorelease];
}

@end
