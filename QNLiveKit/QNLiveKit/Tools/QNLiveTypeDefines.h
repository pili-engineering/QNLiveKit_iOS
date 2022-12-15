//
//  QNLiveTypeDefines.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#ifndef QNLiveTypeDefines_h
#define QNLiveTypeDefines_h

//直播房间状态
typedef NS_ENUM(NSUInteger, QNLiveRoomStatus) {
    QNLiveRoomStatusPrepare = 0,
    QNLiveRoomStatusOn = 1,
    QNLiveRoomStatusOff = 2,
};

//主播状态
typedef NS_ENUM(NSUInteger, QNAnchorStatus) {
    QNAnchorStatusLeave = 0,//离线
    QNAnchorStatusOnline = 1,//在线
};

//房间推流状态
typedef NS_ENUM(NSUInteger, QNLinkType) {
    QNLinkTypeAudienceToMaster = 0,
    QNLinkTypeMasterToMaster = 1,
};

// 无参数成功回调
typedef void (^QNCompleteCallback)(void);

// 失败回调
typedef void (^QNFailureCallback)(NSError *_Nullable  error);


#endif /* QNLiveTypeDefines_h */
