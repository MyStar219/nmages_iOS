//
//  RegionManager.m
//  negotiator
//
//  Created by Alexandru Chis on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegionManager.h"

static RegionManager *kRegionManager = nil;



@implementation RegionManager

@synthesize region          = _region;

- (id)init {
    
    self = [super init];
    if(!self) return nil;
    
    [self initializeApplication];
    
    return self;
}

+ (RegionManager *)sharedInstance {
    if(!kRegionManager) {
        kRegionManager = [[RegionManager alloc] init];
    }
    return kRegionManager;
}

- (void)dealloc {
    
    [_region release];
    
    [super dealloc];    
}

- (void)initializeApplication {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *regionInfo     = [userDefaults objectForKey:kRegionInfoKey];
    
    self.region = [[RegionObject alloc] init];
    
    if (regionInfo) {
        
        self.region.regionId        = [regionInfo objectForKey:kRegionIdKey];
        self.region.regionName      = [regionInfo objectForKey:kRegionNameKey];
        self.region.regionImagePath = [regionInfo objectForKey:kRegionImageKey];
        self.region.regionImageLink = [regionInfo objectForKey:kRegionImageLinkKey];
    }
}

- (void)setNewRegion:(RegionObject *)region {
    
    self.region = region;
    
    [self saveRegionInfo];
}

- (void)saveRegionInfo {
    
    NSMutableDictionary *regionInfo = [NSMutableDictionary dictionary];
    
    if (![NSString isNilOrEmpty:self.region.regionId]) {
        [regionInfo setObject:self.region.regionId forKey:kRegionIdKey];
    } 
    if (![NSString isNilOrEmpty:self.region.regionName]) {
        [regionInfo setObject:self.region.regionName forKey:kRegionNameKey];
    }
    if (![NSString isNilOrEmpty:self.region.regionImagePath]) {
        [regionInfo setObject:self.region.regionImagePath forKey:kRegionImageKey];
    }
    if (![NSString isNilOrEmpty:self.region.regionImageLink]) {
        [regionInfo setObject:self.region.regionImageLink forKey:kRegionImageLinkKey];
    }
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSDictionary dictionaryWithDictionary:regionInfo ] forKey:kRegionInfoKey];
    [userDefaults synchronize];
}

- (NSURL *)regionImageURL {
    
    return [self.region regionImageURL];
}

@end
