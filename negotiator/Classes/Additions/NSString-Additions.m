//
//  NSString-Additions.m
//  vevoke
//
//  Created by Andrei Vig on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString-Additions.h"
#import "GTMNSString+HTML.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (NSString_Additions)

+ (BOOL)isNilOrEmpty:(NSString *)string {
	
	BOOL isNilOrEmpty = NO;
	
	if ((nil == string) || ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])) {
		isNilOrEmpty = YES;
	}
	
	return isNilOrEmpty;
	
}

+ (BOOL) validateEmail: (NSString *)candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    return [emailTest evaluateWithObject:candidate];
}

+ (NSString *)MD5Hash:(NSString *)string {
	
    const char *concat_str = [string UTF8String];
	
    unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(concat_str, strlen(concat_str), result);
	NSMutableString *hash = [NSMutableString string];
    
	for (int i = 0; i < 16; i++) {
        [hash appendFormat:@"%02X", result[i]];
	}
	
    return [hash lowercaseString];	
}

+ (NSString *)periodDescriptionForInterval:(NSTimeInterval)interval {
	NSTimeInterval difference = [[NSDate date] timeIntervalSince1970] - interval;	
	NSString *description = nil;
	
	if (difference <= 60) {
		description = NSLocalizedString(@"just now", nil);
	} else if (difference <= 119) {
		description = NSLocalizedString(@"about a minute ago", nil);
	} else if (difference < 60 * 60) {
		description = [NSString stringWithFormat:NSLocalizedString(@"%d minutes ago", nil), (int)floor(difference / 60.0)];
	} else if (difference < 60 * 60 * 24) {
		int numberOfMinutes = floor(difference / 60.0);
		int numberOfHours = numberOfMinutes / 60;
		int remainingMinutes = numberOfMinutes % 60;
		
		NSString *hoursFormat = nil;
		if (numberOfHours == 1) {
			hoursFormat = NSLocalizedString(@"1 hour", nil);
		} else {
			hoursFormat = [NSString stringWithFormat:NSLocalizedString(@"%d hours", nil), numberOfHours];
		}
		
		NSString *minutesFormat = nil;
		if (remainingMinutes == 0) {
			minutesFormat = @"";
		} else if (remainingMinutes == 1) {
			minutesFormat = @"and 1 minute";
		} else {
			minutesFormat = [NSString stringWithFormat:NSLocalizedString(@"and %d minutes", nil), remainingMinutes];
		}
		
		description = [NSString stringWithFormat:@"%@ %@ ago", hoursFormat, minutesFormat];
	} else {
		description = NSLocalizedString(@"More than one day ago", nil);
	}
	
	return description;
}

+ (NSString *)flattenHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
        
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [ NSString stringWithFormat:@"%@>", text]
                                               withString:@" "];
        
    }
    
    return html;
    
}

- (NSComparisonResult)compareAsNumber:(NSString *)aString {
    
    NSNumber *selfAsNumber = [NSNumber numberWithInt:[self intValue]];
    NSNumber *otherAsNumber = [NSNumber numberWithInt:[aString intValue]];
    return [selfAsNumber compare:otherAsNumber];
}

// Strip HTML tags
- (NSString *)stringByConvertingHTMLToPlainText {
    
    // Pool
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Character sets
    NSCharacterSet *stopCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"< \t\n\r%d%d%d%d", 0x0085, 0x000C, 0x2028, 0x2029]];
    NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r%d%d%d%d", 0x0085, 0x000C, 0x2028, 0x2029]];
    NSCharacterSet *tagNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]; /**/
    
    // Scan and find all tags
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:self.length];
    NSScanner *scanner = [[NSScanner alloc] initWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    [scanner setCaseSensitive:YES];
    NSString *str = nil, *tagName = nil;
    BOOL dontReplaceTagWithSpace = NO;
    do {
        
        // Scan up to the start of a tag or whitespace
        if ([scanner scanUpToCharactersFromSet:stopCharacters intoString:&str]) {
            [result appendString:str];
            str = nil; // reset
        }
        
        // Check if we've stopped at a tag/comment or whitespace
        if ([scanner scanString:@"<" intoString:NULL]) {
            
            // Stopped at a comment or tag
            if ([scanner scanString:@"!--" intoString:NULL]) {
                
                // Comment
                [scanner scanUpToString:@"-->" intoString:NULL];
                [scanner scanString:@"-->" intoString:NULL];
                
            } else {
                
                // Tag - remove and replace with space unless it's
                // a closing inline tag then dont replace with a space
                if ([scanner scanString:@"/" intoString:NULL]) {
                    
                    // Closing tag - replace with space unless it's inline
                    tagName = nil; dontReplaceTagWithSpace = NO;
                    if ([scanner scanCharactersFromSet:tagNameCharacters intoString:&tagName]) {
                        tagName = [tagName lowercaseString];
                        dontReplaceTagWithSpace = ([tagName isEqualToString:@"a"] ||
                                                   [tagName isEqualToString:@"b"] ||
                                                   [tagName isEqualToString:@"i"] ||
                                                   [tagName isEqualToString:@"q"] ||
                                                   [tagName isEqualToString:@"span"] ||
                                                   [tagName isEqualToString:@"em"] ||
                                                   [tagName isEqualToString:@"strong"] ||
                                                   [tagName isEqualToString:@"cite"] ||
                                                   [tagName isEqualToString:@"abbr"] ||
                                                   [tagName isEqualToString:@"acronym"] ||
                                                   [tagName isEqualToString:@"label"]);
                    }
                    
                    // Replace tag with string unless it was an inline
                    if (!dontReplaceTagWithSpace && result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "];
                    
                }
                
                // Scan past tag
                [scanner scanUpToString:@">" intoString:NULL];
                [scanner scanString:@">" intoString:NULL];
                
            }
            
        } else {
            
            // Stopped at whitespace - replace all whitespace and newlines with a space
            if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
                if (result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "]; // Dont append space to beginning or end of result
            }
            
        }
        
    } while (![scanner isAtEnd]);
    
    // Cleanup
    [scanner release];
    
    // Decode HTML entities and return
    NSString *retString = [[result stringByDecodingHTMLEntities] retain];
    [result release];
    
    // Drain
    [pool drain];
    
    // Return
    return [retString autorelease];
    
}

// Decode all HTML entities using GTM
- (NSString *)stringByDecodingHTMLEntities {
    // gtm_stringByUnescapingFromHTML can return self so create new string ;)
    return [NSString stringWithString:[self gtm_stringByUnescapingFromHTML]];
}

// Encode all HTML entities using GTM
- (NSString *)stringByEncodingHTMLEntities {
    // gtm_stringByUnescapingFromHTML can return self so create new string ;)
    return [NSString stringWithString:[self gtm_stringByEscapingForAsciiHTML]];
}

// Replace newlines with <br /> tags
- (NSString *)stringWithNewLinesAsBRs {
    
    // Pool
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Strange New lines:
    // Next Line, U+0085
    // Form Feed, U+000C
    // Line Separator, U+2028
    // Paragraph Separator, U+2029
    
    // Scanner
    NSScanner *scanner = [[NSScanner alloc] initWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    NSMutableString *result = [[NSMutableString alloc] init];
    NSString *temp;
    NSCharacterSet *newLineCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                         [NSString stringWithFormat:@"\n\r%d%d%d%d", 0x0085, 0x000C, 0x2028, 0x2029]];
    // Scan
    do {
        
        // Get non new line characters
        temp = nil;
        [scanner scanUpToCharactersFromSet:newLineCharacters intoString:&temp];
        if (temp) [result appendString:temp];
        temp = nil;
        
        // Add <br /> s
        if ([scanner scanString:@"\r\n" intoString:nil]) {
            
            // Combine \r\n into just 1 <br />
            [result appendString:@"<br />"];
            
        } else if ([scanner scanCharactersFromSet:newLineCharacters intoString:&temp]) {
            
            // Scan other new line characters and add <br /> s
            if (temp) {
                for (int i = 0; i < temp.length; i++) {
                    [result appendString:@"<br />"];
                }
            }
            
        }
        
    } while (![scanner isAtEnd]);
    
    // Cleanup & return
    [scanner release];
    NSString *retString = [[NSString stringWithString:result] retain];
    [result release];
    
    // Drain
    [pool drain];
    
    // Return
    return [retString autorelease];
    
}

// Remove newlines and white space from strong
- (NSString *)stringByRemovingNewLinesAndWhitespace {
    
    // Pool
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Strange New lines:
    // Next Line, U+0085
    // Form Feed, U+000C
    // Line Separator, U+2028
    // Paragraph Separator, U+2029
    
    // Scanner
    NSScanner *scanner = [[NSScanner alloc] initWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    NSMutableString *result = [[NSMutableString alloc] init];
    NSString *temp;
    NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:
                                                      [NSString stringWithFormat:@" \t\n\r%d%d%d%d", 0x0085, 0x000C, 0x2028, 0x2029]];
    // Scan
    while (![scanner isAtEnd]) {
        
        // Get non new line or whitespace characters
        temp = nil;
        [scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:&temp];
        if (temp) [result appendString:temp];
        
        // Replace with a space
        if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
            if (result.length > 0 && ![scanner isAtEnd]) // Dont append space to beginning or end of result
                [result appendString:@" "];
        }
        
    }
    
    // Cleanup
    [scanner release];
    
    // Return
    NSString *retString = [[NSString stringWithString:result] retain];
    [result release];
    
    // Drain
    [pool drain];
    
    // Return
    return [retString autorelease];
    
}

// Wrap plain URLs in <a href="..." class="linkified">...</a>
// - Ignores URLs inside tags (any URL beginning with =")
// - HTTP & HTTPS schemes only
// - Only works in iOS 4+ as we use NSRegularExpression (returns self if not supported so be careful with NSMutableStrings)
// - Expression: (?<!=")\b((http|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?)
// - Adapted from http://regexlib.com/REDetails.aspx?regexp_id=96
- (NSString *)stringByLinkifyingURLs {
    if (!NSClassFromString(@"NSRegularExpression")) return self;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *pattern = @"(?<!=\")\\b((http|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%%&amp;:/~\\+#]*[\\w\\-\\@?^=%%&amp;/~\\+#])?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSString *modifiedString = [[regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length])
                                                           withTemplate:@"<a href=\"$1\" class=\"linkified\">$1</a>"] retain];
    [pool drain];
    return [modifiedString autorelease];
}

// Strip HTML tags
// DEPRECIATED - Please use NSString stringByConvertingHTMLToPlainText
- (NSString *)stringByStrippingTags {
    
    // Pool
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Find first & and short-cut if we can
    NSUInteger ampIndex = [self rangeOfString:@"<" options:NSLiteralSearch].location;
    if (ampIndex == NSNotFound) {
        return [NSString stringWithString:self]; // return copy of string as no tags found
    }
    
    // Scan and find all tags
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    NSMutableSet *tags = [[NSMutableSet alloc] init];
    NSString *tag;
    do {
        
        // Scan up to <
        tag = nil;
        [scanner scanUpToString:@"<" intoString:NULL];
        [scanner scanUpToString:@">" intoString:&tag];
        
        // Add to set
        if (tag) {
            NSString *t = [[NSString alloc] initWithFormat:@"%@>", tag];
            [tags addObject:t];
            [t release];
        }
        
    } while (![scanner isAtEnd]);
    
    // Strings
    NSMutableString *result = [[NSMutableString alloc] initWithString:self];
    NSString *finalString;
    
    // Replace tags
    NSString *replacement;
    for (NSString *t in tags) {
        
        // Replace tag with space unless it's an inline element
        replacement = @" ";
        if ([t isEqualToString:@"<a>"] ||
            [t isEqualToString:@"</a>"] ||
            [t isEqualToString:@"<span>"] ||
            [t isEqualToString:@"</span>"] ||
            [t isEqualToString:@"<strong>"] ||
            [t isEqualToString:@"</strong>"] ||
            [t isEqualToString:@"<em>"] ||
            [t isEqualToString:@"</em>"]) {
            replacement = @"";
        }
        
        // Replace
        [result replaceOccurrencesOfString:t
                                withString:replacement
                                   options:NSLiteralSearch
                                     range:NSMakeRange(0, result.length)];
    }
    
    // Remove multi-spaces and line breaks
    finalString = [[result stringByRemovingNewLinesAndWhitespace] retain];
    
    // Cleanup
    [result release];
    [tags release];
    
    // Drain
    [pool drain];
    
    // Return
    return [finalString autorelease];
}

- (NSComparisonResult)compareAsNumbers:(NSString *)otherString {
    NSNumber *selfNumber = [NSNumber numberWithInt:[self intValue]];
    NSNumber *otherNumber = [NSNumber numberWithInt:[otherString intValue]];
    
    return [selfNumber compare:otherNumber];
}

#pragma mark Custom Method for removing < >, <p> html tags 
- (NSString *)removeHTMLTags {
    
    NSRange range;
    
    NSString *stringToFormat = [[self copy] autorelease];
    
    while ((range = [stringToFormat rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
            stringToFormat = [stringToFormat stringByReplacingCharactersInRange:range withString:@""];
    
    return stringToFormat;

}

-(NSString *) stringByStrippingHTML:(NSString *)htmlStr {
   
    NSRange range;
    while ((range = [htmlStr rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        htmlStr = [htmlStr stringByReplacingCharactersInRange:range withString:@""];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    htmlStr=[htmlStr stringByReplacingOccurrencesOfString:@"&amp;" withString:@""];
    NSLog(@"html update is %@",htmlStr);
    return htmlStr;
}

@end
