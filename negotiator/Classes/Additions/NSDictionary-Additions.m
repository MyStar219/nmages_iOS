//
//  NSDictionary-Additions.m
//  negotiator
//
//  Created by aplome on 19/07/2017.
//
//

#import "NSDictionary-Additions.h"

@implementation NSDictionary (NSDictionary_Additions)

- (BOOL)containsKey: (NSString *)key {
    BOOL retVal = 0;
    NSArray *allKeys = [self allKeys];
    retVal = [allKeys containsObject:key];
    return retVal;
}

@end
