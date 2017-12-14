//
//  UIApplication-Additions.m
//  vevoke
//
//  Created by Andrei Vig on 11/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIApplication-Additions.h"
#import "AppDelegate.h"


static NSString *kFirstStartupKey = @"firstStartupKey";

@implementation UIApplication (UIApplication_Additions)

+ (UIWindow *)mainWindow {

    return [[[UIApplication sharedApplication] delegate] window];
}

+ (AppDelegate*)appDelegate
{
	return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

+ (NSString *)documentsPath {
	// get all the directories
	NSArray *directoriesList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	// get documents directory
	NSString* documentsDirectory = [directoriesList lastObject];
	
	// create documents path
	NSString *documentsPath = [[[NSString alloc] initWithFormat:@"%@/", documentsDirectory] autorelease];
	return documentsPath;
}

#pragma mark --- First Startup

+ (BOOL)isNotFirstStartup {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kFirstStartupKey];
}

+ (void)setFirstStartupOccured {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstStartupKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)supportsRetinaDisplay {
    BOOL hasRetina = NO;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0) {
        hasRetina = YES;
    }
    
    return hasRetina;
}

#pragma mark - Facebook
+ (NSString *)facebookAppID {
	return @"245793075504903";
}

#pragma mark - Twitter
+ (BOOL)loggedInToTwitter {
    NSString *twitterToken = [UIApplication twitterToken];
    NSString *twitterTokenSecret = [UIApplication twitterTokenSecret];
    
    if (![NSString isNilOrEmpty:twitterToken] && ![NSString isNilOrEmpty:twitterTokenSecret]) {
        return YES;
    }
    
    return NO;
}

//Request token URL	https://api.twitter.com/oauth/request_token
//Authorize URL	https://api.twitter.com/oauth/authorize
//Access token URL	https://api.twitter.com/oauth/access_token

+ (NSString *)twitterToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"twitterToken"];
}

+ (void)setTwitterToken:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"twitterToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)twitterTokenSecret {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"twitterTokenSecret"];    
}

+ (void)setTwitterTokenSecret:(NSString *)tokenSecret {    
    [[NSUserDefaults standardUserDefaults] setObject:tokenSecret forKey:@"twitterTokenSecret"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
