//
//  NetworkHandler.mm
//
//  Copyright 2010 Wayfinder Systems AB. All rights reserved.
//

#import "NetworkHandler.h"

static NetworkHandler* _networkHandler;

@implementation NetworkHandler

+ (NetworkHandler*) sharedInstance {
	if(nil == _networkHandler) {
		_networkHandler = [[NetworkHandler alloc] init];
	}
	return _networkHandler;
}

- (id)init {
	self = [super init];
	if (!self) return nil;
    
    
	// Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
	// method "reachabilityChanged" will be called. 
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(reachabilityChanged:) 
												 name:kReachabilityChangedNotification 
											   object:nil];
	 

	_internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[_internetReach startNotifier];
		
	return self;
}

- (void)dealloc {
	[_internetReach stopNotifier];
	[_internetReach release];
	[super dealloc];
}

// Called by Reachability whenever status of network changes.
- (void)reachabilityChanged: (NSNotification* )aNotification {
	
	if (NotReachable == [_internetReach currentReachabilityStatus]) {
		LOG(@"Internet is not reachable.");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"InternetNotReachable" 
															object:nil];
		
	} else {
		LOG(@"Internet is reachable.");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"InternetReachable" 
															object:nil];
	}
}

- (NetworkStatus) currentReachabilityStatus {
	
	if (NotReachable == [_internetReach currentReachabilityStatus]) {
		LOG(@"Internet is not reachable.");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"InternetNotReachable" 
															object:nil];
		
	} else {
		LOG(@"Internet is reachable.");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"InternetReachable" 
															object:nil];
	}
	
	return [_internetReach currentReachabilityStatus];
}

@end
