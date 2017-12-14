//
//  RequestManager.m
//  PointZone
//
//  Created by Andrei Vig on 1/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RequestManager.h"
#import "ASIHTTPRequest.h"
#import "UIApplication-Additions.h"
#import "ASIFormDataRequest.h"

static RequestManager *kRequestManager = nil;

@implementation RequestManager

@synthesize baseURL = _baseURL;

- (id)init {
	
	self = [super init];
	if (!self) return nil;	
    _serverHost		= [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/index.php/api/", SERVER_URL]];
	_serviceVersion = [[NSString alloc] initWithString:@"1.0"];
	
	return self;
}

- (void)dealloc {
	
	[_serverHost release];
	[_serviceVersion release];
	
	[super dealloc];
}

+ (RequestManager *)sharedInstance {
	if (nil == kRequestManager) {
		kRequestManager = [[RequestManager alloc] init];
	}
	
	return kRequestManager;
}

- (ASIHTTPRequest *)requestWithMethodName:(NSString *)methodName	// clubs/getClubs?
							   methodType:(NSString *)methodType	// POST | GET
							   parameters:(NSDictionary *)parameters	
								 delegate:(id <ASIHTTPRequestDelegate>)delegate
								   secure:(BOOL)secure
						   withAuthParams:(BOOL)withAuthParams {
    
	/* get base url */
	NSString *baseURL = [self baseURLSecure:secure];
	
    NSMutableDictionary *extendedParams = [[NSMutableDictionary alloc] init];
    
    if (!withAuthParams) {
    
        [extendedParams setObject:[[UIDevice currentDevice] uniqueDeviceIdentifier] forKey:@"device"];
    }
    
	NSString *paramsQuery = nil;
	NSString *fullURL = nil;
	
	/* get param query & create full url */
	if ([methodType isEqualToString:@"POST"] || [methodType isEqualToString:@"PUT"]) {
        NSString *authQuery = [RequestManager queryStringFromParameters:extendedParams encoded:YES];
		fullURL = [NSString stringWithFormat:@"%@%@?%@", baseURL, methodName, authQuery];
	} else {
        [extendedParams addEntriesFromDictionary:parameters];
		paramsQuery = [RequestManager queryStringFromParameters:extendedParams encoded:YES];
		fullURL = [NSString stringWithFormat:@"%@%@?%@", baseURL, methodName, paramsQuery];		
	}
	
    [extendedParams release];
    
    NSLog(@"url called: %@", fullURL);
	NSURL *requestURL = [NSURL URLWithString:[fullURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    //LOG(@"requested url: %@", requestURL);
	
	ASIHTTPRequest *request = nil;
    
    if ([methodType isEqualToString:@"POST"]) {
        request = [ASIFormDataRequest requestWithURL:requestURL];
        
        NSArray *paramKeys = [parameters allKeys];
        
        for (NSUInteger index = 0, count = [paramKeys count]; index < count; index++) {
            NSString *paramKey		= [paramKeys objectAtIndex:index];
            NSString *paramValue	= [parameters objectForKey:paramKey];
            
            [(ASIFormDataRequest *)request setPostValue:paramValue forKey:paramKey];
        }
    } else {
        request = [ASIHTTPRequest requestWithURL:requestURL];        
    }

	[request setTimeOutSeconds:120];
	[request setDelegate:delegate];
	
	return request;
}

+ (NSString *)queryStringFromParameters:(NSDictionary *)params encoded:(BOOL)encoded {
	
	NSArray *paramsKeys = [params allKeys];
	NSMutableArray *paramsPairs = [[NSMutableArray alloc] init];

	
	for (NSString *paramKey in paramsKeys) {
		NSString *paramValue = [params objectForKey:paramKey];
		
		NSString *paramPair = [NSString stringWithFormat:@"%@=%@", paramKey, paramValue];
		[paramsPairs addObject:paramPair];
	}
	
	/* join param values */
	NSString *queryString = [paramsPairs componentsJoinedByString:@"&"];
	[paramsPairs release];
	
	return queryString;
}

- (NSString *)baseURLSecure:(BOOL)secure {
	NSString *baseURL = [NSString stringWithFormat:@"%@://%@", secure ? @"https" : @"http", _serverHost];
	return baseURL;
}

@end
