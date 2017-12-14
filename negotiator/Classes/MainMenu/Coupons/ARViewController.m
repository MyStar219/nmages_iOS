//
//  ARViewController.m
//  negotiator
//
//  Created by KL on 6/2/16.
//
//

#import "ARViewController.h"
#import "DetailsViewController.h"
#import "CouponDetailsViewController.h"

@interface ARViewController ()

@end

@implementation ARViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.prARManager = [[PRARManager alloc] initWithSize:self.view.frame.size
                                                delegate:self
                                               showRadar:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(gotoDetails:)
                                                name:@"goto_details"
                                              object:nil];
}

-(void)x360Map
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)gotoDetails:(NSNotification *)not
{
    NSString *s = [not object];
    NSLog(@"s: %@", s);
    for(Coupons *coupon in self.couponsArray)
    {
        if([coupon.couponId isEqualToString:s])
        {
            
//            DetailsViewController *detailsController = [[DetailsViewController alloc]initWithCouponsInfo:coupon];
            
            CouponDetailsViewController *detailsController = [[CouponDetailsViewController alloc] initWithNibName:@"CouponDetailsViewController" bundle:[NSBundle mainBundle] couponsInfo:coupon];
//            [self.navigationController pushViewController:detailsController animated:YES];
            
            
            UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:detailsController];
            if ([[nc navigationBar] respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
                [[nc navigationBar] setBackgroundImage:[UIImage imageNamed:@"infoNavBar_bkgd.png"]
                                                               forBarMetrics:UIBarMetricsDefault];
            }
            [self presentViewController:nc animated:YES completion:nil];
            
            //
            
            
            break;
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!self.pointsArray)
    {
        //configure AR
        self.pointsArray = [NSMutableArray new];
        for(Coupons *coupon in self.couponsArray)
        {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:coupon.couponId forKey:@"id"];
            [dict setObject:coupon.title forKey:@"title"];
            [dict setObject:coupon.companyImageURL forKey:@"image"];
            [dict setObject:[NSString stringWithFormat:@"%.6f", coupon.lat] forKey:@"lat"];
            [dict setObject:[NSString stringWithFormat:@"%.6f", coupon.lon] forKey:@"lon"];
            [self.pointsArray addObject:dict];
        }
        [self.prARManager startARWithData:self.pointsArray forLocation:[[LocationUtiliy sharedInstance] currentLocation].coordinate];
        
        //add x button
        UIButton *x = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 50.0f, 20.0f, 40.0f, 40.0f)];
        [x setBackgroundImage:[UIImage imageNamed:@"xwhite.png"] forState:UIControlStateNormal];
        [x addTarget:self
              action:@selector(x360Map) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:x];
        [x setTag:-1945];
    }
}

#pragma mark - PRARManager Delegate

-(void)prarDidSetupAR:(UIView *)arView withCameraLayer:(AVCaptureVideoPreviewLayer *)cameraLayer andRadarView:(UIView *)radar
{
    [self.view.layer addSublayer:cameraLayer];
    [self.view addSubview:arView];
    [self.view bringSubviewToFront:[self.view viewWithTag:AR_VIEW_TAG]];
    [self.view addSubview:radar];
}

-(void)prarUpdateFrame:(CGRect)arViewFrame
{
    [[self.view viewWithTag:AR_VIEW_TAG] setFrame:arViewFrame];
}

-(void)prarGotProblem:(NSString *)problemTitle withDetails:(NSString *)problemDetails
{
    NSLog(@"AR problem: %@ %@", problemTitle, problemDetails);
}

@end
