//
//  QNLiveRoomInfo.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "QNLiveTypeDefines.h"
#import "QNLiveUser.h"

NS_ASSUME_NONNULL_BEGIN

@class QNLiveUser;

//房间信息model

@interface QNLiveRoomInfo : NSObject
@property (nonatomic, copy)NSString *cover_url;
@property (nonatomic, copy)NSString *live_id;
@property (nonatomic, copy)NSString *notice;
@property (nonatomic, copy)NSString *total_count;
@property (nonatomic, assign)QNAnchorStatus AnchorStatus;
@property (nonatomic, assign)QNLiveRoomStatus live_status;
@property (nonatomic, copy)NSString *title;
@property (nonatomic, strong)NSDictionary *extension;
@property (nonatomic, strong)QNLiveUser *anchor_info;
@property (nonatomic, copy)NSString *room_token;
@property (nonatomic, copy)NSString *pk_id;
@property (nonatomic, copy)NSString *online_count;
@property (nonatomic, copy)NSString *start_time;
@property (nonatomic, copy)NSString *end_time;
@property (nonatomic, copy)NSString *chat_id;
@property (nonatomic, copy)NSString *push_url;
@property (nonatomic, copy)NSString *hls_url;
@property (nonatomic, copy)NSString *rtmp_url;
@property (nonatomic, copy)NSString *flv_url;
@property (nonatomic, copy)NSString *pv;
@property (nonatomic, copy)NSString *uv;
@property (nonatomic, copy)NSString *total_mics;

@end

NS_ASSUME_NONNULL_END
