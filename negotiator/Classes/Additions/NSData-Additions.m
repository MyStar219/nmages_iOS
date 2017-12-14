//
//  NSData-Additions.m
//  vevoke
//
//  Created by Andrei Vig on 11/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSData-Additions.h"


@implementation NSData (NSData_Additions)

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString *)newStringInBase64FromData {
	NSMutableString *dest = [[NSMutableString alloc] initWithString:@""];
	unsigned char * working = (unsigned char *)[self bytes];
	int srcLen = [self length];
	
	// tackle the source in 3's as conveniently 4 Base64 nibbles fit into 3 bytes
	for (int i=0; i<srcLen; i += 3)
	{
		// for each output nibble
		for (int nib=0; nib<4; nib++)
		{
			// nibble:nib from char:byt
			int byt = (nib == 0)?0:nib-1;
			int ix = (nib+1)*2;
			
			if (i+byt >= srcLen) break;
			
			// extract the top bits of the nibble, if valid
			unsigned char curr = ((working[i+byt] << (8-ix)) & 0x3F);
			
			// extract the bottom bits of the nibble, if valid
			if (i+nib < srcLen) curr |= ((working[i+nib] >> ix) & 0x3F);
			
			[dest appendFormat:@"%c", base64[curr]];
		}
	}
	
	return dest;
}



@end
