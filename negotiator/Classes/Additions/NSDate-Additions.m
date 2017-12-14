//
//  NSDate-Additions.m
//  vevoke
//
//  Created by Andrei Vig on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDate-Additions.h"


@implementation NSDate (NSDate_Additions)

+ (NSDate *)UTCDate {
	NSDate *currentGMTDate = [NSDate date];
	
	return currentGMTDate;
}

@end
