//
//  FavouritesBadgeManager.h
//  negotiator
//
//  Created by Alexandru Chis on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavouritesBadgeManager : NSObject {
    NSNumber   *_badgeNumber;
}

@property(nonatomic, assign) NSNumber *badgeNumber;

+ (FavouritesBadgeManager *)sharedInstance;

- (void)initializeApplication;
- (void)saveBadgeNumber;

@end
