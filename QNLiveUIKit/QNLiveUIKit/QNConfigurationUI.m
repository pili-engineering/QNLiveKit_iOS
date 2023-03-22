//
//  QNConfigurationUI.m
//  QNLiveUIKit
//
//  Created by sunmu on 2023/3/17.
//

#import "QNConfigurationUI.h"
#import <MJExtension/MJExtension.h>



@interface QNUIItem : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) BOOL flag;
@end

@implementation QNUIItem

@end

@interface QNUIItemes : NSObject
@property (nonatomic,strong) NSString *appid;
@property (nonatomic,strong) NSMutableArray <QNUIItem *>*config;
@end

@implementation QNUIItemes

+ (NSDictionary *)mj_objectClassInArray{
 return @{ @"config" : @"QNUIItem"};
}

@end


@interface QNConfigurationUI ()
@property (nonatomic,strong) QNUIItemes *configUI;

@end

@implementation QNConfigurationUI
+ (QNConfigurationUI *)shardManager {
    static QNConfigurationUI * single = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        single =[[QNConfigurationUI alloc]init];
    }) ;
    return single;
}


- (instancetype)init{
    if (self == [super init]){
        // 鉴权
        NSBundle *bundel = [NSBundle bundleForClass:[self class]];
        NSString *path =  [bundel pathForResource:@"config.conf" ofType:nil];
        NSData *json = [[NSData alloc] initWithContentsOfFile:path];
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
        
        _configUI = [QNUIItemes mj_objectWithKeyValues:dict];
    }
    return  self;
}

-(BOOL)getHiddenWithName:(NSString *)name{
    BOOL hidden = YES;
    for (QNUIItem *item in _configUI.config) {
        if([item.name isEqualToString:name] && item.flag){
            return NO;
        }
    }
    return hidden;
}

@end
