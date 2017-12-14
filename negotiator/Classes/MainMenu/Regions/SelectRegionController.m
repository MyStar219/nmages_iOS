//
//  SelectRegionController.m
//  negotiator
//
//  Created by Andrei Vig on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectRegionController.h"
#import <MagicalRecord/MagicalRecord.h>
#import <MagicalRecord/MagicalRecord+ShorthandMethods.h>
#import "LoadingView.h"
#import "RequestManager.h"
#import "RegionManager.h"
#import "Reachability.h"
#import "NetworkHandler.h"
#import "RegionsEntity+CoreDataClass.h"

@implementation SelectRegionController

@synthesize tableView       = _tableView;
@synthesize headerMessage   = _headerMessage;
@synthesize loadingView     = _loadingView;
@synthesize regionsRequest  = _regionsRequest;
@synthesize regions         = _regions;
@synthesize forceSelect     = _forceSelect;
@synthesize backButton      = _backButton;

- (id)initWithMessage:(NSString *)message forceSelect:(BOOL)forceSelect {
    self = [super init];
    if (!self) return nil;
    
    self.headerMessage = message;
    self.forceSelect = forceSelect;
    
    return self;
}

- (void)dealloc {
    self.headerMessage = nil;
    self.regionsRequest = nil;
    
    if (self.regionsRequest) {
        [self.regionsRequest clearDelegatesAndCancel];
        self.regionsRequest = nil;
    }
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];

    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:self.view.frame];
    backgroundView.image = [UIImage imageNamed:@"info_bkgd.png"];
    [self.view addSubview:backgroundView];
    [backgroundView release];
    
    CGFloat height = 460.0f;
    if([[UIScreen mainScreen]bounds].size.height == 568)
    {
        height = 510.0f;
    } else if ([[UIScreen mainScreen]bounds].size.height >= 667) {
        height = [UIScreen mainScreen].bounds.size.height;
    }
    [backgroundView setFrame:CGRectMake(backgroundView.frame.origin.x, backgroundView.frame.origin.y, backgroundView.frame.size.width, height)];
    _tableView = [[UITableView alloc] initWithFrame:
                  CGRectMake(0.0, 0.0,
                             [UIScreen mainScreen].bounds.size.width, height) 
                                              style:UITableViewStyleGrouped];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setBackgroundView:nil];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_tableView];
    [_tableView release];
    
    _loadingView = [[LoadingView alloc] initWithFrame:
                    CGRectMake(0.0, 0.0,
                               [UIScreen mainScreen].bounds.size.width,
                               460.0)
                                              message:NSLocalizedString(@"Loading regions ...", nil)
                                          messageFont:[UIFont systemFontOfSize:13.0] 
                                                style:LoadingViewTranslucent
                                       roundedCorners:NO];
    if([[UIScreen mainScreen]bounds].size.height == 568)
    {
        [_loadingView setFrame:CGRectMake(_loadingView.frame.origin.x, _loadingView.frame.origin.y, _loadingView.frame.size.width, _loadingView.frame.size.height + 90.0f)];
    }
    [self.view addSubview:_loadingView];
    [_loadingView release];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.regions = [[NSMutableArray alloc] init];
    
    
    // reguest regions
    [self requestRegions];  

    // if we have to force the users to select a region we need to hide the backbutton;
    if (self.forceSelect) {
        [self.navigationItem setHidesBackButton:YES];
    } else {
        // setup back button
        UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 30.0)];
        [homeButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        [homeButton setBackgroundImage:[UIImage imageNamed:@"home_btn.png"] forState:UIControlStateNormal];
        [homeButton setTitle:NSLocalizedString(@"  Back", nil) forState:UIControlStateNormal];
        [homeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        
        _backButton = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
        [homeButton release];
        [self.navigationItem setLeftBarButtonItem:_backButton animated:YES];
        if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0f)
        {
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                               target:nil action:nil];
            negativeSpacer.width = -11;// it was -6 in iOS 6
            [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, _backButton, nil] animated:NO];
        };
        [_backButton release];
    } 
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.regions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    RegionObject *regionObject = (RegionObject *)[self.regions objectAtIndex:indexPath.row];
    
    NSString *regionName = regionObject.regionName;
    NSString *regionId   = regionObject.regionId;
    NSString *regionImage   = regionObject.regionImagePath;
    
    RegionManager *regionManager = [RegionManager sharedInstance];
    
    if ([regionId isEqualToString:[[regionManager region] regionId]]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    [cell.textLabel setText:regionName];
    
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGSize headerSize = [self.headerMessage sizeWithFont:[UIFont boldSystemFontOfSize:14.0] 
                                       constrainedToSize:CGSizeMake(300.0, 1000.0) 
                                           lineBreakMode:UILineBreakModeWordWrap];

    UIView *headerView = [[UIView alloc] initWithFrame:
                          CGRectMake(0.0, 0.0,
                                     [UIScreen mainScreen].bounds.size.width,
                                     headerSize.height + 20.0)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, headerSize.height)];
    [headerLabel setNumberOfLines:0];
    [headerLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [headerLabel setText:self.headerMessage];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setTextAlignment:UITextAlignmentCenter];
    [headerLabel setShadowColor:[UIColor grayColor]];
    [headerLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    [headerView addSubview:headerLabel];
    [headerLabel release];
    
    return [headerView autorelease];;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGSize headerSize = [self.headerMessage sizeWithFont:[UIFont boldSystemFontOfSize:14.0] 
                                       constrainedToSize:CGSizeMake(300.0, 1000.0) 
                                           lineBreakMode:UILineBreakModeWordWrap];
    
    return headerSize.height + 20;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RegionObject *regionObject = (RegionObject *)[self.regions objectAtIndex:indexPath.row];
    
    RegionManager *regionManager = [RegionManager sharedInstance];
    [regionManager setNewRegion:regionObject];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"regionWasChanged"
                                                        object:nil];
    [self goBack:nil];
}

- (void)regionsFromDB {

    NSArray *regionsArray = [RegionsEntity MR_findAllSortedBy:@"regionName" ascending:YES];
    
    if (regionsArray.count > 0) {
        
        [self.loadingView hide];
        
        [self.regions removeAllObjects];
        
        for (RegionsEntity *region in regionsArray) {
            
            [self.regions addObject:[Utility convertRegionsFromDB:region]];
        }
        
        [self.tableView reloadData];
        
    }
}
    
- (void)requestRegions {
    
    [self regionsFromDB];
    
    if (!self.forceSelect) {
        [self.backButton setEnabled:NO];
    }
    
    self.regionsRequest = [[RequestManager sharedInstance] requestWithMethodName:@"regions/getRegions" 
                                                                      methodType:@"GET"
                                                                      parameters:[NSMutableDictionary dictionary]
                                                                        delegate:self 
                                                                          secure:NO 
                                                                  withAuthParams:NO];
    
    [self.regionsRequest setDidFinishSelector:@selector(regionsRequestDidFinish:)];
    [self.regionsRequest setDidFailSelector:@selector(regionsRequestDidFail:)];
    
    [self.regionsRequest startAsynchronous];
}

- (void)regionsRequestDidFinish:(ASIHTTPRequest *)request {
    // hide loading view
    [self.loadingView hide];
    
    if (!self.forceSelect) {
        [self.backButton setEnabled:YES];
    }
    
    NSString *responseString = [request responseString];
    if (![NSString isNilOrEmpty:responseString]) {
        id responseObject = [responseString JSONValue];
        
        NSLog(@"Regions JSON: %@", responseObject);
        
        NSArray *tempRegions = [[NSArray alloc] init];
        
        if ([responseObject respondsToSelector:@selector(objectAtIndex:)]) {
            tempRegions = [Utility parseRegionsJSON:responseObject];
        }
        
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            
            [RegionsEntity MR_truncateAllInContext:localContext];
//            [RegionsEntity MR_truncateAllInContext:[NSManagedObjectContext MR_defaultContext]];
            NSArray *regionsArray = [RegionsEntity MR_findAllSortedBy:@"regionName" ascending:NO];
            
            NSLog(@"Count: %lu", regionsArray.count);
            for (int i=0; i< tempRegions.count; i++) {
            
                RegionObject *regionObject = (RegionObject *)[tempRegions objectAtIndex:i];
                
                RegionsEntity *regions = [RegionsEntity MR_createEntityInContext:localContext];
                
                regions.regionId = regionObject.regionId;
                regions.regionName = regionObject.regionName;
                regions.regionImage = regionObject.regionImagePath;
                regions.regionImageURL = regionObject.regionImageLink;
            }
            
        }];
    }
    [self regionsFromDB];
    [self.tableView reloadData];
}

- (void)regionsRequestDidFail:(ASIHTTPRequest *)request {
    // hide loading view
    [self.loadingView hide];
    
    if (!self.forceSelect) {
        [self.backButton setEnabled:YES];
    }
    
    if (self.regions.count <= 0) {
     
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"We were unable to retrieve the regions list. Please try again later."
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert setTag:10];
        [alert show];
        [alert release];
    }
}

- (void)goBack:(id)sender
{    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == 10){
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
