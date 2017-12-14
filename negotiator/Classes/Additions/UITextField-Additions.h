//
//  UITextField-Additions.h
//  PointZone
//
//  Created by Andrei Vig on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UITextField (UITextField_Additions)

+ (UITextField *)createTextFieldWithLeftViewName:(NSString *)name frame:(CGRect)frame delegate:(id <UITextFieldDelegate>)delegate;

@end
