//
//  QNBaseRTCController.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import <UIKit/UIKit.h>
#import <QNRTCKit/QNRTCKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNBaseRTCController : UIViewController

@property (nonatomic, strong) QNGLKView *preview;//自己画面的预览视图
@property (nonatomic, strong) UIView *renderBackgroundView;//上面只能添加视频流画面

@end

NS_ASSUME_NONNULL_END
