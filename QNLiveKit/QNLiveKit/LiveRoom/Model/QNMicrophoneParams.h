//
//  QNMicrophoneParams.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//麦克风采集参数
@interface QNMicrophoneParams : NSObject

@property (nonatomic, assign)NSInteger mSampleRate;

@property (nonatomic, assign)NSInteger mBitsPerSample;

@property (nonatomic, assign)NSInteger mChannelCount;

@property (nonatomic, assign) CGFloat volume;

@property (nonatomic, assign)NSInteger mBitrate;

@property (nonatomic, assign) BOOL isMaster;

@property (nonatomic, copy) NSString *tag;

@end

NS_ASSUME_NONNULL_END
