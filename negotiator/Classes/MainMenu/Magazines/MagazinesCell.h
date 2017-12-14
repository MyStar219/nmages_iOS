//
//  MagazinesCell.h
//  negotiator
//
//  Created by Alexandru Chis on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Magazines.h"

@interface MagazinesCell : UITableViewCell {
    UILabel         *_nameLabel;
    UILabel         *_locationLabel;
    UILabel         *_distanceLabel;
    
    UIImageView     *_managedImage;
    
    Magazines       *_magazines;
}

@property (nonatomic, retain) UILabel           *nameLabel;
@property (nonatomic, retain) UILabel           *locationLabel;
@property (nonatomic, retain) UILabel           *distanceLabel;

@property (nonatomic, retain) UIImageView       *managedImage;

@property (nonatomic, retain) Magazines         *magazines;

- (void)updateWithMagazines:(Magazines *)magazines;

@end
