//
//  DetailsViewController.m
//  negotiator
//
//  Created by Vig Andrei on 1/23/12.
//  Copyright (c) 2012 Dot IT Mobile. All rights reserved.
//

#import "DetailsViewController.h"
#import "Reachability.h"
#import "JSON.h"
#import "CouponsCell.h"
#import "CouponDetailsViewController.h"
#import "RegionManager.h"
#import "Coupons.h"
#import "AppDelegate.h"
#import "CompanyDetailsCell.h"


@implementation DetailsViewController

@synthesize tableView               = _tableView;
@synthesize companyImage            = _companyImage;
@synthesize couponsInfo             = _couponsInfo;

@synthesize infoData = _infoData;
@synthesize headerTitles = _headerTitles;

- (id)initWithCouponsInfo:(Coupons *)coupons {
    self = [super init];
    if (!self) return nil;
    
    self.couponsInfo = coupons;
    
    self.infoData = [NSMutableArray array];
    self.headerTitles = [NSMutableArray array];
    
    // set coupon data
    NSMutableArray *couponData = [NSMutableArray array];
    if (![NSString isNilOrEmpty:self.couponsInfo.couponTitle]) {
        [couponData addObject:[NSDictionary dictionaryWithObject:self.couponsInfo.couponTitle forKey:@"Offer"]];
    }

    if (![NSString isNilOrEmpty:self.couponsInfo.description]) {
        [couponData addObject:[NSDictionary dictionaryWithObject:self.couponsInfo.description forKey:@"Description"]];
    }
    
    if (![NSString isNilOrEmpty:self.couponsInfo.conditions]) {
        [couponData addObject:[NSDictionary dictionaryWithObject:self.couponsInfo.conditions forKey:@"Conditions"]];
    }
    
    if ([couponData count] > 0) {
        [self.infoData addObject:couponData];
        [self.headerTitles addObject:NSLocalizedString(@"Coupon Details", nil)];
    }
    
    // set company data
    NSMutableArray *companyData = [NSMutableArray array];
    if (![NSString isNilOrEmpty:self.couponsInfo.phone]) {
        [companyData addObject:[NSDictionary dictionaryWithObject:self.couponsInfo.phone forKey:@"Phone"]];
    }
        
    if (![NSString isNilOrEmpty:self.couponsInfo.companyAddress]) {
        [companyData addObject:[NSDictionary dictionaryWithObject:self.couponsInfo.companyAddress forKey:@"Address"]];
    }
    
    
    if (![NSString isNilOrEmpty:self.couponsInfo.email]) {
        [companyData addObject:[NSDictionary dictionaryWithObject:self.couponsInfo.email forKey:@"Email"]];
    }
    
    if (![NSString isNilOrEmpty:self.couponsInfo.website]) {
        [companyData addObject:[NSDictionary dictionaryWithObject:self.couponsInfo.website forKey:@"Website"]];
    }

    if (![NSString isNilOrEmpty:self.couponsInfo.contact]) {
        [companyData addObject:[NSDictionary dictionaryWithObject:self.couponsInfo.contact forKey:@"Contact"]];
    }
    
    if ([companyData count] > 0) {
        [self.infoData addObject:companyData];
        [self.headerTitles addObject:NSLocalizedString(@"Company Details", nil)];
    }

    
    return self;
}

- (void)dealloc {

    self.couponsInfo    = nil;
    self.infoData       = nil;
    self.headerTitles   = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)loadView {
    [super loadView];
    
    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:self.view.frame];
    backgroundView.image = [UIImage imageNamed:@"info_bkgd.png"];
    [self.view addSubview:backgroundView];
    [backgroundView release];
    
    _tableView = [[UITableView alloc] initWithFrame:
                  CGRectMake(0.0, 0.0,
                             [UIScreen mainScreen].bounds.size.width,
                             367.0) style:UITableViewStyleGrouped];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setBackgroundView:nil];
    [self.view addSubview:_tableView];
    [_tableView release];
    
    if([[UIScreen mainScreen]bounds].size.height == 568)
    {
        //[_mapView setFrame:CGRectMake(_mapView.frame.origin.x, _mapView.frame.origin.y, _mapView.frame.size.width, _mapView.frame.size.height + 90.0f)];
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height + 90.0f)];
    }
    
    //company image view
    _companyImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 92.0, 92.0)];
    [_companyImage setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:_companyImage];
    [_companyImage release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 30.0)];
    [homeButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [homeButton setBackgroundImage:[UIImage imageNamed:@"home_btn.png"] forState:UIControlStateNormal];
    [homeButton setTitle:NSLocalizedString(@"  Back", nil) forState:UIControlStateNormal];
    [homeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
    [homeButton release];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem setLeftBarButtonItem:backButton animated:YES];
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -11;// it was -6 in iOS 6
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, backButton, nil] animated:NO];
    };
    [backButton release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
}

- (void)displayCompanyImage {
    
    NSString *imagePath = nil;
    
    if ([NSString isNilOrEmpty:self.couponsInfo.companyImageURL ]) {
        if ([NSString isNilOrEmpty:self.couponsInfo.thumbImageURL]) {
            [self.companyImage setImage:[UIImage imageNamed:@"no_image.png"]];
            return;
        } else {
            imagePath = self.couponsInfo.thumbImageURL;
        }
    } else {
        imagePath = self.couponsInfo.companyImageURL;
    }
    
    [self.companyImage setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"no_image.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.infoData count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    
    if (0 == section) {
        numberOfRows = 1;
    } else {
        numberOfRows = [[self.infoData objectAtIndex:section - 1] count];
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", indexPath.section, indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {

        if (0 == indexPath.section) {
            
            cell = [[[CompanyDetailsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [(CompanyDetailsCell *)cell updateWithCoupon:self.couponsInfo];
            
        } else {
            
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:11.0]];
            
            NSArray *sectionInfo = [self.infoData objectAtIndex:indexPath.section - 1];
            NSDictionary *rowInfo = [sectionInfo objectAtIndex:indexPath.row];
            
            NSString *key = [[rowInfo allKeys] lastObject];
            NSString *content = [rowInfo objectForKey:key];
            
            CGSize contentSize = [[content stringByStrippingHTML:content] sizeWithFont:[UIFont systemFontOfSize:14.0]
                                     constrainedToSize:CGSizeMake(210.0, 1000.0)
                                         lineBreakMode:UILineBreakModeWordWrap];
            
            UITextView *contentView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, 220.0, contentSize.height + 20.0)];
            [contentView setDataDetectorTypes:UIDataDetectorTypeAll];
            
            if ([key isEqualToString:@"Address"]) {
                [contentView setDataDetectorTypes:UIDataDetectorTypeNone];
            } else {
                [contentView setDataDetectorTypes:UIDataDetectorTypeAll];
            }
            
            [contentView setEditable:NO];
            [contentView setScrollEnabled:NO];
            [contentView setBackgroundColor:[UIColor clearColor]];
            [contentView setFont:[UIFont systemFontOfSize:14.0]];
            
            //check the coreponding key to apply string formatting by case
            if ([key isEqualToString:@"Phone"]) {
                [contentView setText:content];
            } else if ([key isEqualToString:@"Address"]){
                [contentView setText:[content removeHTMLTags]];
            } else if ([key isEqualToString:@"Description"]){
                [contentView setText:[content stringByStrippingHTML:content]];
                [contentView setDataDetectorTypes:UIDataDetectorTypeNone];
            } else {
                [contentView setText:[content stringByStrippingHTML:content]];
            }
           
            [cell setAccessoryView:contentView];
            [contentView release];
            [cell.textLabel setText:key];
            [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
        }
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = nil;
    
    return title;
    
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 0.0;
    
    if (0 == indexPath.section) {
        height = 60.0;
    } else {
        NSArray *sectionInfo = [self.infoData objectAtIndex:indexPath.section - 1];
        NSDictionary *rowInfo = [sectionInfo objectAtIndex:indexPath.row];
        
        NSString *key = [[rowInfo allKeys] lastObject];
        NSString *content = [rowInfo objectForKey:key];
                             
        CGSize contentSize = [[content stringByStrippingHTML:content] sizeWithFont:[UIFont systemFontOfSize:14.0]
                                 constrainedToSize:CGSizeMake(210.0, 1000.0)
                                     lineBreakMode:UILineBreakModeWordWrap];
        
        height = MAX(40.0, contentSize.height + 40.0);
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] init];
    
    if (0 != section) {    
        [headerView setFrame:CGRectMake(0.0, 0.0,
                                        [UIScreen mainScreen].bounds.size.width,
                                        40.0)];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 300.0, 30.0)];
        [headerLabel setNumberOfLines:0];
        [headerLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [headerLabel setTextColor:[UIColor whiteColor]];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setTextAlignment:UITextAlignmentLeft];
        [headerView addSubview:headerLabel];
        [headerLabel release];
        
        NSString *title = [self.headerTitles objectAtIndex:section - 1];
        [headerLabel setText:title];
    }
    
    return [headerView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {    
    CGFloat height = 0.0;
    
    if (0 != section) {
        height = 40.0;
    }
    
    return height;
}

- (void)goBack:(id)sender
{
    if(self.navigationController)
    {
        if([self.navigationController.viewControllers count] > 1)
            [self.navigationController popViewControllerAnimated:YES];
        else
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}


@end
