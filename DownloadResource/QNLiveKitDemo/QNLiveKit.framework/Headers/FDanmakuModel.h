//
//  FDanmakuModel.h
//  FDanmakuDemo
//
//  Created by allison on 2018/5/21.
//  Copyright © 2018年 allison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FDanmakuModelProtocol.h"

@interface FDanmakuModel : NSObject <FDanmakuModelProtocol>

@property (nonatomic,assign)NSTimeInterval beginTime;//开始时间
@property (nonatomic,assign)NSTimeInterval liveTime;//滑动时间
@property (nonatomic,copy)NSString *content;//内容
@property (nonatomic,copy)NSString *sendNick;//发送者名称
@property (nonatomic,copy)NSString *sendAvatar;//发送者头像

@end
