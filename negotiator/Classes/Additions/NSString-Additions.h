//
//  NSString-Additions.h
//  vevoke
//
//  Created by Andrei Vig on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NSString_Additions)

+ (BOOL)isNilOrEmpty:(NSString *)string;
+ (BOOL) validateEmail: (NSString *)candidate;
+ (NSString *)MD5Hash:(NSString *)string;
+ (NSString *)periodDescriptionForInterval:(NSTimeInterval)interval;
+ (NSString *)flattenHTML:(NSString *)html;
- (NSString *)stringByConvertingHTMLToPlainText;
- (NSString *)stringByDecodingHTMLEntities;
- (NSString *)stringByEncodingHTMLEntities;
- (NSString *)stringWithNewLinesAsBRs;
- (NSString *)stringByRemovingNewLinesAndWhitespace;
- (NSString *)stringByLinkifyingURLs;
- (NSString *)stringByStrippingTags;
- (NSComparisonResult)compareAsNumbers:(NSString *)otherString;

//custom method for removing < >, <p> html tags 
- (NSString *)removeHTMLTags;

-(NSString *) stringByStrippingHTML:(NSString *)htmlStr;

@end
