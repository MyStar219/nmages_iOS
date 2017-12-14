//
//  AppDelegate.m
//  negotiator
//
//  Created by Andrei Vig on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "VideoPlayer.h"
#import "UIApplication-Additions.h"
#import "Utility.h"
#import "NetworkHandler.h"
#import "RequestManager.h"
#import "IntroController.h"
#import "MenuController.h"
#import "RegionManager.h"
#import "SelectRegionController.h"
#import "MonitorCouponsEntity+CoreDataClass.h"
#import <MagicalRecord/MagicalRecord.h>
#import <MagicalRecord/MagicalRecord+ShorthandMethods.h>

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

@import Firebase;
@import FirebaseInstanceID;
@import FirebaseMessaging;

// FCM Notification Id's
//  "gcm.message_id"
//  "gcm.n.e"
//  "google.c.a.c_id"
//  "google.c.a.e"
//  "google.c.a.ts"
//  "google.c.a.udt"


// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above. Implement FIRMessagingDelegate to receive data message via FCM for
// devices running iOS 10 and above.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>
@end
#endif

static NSString *const CUSTOM_URL_SCHEME = @"negotiator";

@implementation AppDelegate

@synthesize navController = _navController;
@synthesize window = _window;
@synthesize tgr;

- (void)dealloc
{
    [_window release];
    [_navController release];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        [application setStatusBarStyle:UIStatusBarStyleLightContent];

    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"NegotiatorDB"];
    [MagicalRecord enableShorthandMethods];
    
//    [FIROptions defaultOptions].deepLinkURLScheme = CUSTOM_URL_SCHEME;
    [FIRApp configure];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(regionDetected:) 
                                                 name:@"regionDetected"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showRegionPicker:) 
                                                 name:@"showRegionPicker"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deepLinkingEnabledLocation:)
                                                 name:@"deepLinkingEnabledLocation"
                                               object:nil];
    
    /* start network handler */
    [NetworkHandler sharedInstance];
        
    [self.window setBackgroundColor:[UIColor blackColor]];
    [self.window makeKeyAndVisible];
    
    MenuController *menuController = [[MenuController alloc] initWithNibName:@"MenuController" bundle:[NSBundle mainBundle]];
    _navController = [[UINavigationController alloc] initWithRootViewController:menuController];
    if ([[self.navController navigationBar] respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [[self.navController navigationBar] setBackgroundImage:[UIImage imageNamed:@"infoNavBar_bkgd.png"]
                                                 forBarMetrics:UIBarMetricsDefault];
    }
    [menuController release];
    [self.window setBackgroundColor:[UIColor blackColor]];
    self.window.rootViewController = self.navController;
    
    
    // Create the loading view shown when making the request
    _loadingView = [[LoadingView alloc] initWithFrame:self.window.bounds
                                              message:NSLocalizedString(@"Loading ...", nil)
                                          messageFont:[UIFont boldSystemFontOfSize:13.0]
                                                style:LoadingViewBlack
                                       roundedCorners:NO];
    [_loadingView setAlpha:0.0];
    [self.window addSubview:_loadingView];
    [_loadingView release];
    
    
    [self sendRequestForAllCoupons];
    //location not started if not first time?

    //when start app?
    [self startLocationServices];

    
    //
    NSLog(@"mako ss9");
    
    if ([Utility isFirstStartUp]) {
        [self animateSplasher];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self playVideo:0];

        });
        
 

        
//#if TARGET_OS_SIMULATOR
//
//        //Simulator
//
//#else
//
//        // Device
//        [self playVideo:0];
//#endif
        
    }
    else {
    
        
         [self continueEntrySequence];
    }

    //animatio
 
    return YES;
}

- (void)animateSplasher
{
    NSMutableArray *arraya = [NSMutableArray array];
    for (int i=1; i<=55; i++) {
        NSString *imageName = [NSString stringWithFormat:@"nmags_splash%d",i];
        [arraya addObject:[UIImage imageNamed:imageName]];
    }
    
    UIImageView *animationView = [[UIImageView alloc]initWithFrame:self.window.frame];
    animationView.backgroundColor      = [UIColor clearColor];
    animationView.animationImages      = arraya;
    animationView.animationDuration    = 4;
    animationView.animationRepeatCount = 1;
    [animationView startAnimating];
    
    [self.window addSubview:animationView];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
//    [[FIRMessaging messaging] disconnect];
    NSLog(@"Disconnected from FCM");

    
    if ([[LocationUtiliy sharedInstance] userAccepted]) {
        [[LocationUtiliy sharedInstance] stop];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    if ([[LocationUtiliy sharedInstance] userAccepted]) {
        [[LocationUtiliy sharedInstance] stop];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"%s", __FUNCTION__);
    [self connectToFcm];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *numberOfStarts = [userDefaults objectForKey:@"numberOfStartsKey"];
    
    if (nil == numberOfStarts) {
        numberOfStarts = [NSNumber numberWithInt:1];
    } else {
        numberOfStarts = [NSNumber numberWithInt:[numberOfStarts intValue] + 1];
    }
    
    int numberOfStartsValue = [numberOfStarts intValue];
    
    LOG(@"start number %d", numberOfStartsValue);
    
    if (5 == numberOfStartsValue) {
        UIAlertView *rateAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Help make Negotiator better! ", nil) 
                                                            message:NSLocalizedString(@"If you like Negotiator, take a few seconds to rate the app and leave us a note to let us know what you think!", nil)
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Don't ask again", nil) 
                                                  otherButtonTitles:NSLocalizedString(@"Write a rating", nil), NSLocalizedString(@"Not now", nil), nil];
        [rateAlert show];
        [rateAlert release];
    }
    
    [userDefaults setObject:numberOfStarts forKey:@"numberOfStartsKey"];
    [userDefaults synchronize];
    

    if ([[LocationUtiliy sharedInstance] userAccepted]) {
        [[LocationUtiliy sharedInstance] start];
    }
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    [MagicalRecord cleanUp];
    [self saveContext];
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"sections_persisted"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    if ([[LocationUtiliy sharedInstance] userAccepted]) {
        [[LocationUtiliy sharedInstance] stop];
    }
}

- (void)regionDetected:(NSNotification *)aNotif {
    NSLog(@"%s", __FUNCTION__);
    RegionManager *regionManager = [RegionManager sharedInstance];
    
    NSDictionary *detectedRegion = [aNotif userInfo];    
    
    if (![[[regionManager region] regionId] isEqualToString:[detectedRegion objectForKey:@"id"]]) {

        RegionObject *region = [[RegionObject alloc] initWithDictionary:detectedRegion];
        [regionManager setNewRegion:region];
        
//        [self sendTokenToFCMServer:[Utility getFCMToken]];
//        [self sendRequestForAllCoupons];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"regionAlertShow" object:nil userInfo:detectedRegion];
    }
    
    [self.navController dismissModalViewControllerAnimated:YES];
}

- (void)showRegionPicker:(NSNotification *)aNotif {
    NSLog(@"%s", __FUNCTION__);
    [self.navController dismissModalViewControllerAnimated:YES];
    
    if (NotReachable != [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        NSString *message = NSLocalizedString(@"We were unable to detect your current location. Please select a region.", nil);
        SelectRegionController *regionPicker = [[SelectRegionController alloc] initWithMessage:message forceSelect:YES];
        [self.navController pushViewController:regionPicker animated:NO];
        //[regionPicker release];
    } 
}

#pragma mark UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"%s", __FUNCTION__);
    
    if(alertView.tag == -655)
        return;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *startValue = nil;
    
    if (alertView.cancelButtonIndex == buttonIndex) {
        startValue = [NSNumber numberWithInt:10];
    } else if (2 == buttonIndex) {
        startValue = [NSNumber numberWithInt:0];
    } else if (1 == buttonIndex) {
        startValue = [NSNumber numberWithInt:10];
        
        [userDefaults setObject:startValue forKey:@"numberOfStartsKey"];
        [userDefaults synchronize];
        
        
        NSString *url = [@"http://nmags.com/index.php/api/app/redirect" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *appURL = [NSURL URLWithString:url];
        
        if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
            [[UIApplication sharedApplication] openURL:appURL];
        }  
    }
    
    [userDefaults setObject:startValue forKey:@"numberOfStartsKey"];
    [userDefaults synchronize];
}


#pragma mark PushNotifications methods
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    
     [[FIRInstanceID instanceID] setAPNSToken:newDeviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
    
//    [PFPush storeDeviceToken:newDeviceToken];
//    
    NSString *token = [[newDeviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"Device Token: %@", token);
//
//    
//    
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    [currentInstallation addUniqueObject:@"all" forKey:@"channels"];
//    [currentInstallation setDeviceTokenFromData:newDeviceToken];
//    [currentInstallation saveInBackground];;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	if ([error code] != 3010) {
        // show some alert or otherwise handle the failure to register.
	}
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {

    NSLog(@"%@", notification.userInfo[@"aps"]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    
    NSLog(@"%@", userInfo[@"aps"]);
    
//    [PFPush handlePush:userInfo];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectFavouritesView" 
//                                                        object:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    
    completionHandler(UIBackgroundFetchResultNewData);
}

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // Print message ID.
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    
//    if (userInfo[kGCMMessageIDKey]) {
//        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
//    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionNone);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    
    
//    if (userInfo[kGCMMessageIDKey]) {
//        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
//    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    completionHandler();
}
#endif

#pragma mark FIRMessagingDelegate

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

- (void)messaging:(FIRMessaging *)messaging didRefreshRegistrationToken:(NSString *)fcmToken {

    [self updateRefreshToken:fcmToken];
}

- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {

    [self didReceiveMessage:remoteMessage];
}

// Receive data message on iOS 10 devices while app is in the foreground.
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    // Print full message

    [self didReceiveMessage:remoteMessage];
}
#endif

- (void)didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    
    //    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //
    //    localNotification.alertBody = [remoteMessage.appData valueForKey:@"body"];
    //    localNotification.alertTitle = [remoteMessage.appData valueForKey:@"title"];
    //
    //    localNotification.soundName = [remoteMessage.appData valueForKey:@"sound"];
    //
    //    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    //
    //    [userInfo setValue:[remoteMessage.appData valueForKey:@"icon"] forKey:@"icon"];
    //    [userInfo setValue:[remoteMessage.appData valueForKey:@"from"] forKey:@"from"];
    //
    //    localNotification.userInfo = userInfo;
    //
    //    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    
    //    let notification = UILocalNotification()
    //    notification.alertBody = note(fromRegionIdentifier: region.identifier)
    //    notification.soundName = "Default"
    //    UIApplication.shared.presentLocalNotificationNow(notification)
    
    /*
     body = "Bristol - Largest Wallpaper Range";
     from = 925909054788;
     icon = myicon;
     sound = mySound;
     title = "New Deal Created";
     */
    NSLog(@"%@", remoteMessage.appData);
}

- (void)updateRefreshToken:(NSString *)refreshedToken {

    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
    
    // TODO: If necessary send token to application server.
    
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    if (refreshedToken != nil) {
        
        [Utility setFCMToken:refreshedToken];
        
        [self sendTokenToFCMServer:refreshedToken];
    }
}

// [START refresh_token]
- (void)tokenRefreshNotification:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
    
    NSLog(@"notification: %@", notification.userInfo);
    
    [self updateRefreshToken:[[FIRInstanceID instanceID] token]];
    // cJ4wpaKeT84:APA91bEmQ-zT_n4GUrkQA_q3GId1J6YdyhSNLTaBR3x0UJC0ODS0Fp5_7xjt_j0hl6cYyJ2eNnBlZ72gb5eKfPzVb2VhbnaNIzaWNb9vuROkBRUvIH0tUd_dbCBasCI71CAfReVT8Y3q
}
// [END refresh_token]

// [START connect_to_fcm]
- (void)connectToFcm {
    NSLog(@"%s", __FUNCTION__);
    // Won't connect since there is no token
    if (![[FIRInstanceID instanceID] token]) {
        return;
    }
    
    // Disconnect previous FCM connection if it exists.
    [[FIRMessaging messaging] disconnect];
    
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}
// [END connect_to_fcm]

- (void)sendTokenToFCMServer:(NSString *)token {
    NSLog(@"%s", __FUNCTION__);
    
    /* ASSIHttp request for magazines*/
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    
    [parameters setObject:token forKey:@"tokennumber"];
    
    if (![[[[RegionManager sharedInstance] region] regionId] isEqualToString:@""]) {
    
        [parameters setObject:[[[RegionManager sharedInstance] region] regionName] forKey:@"regions"];
    
        //http://www.nmags.com/index.php/api/firebasenotification/getInserttoken
        
        self.webRequest = [[RequestManager sharedInstance] requestWithMethodName:@"firebasenotification/getInserttoken"
                                                                      methodType:@"GET"
                                                                      parameters:parameters
                                                                        delegate:self
                                                                          secure:NO
                                                                  withAuthParams:YES];
        
        [self.webRequest setDidFinishSelector:@selector(sendTokenRequestFinished:)];
        [self.webRequest setDidFailSelector:@selector(sendTokenRequestFailed:)];
        
        [self.webRequest startAsynchronous];
    }
}

-(void)sendTokenRequestFinished:(ASIHTTPRequest *)request {

    NSLog(@"Insert Token: %@", request.responseString);
}

-(void)sendTokenRequestFailed:(ASIHTTPRequest *)request {

}

- (void)registerPushNotification {

    
    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier. Disable the deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:allNotificationTypes];
#pragma clang diagnostic pop
    } else {
        // iOS 8 or later
        // [START register_for_notifications]

        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
        
        // For iOS 10 data message (sent via FCM)
        [FIRMessaging messaging].remoteMessageDelegate = self;
        
#else
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        // [END register_for_notifications]
    }
}

#pragma mark Deep Linking methods



- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"%s", __FUNCTION__);
    return [self application:app openURL:url options:options];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"%s", __FUNCTION__);
    FIRDynamicLink *dynamicLink =
    [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    
    if (dynamicLink) {
        // Handle the deep link. For example, show the deep-linked content or
        // apply a promotional offer to the user's account.
        // [START_EXCLUDE]
        // In this sample, we just open an alert.
        NSString *message = [self generateDynamicLinkMessage:dynamicLink];
        [self parseUrlLinks:message];
        // [END_EXCLUDE]
        return YES;
    }
    
    // [START_EXCLUDE silent]
    // Show the deep link that the app was called with.
    NSString *message = [self generateURLMessage:url];
    [self parseUrlLinks:message];
    // [END_EXCLUDE]
    return NO;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    NSLog(@"%s", __FUNCTION__);
    // [START_EXCLUDE silent]
    NSLog(@"%@", userActivity.webpageURL);
    __weak AppDelegate *weakSelf = self;
    // [END_EXCLUDE]
    
    BOOL handled = [[FIRDynamicLinks dynamicLinks]
                    handleUniversalLink:userActivity.webpageURL
                    completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                 NSError * _Nullable error) {
                        // [START_EXCLUDE]
                        
                        
                        
                        AppDelegate *strongSelf = weakSelf;
                        NSString *message = [strongSelf generateDynamicLinkMessage:dynamicLink];
                        [strongSelf parseUrlLinks:message];
                        // [END_EXCLUDE]
                    }];
    
    // [START_EXCLUDE silent]
    if (!handled) {
        // Show the deep link URL from userActivity.
        NSString *message = [self generateURLMessage:userActivity.webpageURL];
        
        [self parseUrlLinks:message];
    }
    // [END_EXCLUDE]
    
    return handled;
}

- (NSString *)generateURLMessage:(NSURL *)url {

    NSLog(@"%s", __FUNCTION__);
    NSLog(@"URL: %@", url.absoluteString);
    NSLog(@"URL Host: %@", url.host);
    NSLog(@"URL Scheme: %@", url.scheme);
    NSLog(@"URL Path: %@", url.path);
    
    if (![url.path isEqualToString:@""] && ![url.path isEqual:nil]) {
     
        return url.path;
    }
    else {
        
        return @"HomePage";
    }
}
    
- (NSString *)generateDynamicLinkMessage:(FIRDynamicLink *)dynamicLink {
    NSLog(@"%s", __FUNCTION__);
    
    NSString *matchConfidence;
    if (dynamicLink.matchConfidence == FIRDynamicLinkMatchConfidenceStrong) {
        matchConfidence = @"strong";
    } else {
        matchConfidence = @"weak";
    }
    
    NSLog(@"Dynamic Link URL: %@", dynamicLink.url.absoluteString);
    NSLog(@"Dynamic Link Host: %@", dynamicLink.url.host);
    NSLog(@"Dynamic Link Scheme: %@", dynamicLink.url.scheme);
    NSLog(@"Dynamic Link Path: %@", dynamicLink.url.path);
    
    if (![dynamicLink.url.path isEqualToString:@""] && ![dynamicLink.url.path isEqual:nil]) {
     
        return dynamicLink.url.path;
    }
    else {
    
        return @"HomePage";
    }
}

- (void)parseUrlLinks:(NSString *)urlString {
    NSLog(@"%s", __FUNCTION__);
    
    // https://f985d.app.goo.gl/25ee == http://www.nmags.com/liverpool/chow/973
    // mtdruitt-stmarys/services-in-the-city/2898
    
    NSArray *parseValues = [urlString componentsSeparatedByString:@"/"];
    
    if ([urlString isEqualToString:@"HomePage"]) {
        
    }
    // /coupons/1024
    else if ([parseValues[1] isEqualToString:@"coupons"]) {
    
        self.couponId = parseValues[2];
        
        [self requestForCouponWithCouponsId:self.couponId];
    }
    else {
        
        
        if ([parseValues count] >= 3) {
            
            // /fairfield/chow/1024
            
            // fairfield
            self.regionName = parseValues[1];
            // chow
            self.magazineName = parseValues[2];
            // 1024
            self.couponId = parseValues[3];
            
            
            [self requestForCouponWithCouponsId:self.couponId];
        }
        else if ([parseValues count] == 2) {
        
            if ([urlString isEqualToString:@"magazine"]) {
        
                // /magazine/fairfield
                
                
            }
            else {
                
                // /fairfield/chow
                
                
            }
        }
        else {
        
        }
        
        // /the-hills/abode/2789
        // /liverpool/chow/973
    }
}

#pragma mark - ASIHTTPRequst methods

- (void)deepLinkingEnabledLocation:(NSNotification *)notification {

    [self requestForCouponWithCouponsId:self.couponId];
}

- (void)requestForCouponWithCouponsId:(NSString *)couponsId {
    NSLog(@"%s", __FUNCTION__);
    
    /* ASSIHttp request for magazines*/
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // Send the current location to the API
    if ([[LocationUtiliy sharedInstance] userAccepted]) {
        
        [_loadingView show];
        
        CLLocation *currentLocation = [[LocationUtiliy sharedInstance] currentLocation];
        [parameters setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude] forKey:@"latitude"];
        [parameters setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude] forKey:@"longitude"];
    
        // Check if the iOS has the retina display option
        [parameters setObject:[NSNumber numberWithBool:[UIApplication supportsRetinaDisplay]] forKey:@"retina_support"];
        // Send the region id parameter
        [parameters setObject:couponsId forKey:@"coupons_id"];
        
        
        
        
        self.webRequest = [[RequestManager sharedInstance] requestWithMethodName:@"coupons/singleCoupons"
                                                                      methodType:@"GET"
                                                                      parameters:parameters
                                                                        delegate:self
                                                                          secure:NO
                                                                  withAuthParams:NO];
        
        [self.webRequest setDidFinishSelector:@selector(couponsRequestFinished:)];
        [self.webRequest setDidFailSelector:@selector(couponsRequestFailed:)];
        
        [self.webRequest startAsynchronous];
    }
    else {
    
        if (![LocationUtiliy sharedInstance].isEnableLocationFromDeepLink) {
        
            [LocationUtiliy sharedInstance].isEnableLocationFromDeepLink = YES;
            [[LocationUtiliy sharedInstance] start];
        }
    }
}

-(void)couponsRequestFinished:(ASIHTTPRequest *)request {
    
    NSLog(@"%s", __FUNCTION__);
//    [_loadingView hide];
    
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
//                                                       style:UIAlertActionStyleDefault
//                                                     handler:^(UIAlertAction *action) {
//                                                         NSLog(@"OK");
//                                                     }];
//    
//    UIAlertController *alertController =
//    [UIAlertController alertControllerWithTitle:@"Deep-link Data"
//                                        message:@"Its working"
//                                 preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:okAction];
//    
//    
//    
//    UINavigationController *navigationVC = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
//    
//    NSLog(@"%@", navigationVC.visibleViewController);
//    
//    [navigationVC.visibleViewController presentViewController:alertController animated:YES completion:nil];

    
    
    NSString *responseString = [request responseString];
    id responseObject = [responseString JSONValue];
    NSLog(@"coupons: %@", responseObject);
    
    NSMutableDictionary *couponsDictionary = [[NSMutableDictionary alloc] init];
    NSArray *couponsArray = [[NSArray alloc] init];
    // Check if the response object is empty
    if (![NSString isNilOrEmpty:responseString]) {
        if ([responseObject respondsToSelector:@selector(objectAtIndex:)]) {
            
            // Initialize the coupon dictionary
            couponsDictionary = [NSMutableDictionary dictionary];
            
            // Initialize an array that will hold all the coupon objects for displaying them on the map
            NSMutableArray *appendCoupon = [NSMutableArray array];
            
            /* For each dictionary from the response, initialize a coupon object, check it's category id,
             and add it to the coupons dictionary for the coresponding category key */
            for (NSDictionary *couponInfo in responseObject ) {
                Coupons *coupon = [[Coupons alloc] initWithCouponInfo:couponInfo];
                
                [appendCoupon addObject:coupon];
                
                // Sort the coupons by category id
                for (int i=0; i<=16; i++) {
                    NSString *categoryID = [NSString stringWithFormat:@"%d",i];
                    
                    if ([coupon.category[0].categoryId isEqualToString:categoryID]) {
                        NSMutableArray *catArray = [NSMutableArray arrayWithArray:[couponsDictionary objectForKey:categoryID]];
                        
                        /* If the coupon dictionary already contains an object for a category,
                         append it to that one, otherwise initialize the object with the coupon */
                        if ([catArray count]) {
                            [catArray addObject:coupon];
                        } else {
                            catArray = [NSMutableArray arrayWithObject:coupon];
                        }
                        
                        // Set the coupon objects for the coresponding category id in the coupons dictionary
                        [couponsDictionary setObject:catArray forKey:categoryID];
                    }
                }
                [coupon release];
            }
            couponsArray = [NSArray arrayWithArray:appendCoupon];
//            [appendCoupon release];
//            [couponsDictionary release];
        }
    }
    
    if (couponsArray.count > 0) {
        
        [couponsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            Coupons *coupon = (Coupons *)obj;
            
            NSLog(@"Coupon ID: %@", coupon.couponId);
            
            if ([coupon.couponId isEqualToString:self.couponId]) {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                               {
                
                                   [_loadingView hide];
                                   
                                   UINavigationController *navigationVC = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
                                   
                                   NSLog(@"%@", navigationVC.visibleViewController);
                                   
                                   if ([navigationVC.visibleViewController isKindOfClass:[MenuController class]]) {
                                       
                                       [Utility showCouponDetailsWithCoupon:coupon onTarget:navigationVC];
                                   }
                                   else if ([navigationVC.visibleViewController isKindOfClass:[TabBarController class]]) {
                                       
                                       TabBarController *tabBarController = (TabBarController *)navigationVC.visibleViewController;
                                       NSLog(@"%@", tabBarController.selectedViewController);
                                       
                                       UINavigationController *tabBarNavigationChild = (UINavigationController *)tabBarController.selectedViewController;
                                       
                                       NSLog(@"%@", tabBarNavigationChild.visibleViewController);
                                       
                                       [Utility showCouponDetailsWithCoupon:coupon onTarget:navigationVC];
                                   }
                               });
            }
        }];
    }
    else {
        
        [_loadingView hide];
    }
    // Check if the dictionary contains coupon objects, if so, display the tableview, otherwise a message
//    if ([self.couponsDictionary count] == 0) {
//        [self.tableView setAlpha:0.0];
//        [_mapView setAlpha:0.0];
//        [_view360 setAlpha:0.0f];
//        [self.navigationItem setRightBarButtonItem:nil animated:YES];
//        [self showMessageViewWithContent:NSLocalizedString(@"There are no coupons yet. Please try again soon!", nil)];
//    } else {
//        int size = [self.couponsArray count];
//        NSLog(@"there are %d objects in the array", size);
//        
//        [_view360 setAlpha:0.0f];
//        [_mapView setAlpha:0.0];
//        [self.tableView setAlpha:1.0];
//        
//        int i = 0;
//        
//        for(Coupons *coupon in self.couponsArray){
//            
//            if (![NSString isNilOrEmpty: coupon.address1] || ![NSString isNilOrEmpty: coupon.address2]) {
//                if (![NSString isNilOrEmpty: coupon.suburb] || ![NSString isNilOrEmpty: coupon.postcode]) {
//                    i++;
//                }
//            }
//        }
//        
//        if (i > 0) {
//            [self.navigationItem setRightBarButtonItem:self.mapButton animated:YES];
//            if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
//            {
//                UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
//                                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                                   target:nil action:nil];
//                negativeSpacer.width = -11;// it was -6 in iOS 6
//                [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, self.mapButton, nil] animated:NO];
//            };
//        } else {
//            [self.navigationItem setRightBarButtonItem:nil animated:YES];
//        }
//        
//        [_tableView reloadData];
//    }
}

- (void)couponsRequestFailed:(ASIHTTPRequest *)request {
    NSLog(@"%s", __FUNCTION__);
    
//    [_loadingView hide];
    
//    [self.tableView setAlpha:0.0];
//    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    //    [self showMessageViewWithContent:NSLocalizedString(@"There are no coupons yet. Please try again soon!", nil)];
    
    NSString *alertMessage = nil;
    
    if (NotReachable == [[NetworkHandler sharedInstance] currentReachabilityStatus]) {
        alertMessage = NSLocalizedString(@"It seems you don't have a working internet connection. Please check your Network Settings and try again!", nil);
    } else {
        alertMessage = NSLocalizedString(@"We had a problem retrieving the coupons list. Please try again later.", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:NSLocalizedString(@"Try again", nil), nil];
    alert.tag = 111;
    [alert show];
    [alert release];
}


- (void)sendRequestForAllCoupons {
    NSLog(@"%s", __FUNCTION__);
    
    
    NSString *regionID = [[[RegionManager sharedInstance] region] regionId];
    
    if (regionID != nil && ![regionID isEqualToString:@""]) {
     
        /* ASSIHttp request for magazines*/
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        // Send the current location to the API
        if ([[LocationUtiliy sharedInstance] userAccepted]) {
            CLLocation *currentLocation = [[LocationUtiliy sharedInstance] currentLocation];
            [parameters setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude] forKey:@"latitude"];
            [parameters setObject:[NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude] forKey:@"longitude"];
        }
        
        // Check if the iOS has the retina display option
        [parameters setObject:[NSNumber numberWithBool:[UIApplication supportsRetinaDisplay]] forKey:@"retina_support"];
        // Send the region id parameter
        [parameters setObject:regionID forKey:@"region_id"];
        
        self.webRequest = [[RequestManager sharedInstance] requestWithMethodName:@"coupons/getCoupons"
                                                                      methodType:@"GET"
                                                                      parameters:parameters
                                                                        delegate:self
                                                                          secure:NO
                                                                  withAuthParams:NO];
        
        [self.webRequest setDidFinishSelector:@selector(allCouponsRequestFinished:)];
        [self.webRequest setDidFailSelector:@selector(allCouponsRequestFailed:)];
        
        [self.webRequest startAsynchronous];
        
    }
}

-(void)allCouponsRequestFinished:(ASIHTTPRequest *)request {
    
    NSString *responseString = [request responseString];
    
    if (![NSString isNilOrEmpty:responseString]) {
        id responseObject = [responseString JSONValue];
        
        NSLog(@"All Coupons: %@", responseObject);
        
        NSArray *tempCoupons = [[NSArray alloc] init];
        
        if ([responseObject respondsToSelector:@selector(objectAtIndex:)]) {
            tempCoupons = [Utility parseCouponsJSON:responseObject];
        }
        
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            
            [MonitorCouponsEntity MR_truncateAllInContext:localContext];
            
            for (int i=0; i< tempCoupons.count; i++) {
            
                MonitorCoupons *monitorCoupons = (MonitorCoupons *)[tempCoupons objectAtIndex:i];

                MonitorCouponsEntity *monitorEntity = [MonitorCouponsEntity MR_createEntityInContext:localContext];
                
                monitorEntity.couponId = (monitorCoupons.couponId != nil) ? monitorCoupons.couponId : @"";
                monitorEntity.couponTitle = (monitorCoupons.couponTitle != nil) ? monitorCoupons.couponTitle : @"";
                monitorEntity.lat = monitorCoupons.lat;
                monitorEntity.lon = monitorCoupons.lon;
            }
            
        }];
        
        [LocationUtiliy sharedInstance].monitorCoupons = [Utility getMonitorCouponsFromDB];
        [[LocationUtiliy sharedInstance] start];
        [tempCoupons release];
    }
}

-(void)allCouponsRequestFailed:(ASIHTTPRequest *)request {
    
}

#pragma mark - Helper Methods

- (void)saveContext
{
    NSLog(@"%s", __FUNCTION__);
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    [localContext MR_saveToPersistentStoreWithCompletion:nil];
}

-(void)playVideo:(NSTimeInterval)sec
{
    
    [VideoPlayer playVideo:sec completion:^(BOOL isFinished, NSError * _Nullable error) {
        
        if (isFinished) {
            
            [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"FirstTime"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            
            //this on play video? should be on every init?
//            [self startLocationServices];
            
            if ([Utility isFirstStartUp]) {
                
                [Utility setFirstStartUp];
                
                [self registerPushNotification];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"regionSelectFirstTime" object:nil];
            }
        }
        
        NSLog(@"Video is Finished/Stopped");
    }];
}

- (void)startLocationServices {

    if (![[LocationUtiliy sharedInstance] userAccepted]) {
        
        [[LocationUtiliy sharedInstance] start];
    }
}

-(void)continueEntrySequence
{
    IntroController *introController = [[IntroController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:introController];
    [navController setNavigationBarHidden:YES animated:NO];
    [introController release];
    [self.navController presentModalViewController:navController animated:NO];
    [navController release];
}

@end
