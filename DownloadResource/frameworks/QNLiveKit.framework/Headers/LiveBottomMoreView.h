//
//  LiveBottomMoreView.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/10/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CameraChangeBlock)(void);
typedef void (^MicrophoneBlock)(BOOL mute);
typedef void (^CameraMirrorBlock)(BOOL mute);
typedef void (^BeautyBlock)(void);
typedef void (^EffectsBlock)(void);

@interface LiveBottomMoreView : UIView

- (instancetype)initWithFrame:(CGRect)frame beauty:(BOOL)beauty;

@property (nonatomic, copy)CameraChangeBlock cameraChangeBlock;

@property (nonatomic, copy)MicrophoneBlock microphoneBlock;

@property (nonatomic, copy)CameraMirrorBlock cameraMirrorBlock;

@property (nonatomic, copy)BeautyBlock beautyBlock;

@property (nonatomic, copy)EffectsBlock effectsBlock;

@end

NS_ASSUME_NONNULL_END
