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

//房间推流状态
typedef NS_ENUM(NSUInteger, QNLinkType) {
    QNLinkTypeAudienceToMaster = 0,
    QNLinkTypeMasterToMaster = 1,
};

#endif /* QNLiveTypeDefines_h */
