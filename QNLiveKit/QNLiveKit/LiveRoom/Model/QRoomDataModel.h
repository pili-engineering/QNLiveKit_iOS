//
//  QRoomDataModel.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/9/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//房间推流状态
typedef NS_ENUM(NSUInteger, QRoomDataType) {
    QRoomDataTypeWatch =  1,//浏览直播间
    QRoomDataTypeGoodClick = 2,//商品点击
    QRoomDataTypeComment = 3,//评论
    QRoomDataTypePK = 4,//  pk
    QRoomDataTypeLink = 5,//观众连麦
};

@interface QRoomDataModel : NSObject

@property (nonatomic, copy) NSString *live_id;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *biz_id;
@property (nonatomic, assign) QRoomDataType type;
@property (nonatomic, assign) NSInteger count;

@property (nonatomic, copy) NSString *type_description;
@property (nonatomic, strong) NSNumber *page_view;//点击/浏览次数
@property (nonatomic, strong) NSNumber *unique_visitor;//人数

@end

NS_ASSUME_NONNULL_END
