//
//  QNMicrophoneParams.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNMicrophoneParams : NSObject

@property (nonatomic, assign)NSInteger mSampleRate;

@property (nonatomic, assign)NSInteger mBitsPerSample;

@property (nonatomic, assign)NSInteger mChannelCount;

@property (nonatomic, assign)NSInteger mBitrate;

@end

NS_ASSUME_NONNULL_END
