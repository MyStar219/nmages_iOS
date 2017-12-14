
// KL

#import "Location.h"

@implementation Location

static Location *gInstance = NULL;

#pragma mark -
#pragma mark initialization and lifecycle

+(Location *)singleton
{
    @synchronized(self)
    {
        if(gInstance == NULL)
        {
            gInstance = [[Location alloc]init];
        }
    }
    
    return gInstance;
}

-(id)init
{
    self = [super init];
    
    return self;
}

#pragma mark -
#pragma mark CLLocation related

-(void)getLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
    else
    {
        if(([CLLocationManager locationServicesEnabled] &&
            [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied))
        {
            [self.locationManager startUpdatingLocation];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                           message:@"Please enable Location Services for this app in your iPhone Privacy Settings"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil, nil];
            //[alert show];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"location_refused" object:nil];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    self.location = newLocation;
//    self.location = [[CLLocation alloc]initWithLatitude:-33.86 longitude:151.21f];
    [[LocationUtiliy sharedInstance]setCurrentLocation:self.location];
    [[LocationUtiliy sharedInstance]setUserAcceptedLocation:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"location_set" object:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"location error: %@", [error localizedDescription]);
    if ([[error domain] isEqualToString: kCLErrorDomain] && [error code] == kCLErrorDenied)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"location_refused" object:nil];
    }
}


@end
