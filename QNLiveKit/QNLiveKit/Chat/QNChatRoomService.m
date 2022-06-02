//
//  QNChatRoomService.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import "QNChatRoomService.h"
#import "CreateSignalHandler.h"

@interface QNChatRoomService ()<QNIMChatServiceProtocol>

@property (nonatomic, copy) NSString *groupId;

@property(nonatomic, copy)NSString *roomId;

@property (nonatomic,strong)CreateSignalHandler *creater;

@end

@implementation QNChatRoomService

- (instancetype)initWithGroupId:(NSString *)groupId roomId:(NSString *)roomId{
    if (self = [super init]) {
        self.groupId = groupId;
        self.roomId = roomId;
        [[QNIMChatService sharedOption] addChatListener:self];
    }
    return self;
}

//添加聊天监听
- (void)addChatServiceListener:(id<QNChatRoomServiceListener>)listener{
    self.chatRoomListener = listener;
}

//移除聊天监听
- (void)removeChatServiceListener:(id<QNChatRoomServiceListener>)listener{
    self.chatRoomListener = nil;
}

//发c2c消息
- (void)sendCustomC2CMsg:(NSString *)msg memberId:(NSString *)memberId callBack:(void (^)(void))callBack{
    
}

//发群消息
- (void)sendCustomGroupMsg:(NSString *)msg callBack:(void (^)(void))callBack {

    QNIMMessageObject *message = [self.creater createChatMessage:msg];
    [[QNIMChatService sharedOption] sendMessage:message];
    
}

//踢人
- (void)kickUser:(NSString *)msg memberId:(NSString *)memberId callBack:(void (^)(void))callBack{
    
}
//禁言
- (void)muteUser:(NSString *)msg memberId:(NSString *)memberId duration:(long long)duration isMute:(BOOL)isMute callBack:(void (^)(void))callBack{
    
}
//添加管理员
- (void)addAdmin:(NSString *)memberId callBack:(void (^)(void))callBack{
    
}
//移除管理员
- (void)removeAdmin:(NSString *)msg memberId:(NSString *)memberId callBack:(void (^)(void))callBack{
    
}

- (CreateSignalHandler *)creater {
    if (!_creater) {
        _creater = [[CreateSignalHandler alloc]initWithToId:self.groupId roomId:self.roomId];
    }
    return _creater;
}

@end
