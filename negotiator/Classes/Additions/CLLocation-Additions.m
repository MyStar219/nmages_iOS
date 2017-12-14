//
//  CLLocation-Additions.m
//  negotiator
//
//  Created by aplome on 20/07/2017.
//
//

#import "CLLocation-Additions.h"

@implementation CLLocation (CLLocation_Additions)


- (BOOL)isEqualORRangeWith:(CLLocation *)otherLocation {

    CLLocationDistance delta = [self distanceFromLocation:otherLocation];
    
    NSLog(@"Distance: %f", delta);
    NSLog(@"Accuracy: %f", self.horizontalAccuracy);
    
    BOOL isEqual = (delta < self.horizontalAccuracy);
    return isEqual;
}


@end
