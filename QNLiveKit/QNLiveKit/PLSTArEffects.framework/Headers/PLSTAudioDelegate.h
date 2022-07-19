//
//  PLSTAudioDelegate.h
//  PLSTArEffects
//
//  Created by 李政勇 on 2020/6/28.
//  Copyright © 2020 Pili. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PLSTAudioCallback <NSObject>
@required

/*!
 @method
 @abstract 音频播放完毕的回调
 
 @param flag 是否成功标志
 @param name 音频名字
 
 @since v1.0.0
 */
- (void)didFinishPlayingWith:(BOOL)flag name:(NSString *)name;
@end

@protocol PLSTAudioDelegate <NSObject>

/*!
 @property callBack
 @brief 音频播放回调, 音频播放完毕须要调用此回调
 
 @since v1.0.0
 */
@property(nonatomic, weak) id<PLSTAudioCallback> callBack;

/*!
 @method
 @abstract 加载音频
 
 @param soundData 音频数据
 @param name 音频名称
 
 @since v1.0.0
 */
- (void)loadSound:(NSData *)soundData name:(NSString *)name;

/*!
 @method
 @abstract 播放音频
 
 @param name 音频名称
 @param iLoop 是否循环播放
 
 @since v1.0.0
 */
- (void)playSound:(NSString *)name loop:(int)iLoop;

/*!
 @method
 @abstract 暂停
 
 @param name 音频名称
 
 @since v1.0.0
 */
- (void)pauseSound:(NSString *)name;

/*!
 @method
 @abstract 恢复播放
 
 @param name 音频名称
 
 @since v1.0.0
 */
- (void)resumeSound:(NSString *)name;

/*!
 @method
 @abstract 停止播放
 
 @param name 音频名称
 
 @since v1.0.0
 */
- (void)stopSound:(NSString *)name;

/*!
 @method
 @abstract 释放音频
 
 @param name 音频名称
 
 @since v1.0.0
 */
- (void)unloadSound:(NSString *)name;
@end


/*!
 @class PLSTDefaultDelegate
 @abstract 默认音频代理实现
 */
@interface PLSTDefaultDelegate : NSObject<PLSTAudioDelegate>

@end

NS_ASSUME_NONNULL_END
