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

@property (nonatomic, assign)NSInteger mX;

@property (nonatomic, assign)NSInteger mY;

@property (nonatomic, assign)NSInteger mZ;

@property (nonatomic, assign)NSInteger mWidth;

@property (nonatomic, assign)NSInteger mHeight;

//图像的填充模式, 默认设置填充模式将继承 QNMergeStreamConfiguration 中数值
@property (nonatomic, assign)QNVideoFillModeType fillMode;
@end

@interface QNMergeOption : NSObject

@property (nonatomic, strong)CameraMergeOption *cameraMergeOption;

@property (nonatomic, strong)MicrophoneMergeOption *microphoneMergeOption;

@property (nonatomic, copy)NSString *uid;

@property (nonatomic, strong) QNTranscodingLiveStreamingImage *backgroundInfo;

@end

NS_ASSUME_NONNULL_END
