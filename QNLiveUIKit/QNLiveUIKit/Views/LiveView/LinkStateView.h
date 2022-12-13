//
//  LinkStateView.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/7.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QLiveView.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^MicrophoneBlock)(BOOL mute);
typedef void (^CameraBlock)(BOOL mute);

//连麦中面板槽位
@interface LinkStateView : QLiveView

@property (nonatomic, copy)MicrophoneBlock microphoneBlock;

@property (nonatomic, copy)CameraBlock cameraBlock;

@end

NS_ASSUME_NONNULL_END
