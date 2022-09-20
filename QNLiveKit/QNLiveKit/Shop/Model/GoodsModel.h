//
//  GoodsModel.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//直播房间状态
typedef NS_ENUM(NSUInteger, QLiveGoodsStatus) {
    QLiveGoodsStatusTakeDown = 0,//下架(用户不可见)
    QLiveGoodsStatusTakeOn = 1, //上架(用户可见)
    QLiveGoodsStatusForbidden = 2, //上架不能购买
    QLiveGoodsStatusTakeAll  = 3,
};

@interface GoodRecordModel : NSObject

@property(nonatomic, copy) NSString *record_url;//录制的讲解URL

@property(nonatomic, copy) NSString *live_id;//所在的直播间

@property(nonatomic, copy) NSString *item_id;//商品ID

@property(nonatomic, copy) NSString *record_id;//录制ID

@property(nonatomic, copy) NSString *start;

@property(nonatomic, copy) NSString *end;

@property(nonatomic, strong) NSNumber *status;

@end

//商品model
@interface GoodsModel : NSObject

@property(nonatomic, copy) NSString *item_id;//商品id

@property(nonatomic, copy) NSString *title;//商品标题

@property(nonatomic, copy) NSString *tags;//商品标签，多个以 ","分割。

@property(nonatomic, copy) NSString *thumbnail;//缩略图 url

@property(nonatomic, copy) NSString *link;//商品链接 url

@property(nonatomic, copy) NSString *order;//商品序号

@property(nonatomic, copy) NSString *current_price;//当前价格字符串

@property(nonatomic, copy) NSString *origin_price;//原始价格字符串

@property(nonatomic, assign) QLiveGoodsStatus status;//商品状态

@property(nonatomic, strong) NSDictionary *extends;//扩展信息

@property(nonatomic, assign) BOOL isExplaining;//商品是否正在讲解中
  
@property(nonatomic, assign) BOOL isSelected;//商品是否选中

@property(nonatomic, strong) GoodRecordModel *record;

@end

NS_ASSUME_NONNULL_END
