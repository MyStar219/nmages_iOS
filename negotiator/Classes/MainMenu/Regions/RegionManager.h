//
//  RegionManager.h
//  negotiator
//
//  Created by Alexandru Chis on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegionObject.h"

static NSString      *kRegionInfoKey        = @"RegionInfoKey";
static NSString      *kRegionIdKey          = @"RegionIdKey";
static NSString      *kRegionNameKey        = @"RegionNameKey";
static NSString      *kRegionImageKey       = @"RegionImageKey";
static NSString      *kRegionImageLinkKey   = @"RegionImageLinkKey";

@interface RegionManager : NSObject {
    
    RegionObject *_region;
}

@property (nonatomic, strong) RegionObject *region;
    

+ (RegionManager *)sharedInstance;

- (void)initializeApplication;
- (void)setNewRegion:(RegionObject *)region;
- (void)saveRegionInfo;

- (NSURL *)regionImageURL;

@end
