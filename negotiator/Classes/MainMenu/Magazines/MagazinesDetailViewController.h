//
//  MagazinesDetailViewController.h
//  negotiator
//
//  Created by Alexandru Chis on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Magazines.h"
#import "AppDelegate.h"

@interface MagazinesDetailViewController : MainController <MKMapViewDelegate>{
    Magazines               *_magazineInfo;
    
    IBOutlet UIView         *_detailsView;
    
    IBOutlet UILabel        *_storeLabel;
    IBOutlet UILabel        *_photoPersonLabel;
    IBOutlet UILabel        *_addressLabel;
    
    IBOutlet UIButton       *_mapButton;
    IBOutlet UIButton       *_callButton;
    
    IBOutlet UIImageView    *_storeImage;
    IBOutlet UIView *detailView;
    
    IBOutlet UIImageView *detailHeader;
    MKMapView               *_mapView;  
    
    UIBarButtonItem         *_magazinesBarButton;
    
    UIImageView             *_managedImage;
    
    UIButton *_view360;
}

@property (nonatomic, retain) Magazines         *magazineInfo;
@property (nonatomic, retain) MKMapView         *mapView;
@property (nonatomic, retain) UIView            *detailsView;
@property (nonatomic, retain) UIImageView       *managedImage;
@property (nonatomic, retain) UIButton *view360;

- (void)displayDetailImage;
- (void)goBack:(id)sender;
- (void)goToDetails:(id)sender;

- (IBAction)goToMap:(id)sender;
- (IBAction)callStore:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil magazineInfo:(Magazines *)magazine;

@end
