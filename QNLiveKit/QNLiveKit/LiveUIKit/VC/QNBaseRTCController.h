//
//  QNBaseRTCController.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import <UIKit/UIKit.h>
#import <QNRTCKit/QNRTCKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo,QNLivePushClient,QNLiveRoomClient,QNChatRoomService,LiveChatRoom,QNLinkMicService,QNMergeOption,QNPKService,QRenderView;

@interface QNBaseRTCController : UIViewController

@property (nonatomic, strong) QRenderView *preview;//自己画面的预览视图
@property (nonatomic, strong) UIView *renderBackgroundView;//上面只能添加视频流画面
@property (nonatomic,strong) QNLiveRoomInfo *roomInfo;
@property (nonatomic, strong) QNChatRoomService *_Nullable chatService;
@property (nonatomic, strong) LiveChatRoom *chatRoomView;
@property (nonatomic, strong) QNLinkMicService *_Nullable linkService;
@property (nonatomic, strong) QNPKService *_Nullable pkService;
@property (nonatomic, strong) QNMergeOption *option;

@end

NS_ASSUME_NONNULL_END
