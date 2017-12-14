//
//  NSArray-Additions.m
//  vevoke
//
//  Created by Andrei Vig on 11/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSArray-Additions.h"


@implementation NSArray (NSArray_Additions)

- (NSArray *)reversedArray {

	NSMutableArray *reversedArray = [NSMutableArray arrayWithCapacity:[self count]];
	NSEnumerator *enumerator = [self reverseObjectEnumerator];
	
	for (id element in enumerator) {
		[reversedArray addObject:element];
	}
	
	return reversedArray;
}

@end
