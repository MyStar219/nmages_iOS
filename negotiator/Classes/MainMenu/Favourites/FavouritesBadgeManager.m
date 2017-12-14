//
//  FavouritesBadgeManager.m
//  negotiator
//
//  Created by Alexandru Chis on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavouritesBadgeManager.h"

static FavouritesBadgeManager *kFavouritesBadgeManager = nil;

static NSString      *kBadgeKey    = @"BadgeKey";

@implementation FavouritesBadgeManager

@synthesize badgeNumber = _badgeNumber;

- (id)init {
    
    self = [super init];
    if(!self) return nil;
    
    [self initializeApplication];
    
    return self;
}

+ (FavouritesBadgeManager *)sharedInstance {
    if(!kFavouritesBadgeManager) {
        kFavouritesBadgeManager = [[FavouritesBadgeManager alloc] init];
    }
    return kFavouritesBadgeManager;
}

- (void)dealloc {
    
    self.badgeNumber = nil;
    
    [super dealloc];    
}

- (void)initializeApplication {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *badgeInfo     = [userDefaults objectForKey:kBadgeKey];
    
    if (badgeInfo) {
        self.badgeNumber       = [badgeInfo objectForKey:@"badge"];
    } else {
        self.badgeNumber       = [NSNumber numberWithInt:0];
    }
}

- (void)saveBadgeNumber {
    NSMutableDictionary *badgeInfo = [NSMutableDictionary dictionary];
    
    [badgeInfo setObject:self.badgeNumber forKey:@"badge"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSDictionary dictionaryWithDictionary:badgeInfo ] forKey:kBadgeKey];
    [userDefaults synchronize];
}


@end
