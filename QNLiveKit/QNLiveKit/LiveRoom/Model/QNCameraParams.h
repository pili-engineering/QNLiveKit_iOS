//
//  QNCameraParams.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNCameraParams : NSObject

@property (nonatomic, assign)NSInteger width;

@property (nonatomic, assign)NSInteger height;
//帧率
@property (nonatomic, assign)NSInteger fps;
//码率
@property (nonatomic, assign)NSInteger bitrate;

@end

NS_ASSUME_NONNULL_END
