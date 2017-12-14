//
//  MagazinesCell.m
//  negotiator
//
//  Created by Alexandru Chis on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MagazinesCell.h"
#import "AppDelegate.h"

@implementation MagazinesCell

@synthesize nameLabel       = _nameLabel;
@synthesize locationLabel   = _locationLabel;
@synthesize distanceLabel   = _distanceLabel;
@synthesize managedImage    = _managedImage;
@synthesize magazines       = _magazines;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    
    _managedImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 92.0, 92.0)];
    [_managedImage setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_managedImage];
    [_managedImage release];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 4.0, 200.0, 40.0)];
    [_nameLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [_nameLabel setBackgroundColor:[UIColor clearColor]];
    [_nameLabel setNumberOfLines:2];
    [self addSubview:_nameLabel];
    [_nameLabel release];
    
    _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 48.0, 200.0, 20.0)];
    [_locationLabel setFont:[UIFont systemFontOfSize:14.0]];
    [_locationLabel setTextColor:[UIColor blackColor]];
    [_locationLabel setBackgroundColor:[UIColor clearColor]];
    [_locationLabel setNumberOfLines:1];
    [self addSubview:_locationLabel];
    [_locationLabel release];
    
    _distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 72.0, 200.0, 15.0)];
    [_distanceLabel setTextAlignment:UITextAlignmentLeft];
    [_distanceLabel setBackgroundColor:[UIColor clearColor]];
    [_distanceLabel setFont:[UIFont systemFontOfSize:12.0]];
    [_distanceLabel setTextColor:[UIColor grayColor]];
    [self addSubview:_distanceLabel];
    [_distanceLabel release];
    
    
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc {

    [super dealloc];
}

- (void)updateWithMagazines:(Magazines *)magazines{
    
    [self.managedImage setImage:nil];
    self.magazines = magazines;
    
    [_nameLabel setText:self.magazines.name];
    [_locationLabel setText:self.magazines.photoPerson];

    if ([self.magazines distance] > 0) {
        [_distanceLabel setText:[self.magazines formattedDistance]];
    } else {
        [_distanceLabel setText:@""];
    }
    if ([NSString isNilOrEmpty: self.magazines.address1] &&
        [NSString isNilOrEmpty: self.magazines.address2]) {
        [_distanceLabel setHidden:YES];
    }

    NSString *imagePath = nil;

    if (!self.magazines.imageLoaded || (nil == self.magazines.image)){
        if ([NSString isNilOrEmpty:self.magazines.thumbImageURL ]) {
            [self.managedImage setImage:[UIImage imageNamed:@"no_image.png"]];
            return;
        } else {
            
            imagePath = self.magazines.thumbImageURL;
        }
    } else {
        
        if (self.magazines.image != nil){
            [self.managedImage setImage:self.magazines.image];
        } else {
            [self.managedImage setImage:[UIImage imageNamed:@"no_image.png"]];
        }
    }
    
    if (imagePath != nil) {
     
        [self.managedImage setImageWithURL:[NSURL URLWithString: imagePath] placeholderImage:[UIImage imageNamed:@"no_image.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
}

@end
