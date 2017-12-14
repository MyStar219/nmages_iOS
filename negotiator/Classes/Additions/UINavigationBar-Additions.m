
#import "UINavigationBar-Additions.h"


@implementation UINavigationBar (UINavigationBar_Addtions)

-(void)drawRect:(CGRect)rect {  
    UIImage *image = [UIImage imageNamed: @"infoNavBar_bkgd.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}


@end
