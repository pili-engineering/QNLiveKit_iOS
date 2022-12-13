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
//点击创建房间回调（需要自己实现跳转时实现）
@property (nonatomic, copy) void (^createRoomClickedBlock)(void);
//主播点击进房回调（需要自己实现跳转时实现）
@property (nonatomic, copy) void (^masterJoinBlock)(QNLiveRoomInfo *roomInfo);
//观众点击进房回调（需要自己实现跳转时实现）
@property (nonatomic, copy) void (^audienceJoinBlock)(QNLiveRoomInfo *roomInfo);
//主播关闭直播间回调
@property (nonatomic, copy) void (^masterCloseLiveBlock)(QNLiveRoomInfo *roomInfo);
//主播暂时离开直播间回调
@property (nonatomic, copy) void (^masterLeaveLiveBlock)(QNLiveRoomInfo *roomInfo);

@end

NS_ASSUME_NONNULL_END
