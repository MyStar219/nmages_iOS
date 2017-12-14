//
//  RegionObject.m
//  negotiator
//
//  Created by aplome on 24/07/2017.
//
//

#import "RegionObject.h"

@implementation RegionObject

@synthesize regionId            = _regionId;
@synthesize regionName          = _regionName;
@synthesize regionImagePath     = _regionImagePath;
@synthesize regionImageLink     = _regionImageLink;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self initialize];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        
        self.regionId           = [NSString isNilOrEmpty:[dict objectForKey:@"id"]]? @"" :[dict objectForKey:@"id"];
        self.regionName         = [NSString isNilOrEmpty:[dict objectForKey:@"name"]]? @"" :[dict objectForKey:@"name"];
        self.regionImagePath    = [NSString isNilOrEmpty:[dict objectForKey:@"image"]]? @"" : [dict objectForKey:@"image"];
        self.regionImageLink    = [NSString isNilOrEmpty:[dict objectForKey:@"imageURL"]]? @"" : [dict objectForKey:@"imageURL"];
    }
    return self;
}

- (void)initialize {
    
    self.regionId        = @"";
    self.regionName      = @"";
    self.regionImagePath = @"";
    self.regionImageLink = @"";
}

- (NSURL *)regionImageURL {
    return [NSURL URLWithString:self.regionImagePath];
}


@end
