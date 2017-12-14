//
//  RegionObject.h
//  negotiator
//
//  Created by aplome on 24/07/2017.
//
//

#import <Foundation/Foundation.h>

@interface RegionObject : NSObject {
    
    NSString    *_regionId;
    NSString    *_regionName;
    NSString    *_regionImagePath;
    NSString    *_regionImageLink;
}

@property(nonatomic, copy) NSString *regionId;
@property(nonatomic, copy) NSString *regionName;
@property(nonatomic, copy) NSString *regionImagePath;
@property(nonatomic, copy) NSString *regionImageLink;
    
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSURL *)regionImageURL;
    
@end
