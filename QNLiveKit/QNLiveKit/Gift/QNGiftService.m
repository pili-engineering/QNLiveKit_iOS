//
//  QNGiftService.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import "QNGiftService.h"
#import "QLiveNetworkUtil.h"

@interface QNGiftService ()

@property (nonatomic, strong) NSDictionary<NSString*, QNGiftModel *> *models;

@property (nonatomic, strong) NSDictionary<NSString*, NSArray<QNGiftModel *> *> *typeModels;

@end

@implementation QNGiftService

+(instancetype)sharedInstance {
    static QNGiftService * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.models = [NSMutableDictionary new];
        instance.typeModels = [NSMutableDictionary new];
    });
    return instance;
}

- (void)getGiftModelsByType:(NSInteger)type complete:(void (^)(NSArray<QNGiftModel *>* giftModels))complete {
    NSString *typeKey = [NSString stringWithFormat:@"%ld", type];
    if (self.typeModels.count > 0) {
        complete([self.typeModels objectForKey:typeKey]);
        return;
    }
    
    [self fetchAllModels:^{
        complete([self.typeModels objectForKey:typeKey]);
    }];
}

- (void)getGiftModelById:(NSInteger)giftID complete:(void (^)(QNGiftModel *giftModel))complete{
    NSString *idKey = [NSString stringWithFormat:@"%ld", giftID];
    if (self.models.count > 0) {
        complete([self.models objectForKey:idKey]);
        return;
    }
    
    [self fetchAllModels:^{
        complete([self.models objectForKey:idKey]);
    }];
}

- (void)fetchAllModels:(void (^)(void))complete {
    NSString *action = @"client/gift/config/-1";
    [QLiveNetworkUtil getRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        NSArray <QNGiftModel *> *modelList = [QNGiftModel mj_objectArrayWithKeyValuesArray:responseData];
        
        NSMutableDictionary *allModelDic = [NSMutableDictionary new];
        NSMutableDictionary *typeModelDic = [NSMutableDictionary new];
        
        for (QNGiftModel *model in modelList) {
            NSString *typeKey = [NSString stringWithFormat:@"%ld", model.type];
            NSString *idKey = [NSString stringWithFormat:@"%ld", model.gift_id];
         
            [allModelDic setObject:model forKey:idKey];
            
            NSMutableArray *models = [typeModelDic objectForKey:typeKey];
            if (!models) {
                models = [NSMutableArray new];
                [typeModelDic setObject:models forKey:typeKey];
            }
            
            [models addObject:model];
        }
        
        self.models = [allModelDic copy];
        self.typeModels = [typeModelDic copy];
        
        complete();
    } failure:^(NSError * _Nonnull error) {
        complete();
    }];
}
@end
