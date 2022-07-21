//
//  QShopService.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/21.
//

#import "QShopService.h"
#import "QLiveNetworkUtil.h"
#import "CreateSignalHandler.h"
#import <QNIMSDK/QNIMSDK.h>
#import "QNLiveRoomInfo.h"
#import "QIMModel.h"
#import "CreateSignalHandler.h"

@interface QShopService ()

@property (nonatomic,strong)CreateSignalHandler *creater;

@end

@implementation QShopService

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIMMessageNotification:) name:ReceiveIMMessageNotification object:nil];
    }
    return self;
}

- (void)receiveIMMessageNotification:(NSNotification *)notice {
    
    NSDictionary *dic = notice.userInfo;
    QIMModel *imModel = [QIMModel mj_objectWithKeyValues:dic.mj_keyValues];
    //收到切换讲解商品信令
    if ([imModel.action isEqualToString:liveroom_shopping_explaining]) {
      
        GoodsModel *model = [GoodsModel mj_objectWithKeyValues:imModel.data];
                    
        if ([self.delegate respondsToSelector:@selector(onExplainingUpdate:)]) {
            [self.delegate onExplainingUpdate:model];
        }
   }
}

//获取商品列表
- (void)getGoodList:(nullable void (^)(NSArray <GoodsModel *> * _Nullable goodList))callBack {
    
    NSString *action = [NSString stringWithFormat:@"client/item/%@",self.roomInfo.live_id];
    [QLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
       NSArray<GoodsModel *>*list = [GoodsModel mj_objectArrayWithKeyValuesArray:responseData];
        if (callBack) {
            callBack(list);
        }
    } failure:^(NSError * _Nonnull error) {
        if (callBack) {
            callBack(nil);
        }
    }];
}

- (void)getOnlineGoodList:(nullable void (^)(NSArray <GoodsModel *> * _Nullable goodList))callBack {
    NSString *action = [NSString stringWithFormat:@"client/item/%@",self.roomInfo.live_id];
    [QLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        NSMutableArray <GoodsModel *> *goods = [GoodsModel mj_objectArrayWithKeyValuesArray:responseData];
        //筛选上架中的商品
        NSMutableArray *resultArr = [NSMutableArray array];
        for (GoodsModel *good in goods) {
            if (good.status == QLiveGoodsStatusTakeOn) {
                [resultArr addObject:good];
            }
        }
        if (callBack) {
            callBack(resultArr);
        }
    } failure:^(NSError * _Nonnull error) {
        if (callBack) {
            callBack(nil);
        }
    }];
}

//调整商品顺序
- (void)sortGood:(GoodsModel *)good fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex callBack:(nullable void (^)(void))callBack { 
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.roomInfo.live_id;
    params[@"item_id"] = good.item_id;
    params[@"from"] = @(fromIndex);
    params[@"to"] = @(toIndex);
    [QLiveNetworkUtil postRequestWithAction:@"client/item/order/single" params:params success:^(NSDictionary * _Nonnull responseData) {
        if (callBack) {
            callBack();
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//讲解商品
- (void)explainGood:(GoodsModel *)model callBack:(nullable void (^)(void))callBack {
    NSString *action = [NSString stringWithFormat:@"client/item/demonstrate/%@/%@",self.roomInfo.live_id,model.item_id];
    [QLiveNetworkUtil postRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        [self sendExplainGoodMsg:model];
        if (callBack) {
            callBack();
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//取消讲解商品
- (void)endExplainGood:(nullable void (^)(void))callBack {
    NSString *action = [NSString stringWithFormat:@"client/item/demonstrate/%@",self.roomInfo.live_id];
    [QLiveNetworkUtil deleteRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        if (callBack) {
            callBack();
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//查看正在讲解的商品
- (void)getExplainGood:(nullable void (^)(GoodsModel * _Nullable good))callBack {
    NSString *action = [NSString stringWithFormat:@"client/item/demonstrate/%@",self.roomInfo.live_id];
    [QLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        
        GoodsModel *explainGood = [GoodsModel mj_objectWithKeyValues:responseData];
        if (callBack) {
            callBack(explainGood);
        }
    } failure:^(NSError * _Nonnull error) {
        if (callBack) {
            callBack(nil);
        }
    }];
}

//批量修改商品状态
- (void)updateGoodsStatus:(NSArray <GoodsModel *>*)goods status:(QLiveGoodsStatus)status callBack:(nullable void (^)(void))callBack {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.roomInfo.live_id;
    
    NSMutableArray *arr = [NSMutableArray array];
    for (GoodsModel *good in goods) {
        GoodsModel *model = [GoodsModel new];
        model.item_id = good.item_id;
        model.status = status;
        [arr addObject:model.mj_keyValues];
    }
    params[@"items"] = arr;
    [QLiveNetworkUtil postRequestWithAction:@"client/item/status" params:params success:^(NSDictionary * _Nonnull responseData) {
        if (callBack) {
            callBack();
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//移除商品
- (void)removeGoods:(NSArray <GoodsModel *>*)goods callBack:(nullable void (^)(void))callBack {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.roomInfo.live_id;
    
    NSMutableArray *arr = [NSMutableArray array];
    for (GoodsModel *good in goods) {
        [arr addObject:good.item_id];
    }
    params[@"items"] = arr;
    [QLiveNetworkUtil postRequestWithAction:@"client/item/delete" params:params success:^(NSDictionary * _Nonnull responseData) {
        if (callBack) {
            callBack();
        }
        } failure:^(NSError * _Nonnull error) {
            
        }];
}

//发送切换讲解商品信令
-(void)sendExplainGoodMsg:(GoodsModel *)model {
    QNIMMessageObject *message = [self.creater  createExplainGoodMsg:model];
    [[QNIMChatService sharedOption] sendMessage:message];
}

- (CreateSignalHandler *)creater {
    if (!_creater) {
        _creater = [[CreateSignalHandler alloc]initWithToId:self.roomInfo.chat_id roomId:self.roomInfo.live_id];
    }
    return _creater;
}

@end
