//
//  QNCreateRoomParam.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//创建房间参数

@interface QNCreateRoomParam : NSObject

@property (nonatomic, copy)NSString *title;
//公告
@property (nonatomic, copy)NSString *notice;
//封面图片
@property (nonatomic, copy)NSString *cover_url;
@property (nonatomic, strong)NSDictionary *extension;
@property (nonatomic, copy)NSString *start_at;

@end

NS_ASSUME_NONNULL_END
