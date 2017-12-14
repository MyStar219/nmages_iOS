//
//  UIApplication-Additions.h
//  vevoke
//
//  Created by Andrei Vig on 11/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIApplication-Additions.h"

@class AppDelegate;
//@class pocketmateAppDelegate;

@interface UIApplication (UIApplication_Additions)

/* use this method to obtain app delegate */
+ (AppDelegate *)appDelegate;
+ (UIWindow *)mainWindow;

+ (NSString *)documentsPath;

/* first startup */
+ (BOOL)isNotFirstStartup;
+ (void)setFirstStartupOccured;

/* facebook */
+ (NSString *)facebookAppID;

/* twitter */
+ (BOOL)loggedInToTwitter;
+ (NSString *)twitterToken;
+ (NSString *)twitterTokenSecret;

+ (void)setTwitterToken:(NSString *)token;
+ (void)setTwitterTokenSecret:(NSString *)tokenSecret;

/* support of Retina Display*/
+ (BOOL)supportsRetinaDisplay;

@end
