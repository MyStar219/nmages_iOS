//
//  MagazinesDetailViewController.m
//  negotiator
//
//  Created by Alexandru Chis on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MagazinesDetailViewController.h"
#import "AppDelegate.h"
#import "ARViewController.h"

@implementation MagazinesDetailViewController

@synthesize magazineInfo    = _magazineInfo;
@synthesize mapView         = _mapView;
@synthesize detailsView     = _detailsView;
@synthesize managedImage    = _managedImage;
@synthesize view360 = _view360;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil magazineInfo:(Magazines *)magazine {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    self.magazineInfo = magazine;
    
    return self;
}

- (void)dealloc {
    
    [_magazinesBarButton release];
    [_magazineInfo release];
    
    [detailView release];
    [detailHeader release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
//- (void)loadView {
//    [super loadView];
//}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([NSString isNilOrEmpty: self.magazineInfo.address1] &&
        [NSString isNilOrEmpty: self.magazineInfo.address2]) {
        [_mapButton setHidden:YES];
        [_callButton setFrame:CGRectMake(195.0, 32.0, 111.0, 32.0)];
        
    }
    
    self.view360 = [[UIButton alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 40.0f)];
    [self.view360 setBackgroundImage:[UIImage imageNamed:@"view360.png"] forState:UIControlStateNormal];
    [self.view360 addTarget:self action:@selector(view360Map) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.view360];
    [self.view360 setAlpha:0.0f];
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 40.0, 320.0, 326.0)];
    [_mapView setDelegate:self];
    [_mapView setShowsUserLocation:YES];
    [_mapView setAlpha:0.0];
    [self.view addSubview:_mapView];
    [_mapView release];
    
    if([[UIScreen mainScreen]bounds].size.height == 568)
    {
        [_mapView setFrame:CGRectMake(_mapView.frame.origin.x, _mapView.frame.origin.y, _mapView.frame.size.width, _mapView.frame.size.height + 90.0f)];
        //[_tableView setFrame:CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height + 90.0f)];
    }
    
    CGFloat factor = 43.0f;
    if([[UIScreen mainScreen]bounds].size.height == 568)
    {
        //factor = 130.0f;
    }
    if([[UIScreen mainScreen]bounds].size.height < 667) {
        _managedImage = [[UIImageView alloc] initWithFrame:
                         CGRectMake(0.0, factor,
                                    [UIScreen mainScreen].bounds.size.width , 232)];
        [_managedImage setContentMode:UIViewContentModeScaleAspectFit];
        [self.detailsView addSubview:_managedImage];
    } else if([[UIScreen mainScreen]bounds].size.height >= 667) {
        _managedImage = [[UIImageView alloc] initWithFrame:
                         CGRectMake(0.0, factor,
                                    [UIScreen mainScreen].bounds.size.width , 300.0)];
        [_managedImage setContentMode:UIViewContentModeScaleAspectFit];
        [self.detailsView addSubview:_managedImage];
    }

    [_managedImage release];

    [_storeLabel setText: self.magazineInfo.name];
    [_photoPersonLabel setText: self.magazineInfo.photoPerson];
    [_addressLabel setText:[self.magazineInfo formattedAddress]];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 30.0)];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"home_btn.png"] forState:UIControlStateNormal];
    [backButton setTitle:NSLocalizedString(@"  Back", nil) forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    _magazinesBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton release];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem setLeftBarButtonItem:_magazinesBarButton animated:YES];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, _magazinesBarButton, nil] animated:NO];
    };
    [self displayDetailImage];
    
    //gd
    UIButton *gd = [[UIButton alloc]initWithFrame:CGRectMake(10.0f, [UIScreen mainScreen].bounds.size.height - 205.0f, 300.0f, 60.0f)];
    [gd setBackgroundImage:[UIImage imageNamed:@"gd.png"] forState:UIControlStateNormal];
    [gd setTitle:@"GET DIRECTIONS TO HERE" forState:UIControlStateNormal];
    [gd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [gd addTarget:self
           action:@selector(gd:) forControlEvents:UIControlEventTouchUpInside];
    [gd setTag:-1945];
    [self.view addSubview:gd];
    [gd setHidden:YES];
}

-(void)view360Map
{
    ARViewController *ar = [[ARViewController alloc]initWithNibName:@"ARViewController" bundle:nil];
    [ar setCouponsArray:[NSArray arrayWithObject:self.magazineInfo]];
    [self presentViewController:ar animated:YES completion:nil];
}

-(IBAction)gd:(id)sender
{
    if(!self.mapView.userLocation)
        return;
    
    //open Maps from where we are to this group
    double lat = self.magazineInfo.lat;
    double lng = self.magazineInfo.lon;
    NSString *googleMapUrlString = [NSString stringWithFormat:@"maps://maps.google.com/maps?saddr=%.6f,%.6f&daddr=%.6f,%.6f", self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude, lat, lng];
    NSLog(@"gmurl: %@", googleMapUrlString);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapUrlString]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)displayDetailImage {
    
    if ([NSString isNilOrEmpty:self.magazineInfo.detailImageURL ]) {
        [self.managedImage setImage:[UIImage imageNamed:@"no_image.png"]];
    } else {
        
        [self.managedImage setImageWithURL:[NSURL URLWithString: self.magazineInfo.detailImageURL] placeholderImage:[UIImage imageNamed:@"no_image.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:NSClassFromString(@"MKUserLocation")]) {
        return nil;
    }
    
	NSString *identifier = nil;
    
    if (![annotation isKindOfClass:NSClassFromString(@"MKUserLocation")]) {
        identifier = @"magazinesIdentifier";
    } else {
        identifier = @"userIdentifier";
    }
    
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	
	if (!annotationView) {
		annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
	}
    
    [annotationView setNeedsDisplay];
    [annotationView setAnimatesDrop:YES];
    [annotationView setPinColor:MKPinAnnotationColorRed];
    [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
    [annotationView setCanShowCallout:YES];
    
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
    [leftView setContentMode:UIViewContentModeScaleAspectFill];
    [leftView setClipsToBounds:YES];
    
    UIImage *magazineImage = [(Magazines *)annotation image];
    
    if (magazineImage) {
        [leftView setImage:magazineImage];
    } else {
        [leftView setImage:[UIImage imageNamed:@"no_image.png"]];
    }
    
    [annotationView setLeftCalloutAccessoryView:[leftView autorelease]];
    
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self goToDetails:nil];
}


#pragma mark - UIButton action methods

- (void)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goToDetails:(id)sender {

    [UIView beginAnimations:@"switchToList" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:NO];
	
    [self.view360 setAlpha:0.0f];
	[self.mapView setAlpha:0.0];
    [self.detailsView setAlpha:1.0];
    
    [[self.view viewWithTag:-1945]setHidden:YES];
	
	[UIView commitAnimations];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem setLeftBarButtonItem:_magazinesBarButton animated:YES];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, _magazinesBarButton, nil] animated:NO];
    };

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        [self.navigationItem setRightBarButtonItems:nil];
    else
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (IBAction)goToMap:(id)sender{
    NSLog(@"goToMap");
    [UIView beginAnimations:@"switchToMap" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
	
	[self.detailsView setAlpha:0.0];
    [self.mapView setAlpha:1.0];
    [self.view360 setAlpha:1.0f];
    
    [[self.view viewWithTag:-1945]setHidden:NO];
	
	[UIView commitAnimations];
    
    UIButton *backToDetailsButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 30.0)];
    [backToDetailsButton addTarget:self action:@selector(goToDetails:) forControlEvents:UIControlEventTouchUpInside];
    [backToDetailsButton setBackgroundImage:[UIImage imageNamed:@"right_btn.png"] forState:UIControlStateNormal];
    [backToDetailsButton setTitle:NSLocalizedString(@" Back", nil) forState:UIControlStateNormal];
    [backToDetailsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    UIBarButtonItem *backToDetails = [[UIBarButtonItem alloc] initWithCustomView:backToDetailsButton];
    [backToDetailsButton release];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
//        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setLeftBarButtonItems:nil];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, backToDetails, nil] animated:NO];
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:backToDetails animated:YES];
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    }

    [backToDetails release];

    [self.mapView addAnnotation:self.magazineInfo];
        [self.mapView setRegion:[MKMapView regionForAnnotations:[NSArray arrayWithObject:self.magazineInfo]]];
    [self.mapView selectAnnotation:self.magazineInfo animated:YES];
}

- (IBAction)callStore:(id)sender{
    
//    NSString *phoneLinkString = [NSString stringWithFormat:@"tel:%@", self.magazineInfo.phone];
//    NSURL *phoneLinkURL = [NSURL URLWithString:phoneLinkString];
//    [[UIApplication sharedApplication] openURL:phoneLinkURL];
    
    NSString *phoneLinkString = [NSString stringWithFormat:@"tel:%@", self.magazineInfo.phone];
    NSURL *phoneLinkURL = [NSURL URLWithString:phoneLinkString];
    if([[UIApplication sharedApplication] canOpenURL:phoneLinkURL]){
        [[UIApplication sharedApplication] openURL:phoneLinkURL];
    }else{
        NSString *alertMessage = [NSString stringWithFormat:@"Do you want to call this number: %@ ?",self.magazineInfo.phone];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage
                                                        message:nil 
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel" 
                                              otherButtonTitles:@"Call",nil];
        [alert show];
        [alert release];
        
        
    }

}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *phoneLinkString = [NSString stringWithFormat:@"tel:%@", self.magazineInfo.phone]; 
        NSURL *phoneLinkURL = [NSURL URLWithString:phoneLinkString];
        [[UIApplication sharedApplication] openURL:phoneLinkURL];
    }
}

@end
