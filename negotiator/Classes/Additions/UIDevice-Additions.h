//
//  UIDevice-Additions.h
//  CoffeMinute
//
//  Created by Andrei Vig on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIDevice (UIDevice_Additions)

- (NSString *)uniqueDeviceIdentifier;
- (NSString *) uniqueGlobalDeviceIdentifier;

@end
