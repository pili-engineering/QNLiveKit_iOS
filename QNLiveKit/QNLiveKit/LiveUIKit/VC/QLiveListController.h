//
//  QLiveListController.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo;

@interface QLiveListController : UIViewController
//创建房间被点击回调
@property (nonatomic, copy) void (^createRoomClickedBlock)(void);
//主播进房回调
@property (nonatomic, copy) void (^masterJoinBlock)(QNLiveRoomInfo *itemModel);
//观众进房回调
@property (nonatomic, copy) void (^audienceJoinBlock)(QNLiveRoomInfo *itemModel);

@end

NS_ASSUME_NONNULL_END
