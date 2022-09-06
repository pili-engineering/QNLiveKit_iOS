//
//  QShopService.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/21.
//

#import <QNLiveKit/QNLiveKit.h>
#import "GoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ShopServiceListener <NSObject>
@optional

//正在讲解商品更新通知
- (void)onExplainingUpdate:(GoodsModel *)good;
//商品列表更新通知
- (void)onGoodsRefresh;

@end

@interface QShopService : QNLiveService

@property (nonatomic, weak)id<ShopServiceListener> delegate;

//获取所有商品
- (void)getGoodList:(nullable void (^)(NSArray <GoodsModel *> * _Nullable goodList))callBack;

//获取上架中的商品
- (void)getOnlineGoodList:(nullable void (^)(NSArray <GoodsModel *> * _Nullable goodList))callBack;

//调整商品顺序
- (void)sortGood:(GoodsModel *)good fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex callBack:(nullable void (^)(void))callBack;

//讲解商品
- (void)explainGood:(GoodsModel *)model callBack:(nullable void (^)(void))callBack;

//录制商品
- (void)recordGood:(NSString *)itemID callBack:(nullable void (^)(void))callBack;

//获取商品讲解回放
- (void)getGoodRecord:(NSString *)itemID callBack:(nullable void (^)(GoodsModel * _Nullable good))callBack;

//获取当前直播间所有商品讲解的录制
- (void)getAllGoodRecord:(nullable void (^)(NSArray <GoodsModel *> * _Nullable goodList))callBack;

//删除商品录制回放
- (void)deleteGoodRecordIDs:(NSArray *)recordIDs callBack:(nullable void (^)(void))callBack;

//取消讲解商品
- (void)endExplainAndRecordGood:(nullable void (^)(void))callBack;

//查看正在讲解的商品
- (void)getExplainGood:(nullable void (^)(GoodsModel * _Nullable good))callBack;

//批量修改商品状态
- (void)updateGoodsStatus:(NSArray <GoodsModel *>*)goods status:(QLiveGoodsStatus)status callBack:(nullable void (^)(void))callBack;

//移除商品
- (void)removeGoods:(NSArray <GoodsModel *>*)goods callBack:(nullable void (^)(void))callBack;

@end

NS_ASSUME_NONNULL_END
