//
//  ARViewController.h
//  negotiator
//
//  Created by KL on 6/2/16.
//
//

#import <UIKit/UIKit.h>
#import "PRARManager.h"
#import "Coupons.h"

@interface ARViewController : UIViewController

@property (strong, nonatomic) PRARManager *prARManager;
@property (strong, nonatomic) NSMutableArray      *couponsArray, *pointsArray;

-(void)gotoDetails:(NSString *)idInt;

@end
