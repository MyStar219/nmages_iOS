//
//  UIView+Additions.h
//  ClaimDirector
//
//  Created by Anton Selivonchyk on 6/21/12.
//  Copyright (c) 2012 AdeptiSoft LLC. All rights reserved.
//

@interface UIView (Additions)

@property (nonatomic, readwrite) CGFloat x;
@property (nonatomic, readwrite) CGFloat y;
@property (nonatomic, readwrite) CGSize size;
@property (nonatomic, readwrite) CGPoint origin;
@property (nonatomic, readwrite) CGFloat width;
@property (nonatomic, readwrite) CGFloat height;

- (UIViewController*)viewController;

@end
