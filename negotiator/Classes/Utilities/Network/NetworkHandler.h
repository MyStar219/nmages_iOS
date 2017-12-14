//
//  NetworkHandler.h
//
//  Copyright 2010 Andrei vig. All rights reserved.
//

#import "Reachability.h"

@interface NetworkHandler : NSObject {
	// Keeps track of the reachability
	Reachability* _internetReach;
}

/**
 * Creates, unless already created, and returns a unique instance of
 * the Network handler.
 */
+ (NetworkHandler*) sharedInstance;

/**
 * Method used to receive reachability changes
 */
- (void) reachabilityChanged:(NSNotification *)aNotification;

/**
 * Returns the current reachability status.
 *
 * @return The current reachability status, i.e. if the network is reachable.
 */
- (NetworkStatus) currentReachabilityStatus;

@end
