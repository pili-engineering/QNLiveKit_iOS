//
//  WacthRecordController.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/9/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GoodsModel,QNLiveRoomInfo;
//观看商品讲解VC
@interface WacthRecordController : UIViewController

//点击商品
@property (nonatomic, copy) void (^buyClickedBlock)(GoodsModel *itemModel);

- (instancetype)initWithModel:(GoodsModel *)model roomInfo:(QNLiveRoomInfo *)roomInfo;

@end

NS_ASSUME_NONNULL_END
