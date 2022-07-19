//
//  QNMergeOption.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MicrophoneMergeOption : NSObject

@property (nonatomic, assign)BOOL isNeed;

@end

@interface CameraMergeOption : NSObject

@property (nonatomic, assign)BOOL isNeed;

@property (nonatomic, assign)CGRect frame;

@property (nonatomic, assign)NSInteger mZ;


@property (nonatomic, assign) int mixStreamY;
//码率
@property (nonatomic, assign) int mixBitrate;
//帧率
@property (nonatomic, assign) int fps;

//图像的填充模式, 默认设置填充模式将继承 QNMergeStreamConfiguration 中数值
@property (nonatomic, assign)QNVideoFillModeType fillMode;
@end

//混流参数
@interface QNMergeOption : NSObject

@property (nonatomic, strong)CameraMergeOption *cameraMergeOption;

@property (nonatomic, strong)MicrophoneMergeOption *microphoneMergeOption;

@property (nonatomic, copy)NSString *uid;

@property (nonatomic, assign) int width;

@property (nonatomic, assign) int height;

@property (nonatomic, strong) QNTranscodingLiveStreamingImage *backgroundInfo;

@end

NS_ASSUME_NONNULL_END
