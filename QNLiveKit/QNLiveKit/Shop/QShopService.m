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

@interface QShopService ()<QNChatRoomServiceListener>

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
        
    } else if ([imModel.action isEqualToString:liveroom_shopping_refresh]) {
        //收到商品信息刷新信令
        if ([self.delegate respondsToSelector:@selector(onGoodsRefresh)]) {
            [self.delegate onGoodsRefresh];
        }
    }
}

//获取所有商品
- (void)getGoodList:(nullable void (^)(NSArray <GoodsModel *> * _Nullable goodList))callBack {
    NSLog(@"获取所有商品");
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

//获取上架中的商品
- (void)getOnlineGoodList:(nullable void (^)(NSArray <GoodsModel *> * _Nullable goodList))callBack {
    NSLog(@"获取上架中的商品");
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
    NSLog(@"调整商品顺序");
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.roomInfo.live_id;
    params[@"item_id"] = good.item_id;
    params[@"from"] = @(fromIndex);
    params[@"to"] = @(toIndex);
    [QLiveNetworkUtil postRequestWithAction:@"client/item/order/single" params:params success:^(NSDictionary * _Nonnull responseData) {
        [self sendRefreshGoodMsg];
        if (callBack) {
            callBack();
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//讲解商品
- (void)explainGood:(GoodsModel *)model callBack:(nullable void (^)(void))callBack {
    NSLog(@"讲解商品");
    NSString *action = [NSString stringWithFormat:@"client/item/demonstrate/%@/%@",self.roomInfo.live_id,model.item_id];
    [QLiveNetworkUtil postRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        [self sendExplainGoodMsg:model];
        if (callBack) {
            callBack();
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//取消讲解商品/录制商品
- (void)endExplainAndRecordGood:(nullable void (^)(void))callBack {
    NSLog(@"取消讲解商品/录制商品");
    NSString *action = [NSString stringWithFormat:@"client/item/demonstrate/%@",self.roomInfo.live_id];
    [QLiveNetworkUtil deleteRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        [self sendExplainGoodMsg:[GoodsModel new]];
        if (callBack) {
            callBack();
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//录制商品
- (void)recordGood:(NSString *)itemID callBack:(nullable void (^)(void))callBack {
    NSLog(@"录制商品");
    NSString *action = [NSString stringWithFormat:@"client/item/demonstrate/start/%@/%@",self.roomInfo.live_id,itemID];
    [QLiveNetworkUtil postRequestWithAction:action params:@{} success:^(NSDictionary * _Nonnull responseData) {
        if (callBack) {
            callBack();
        }
        } failure:^(NSError * _Nonnull error) {
        }];
}

//查看正在讲解的商品
- (void)getExplainGood:(nullable void (^)(GoodsModel * _Nullable good))callBack {
    NSLog(@"查看正在讲解的商品");
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

//获取商品讲解回放
- (void)getGoodRecord:(NSString *)itemID callBack:(nullable void (^)(GoodsModel * _Nullable good))callBack {
    NSLog(@"获取商品讲解回放");
    NSString *action = [NSString stringWithFormat:@"client/item/demonstrate/record/%@/%@",self.roomInfo.live_id,itemID];
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

//删除商品录制回放
- (void)deleteGoodRecordIDs:(NSArray *)recordIDs callBack:(nullable void (^)(void))callBack {
    NSLog(@"删除商品录制回放");
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.roomInfo.live_id;
    params[@"demonstrate_item"] = recordIDs.mj_keyValues;
    [QLiveNetworkUtil postRequestWithAction:@"client/item/demonstrate/record/delete" params:params success:^(NSDictionary * _Nonnull responseData) {
        if (callBack) {
            callBack();
        }
        } failure:^(NSError * _Nonnull error) {
        }];
}

//获取当前直播间所有商品讲解的录制
- (void)getAllGoodRecord:(nullable void (^)(NSArray <GoodsModel *> * _Nullable goodList))callBack {
    NSLog(@"获取当前直播间所有商品讲解的录制");
    NSString *action = [NSString stringWithFormat:@"client/item/demonstrate/record/%@",self.roomInfo.live_id];
    [QLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        
        NSArray <GoodsModel *> *explainGoods = [GoodsModel mj_objectArrayWithKeyValuesArray:responseData];
        if (callBack) {
            callBack(explainGoods);
        }
    } failure:^(NSError * _Nonnull error) {
        if (callBack) {
            callBack(nil);
        }
    }];
}

//批量修改商品状态
- (void)updateGoodsStatus:(NSArray <GoodsModel *>*)goods status:(QLiveGoodsStatus)status callBack:(nullable void (^)(void))callBack {
    NSLog(@"批量修改商品状态");
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
        [self sendRefreshGoodMsg];
        if (callBack) {
            callBack();
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//移除商品
- (void)removeGoods:(NSArray <GoodsModel *>*)goods callBack:(nullable void (^)(void))callBack {
    
    NSLog(@"移除商品");
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.roomInfo.live_id;
    
    NSMutableArray *arr = [NSMutableArray array];
    for (GoodsModel *good in goods) {
        [arr addObject:good.item_id];
    }
    params[@"items"] = arr;
    [QLiveNetworkUtil postRequestWithAction:@"client/item/delete" params:params success:^(NSDictionary * _Nonnull responseData) {
        [self sendRefreshGoodMsg];
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

//发送商品列表刷新信令
-(void)sendRefreshGoodMsg {
    QNIMMessageObject *message = [self.creater  createRefreshGoodMsg];
    [[QNIMChatService sharedOption] sendMessage:message];
}

- (CreateSignalHandler *)creater {
    if (!_creater) {
        _creater = [[CreateSignalHandler alloc]initWithToId:self.roomInfo.chat_id roomId:self.roomInfo.live_id];
    }
    return _creater;
}

@end
