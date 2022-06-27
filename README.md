# QNLiveKit_iOS

##互动直播低代码iOS

### qlive-sdk是七牛云推出的一款互动直播低代码解决方案sdk。只需几行代码快速接入互动连麦pk直播。


## SDK接入    
    
### 配置依赖 

    
    //  podfile文件中加入以下依赖项，如果项目中已经依赖可以忽略
        pod 'QNRTCKit-iOS','5.0.0'
        pod 'PLPlayerKit', '3.4.7'
        pod 'Masonry'
        pod 'SDWebImage'
        pod 'AFNetworking'
    
    信令依赖：将QNIMSDK拖入项目中，并在General的中选择 Embed & sign
    
### 快速接入

    
        
        //初始化SDK
        [QLive initWithToken:token];
        //绑定自己服务器的头像和昵称 extension为扩展字段，可以自定义同步的内容
        [QLive setUser:user.avatar nick:user.nickname extension:nil];
        
        
        如果需要使用内置UI，直接跳转至特定的ViewController即可
        
        跳转方式一
        
        
        //直播列表页：
        QLiveListController *listVc = [QLiveListController new];
        [self.navigationController pushViewController:listVc animated:YES];
        
        跳转方式二
        
        //创建直播页：（无参数跳转）
        QCreateLiveController *createLiveVc = [QCreateLiveController new];
        createLiveVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:createLiveVc animated:YES completion:nil];
        
        
        跳转方式三
        
        //直播进行页：（带QNLiveRoomInfo参数跳转）
        QLiveController *liveVc = [QLiveController new];
        liveVc.roomInfo = roomInfo;
        liveVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:liveVc animated:YES completion:nil];
        
        
        跳转方式四
        
        //观众观看页面：（带QNLiveRoomInfo参数跳转）
        QNAudienceController *vc = [QNAudienceController new];
        vc.roomInfo = roomInfo;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
        
    
### 详细接入

#### 初始化类
    
    
    
    /// 房间业务管理
    @interface QLive : NSObject

    // 初始化
    + (void)initWithToken:(NSString *)token;
    //绑定用户信息
    + (void)setUser:(NSString *)avatar nick:(NSString *)nick extension:(nullable NSDictionary *)extension;
    //创建主播端
    + (QNLivePushClient *)createPusherClient;
    //创建观众端
    + (QNLivePullClient *)createPlayerClient;
    //获得直播场景
    + (QRooms *)getRooms;
    //获取自己的信息
    + (void)getSelfUser:(void (^)(QNLiveUser *user))callBack;

    @end

    

#### 主播操作
    
    
    @interface QNLivePushClient : QNLiveRoomClient
    
    //直播操作
    
    /// 开始直播
    - (void)startLive:(NSString *)roomID callBack:(nullable void (^)(QNLiveRoomInfo *_Nullable roomInfo))callBack;
    /// 停止直播
    - (void)closeRoom:(NSString *)roomID;
    
    //推流操作
    
    /// 启动视频采集
    - (void)enableCamera:(nullable QNCameraParams *)cameraParams renderView:(nullable QRenderView *)renderView;
    /// 切换摄像头
    - (void)switchCamera;
    /// 是否禁止本地摄像头推流
    - (void)muteCamera:(BOOL)muted;
    /// 是否禁止本地麦克风推流
    - (void)muteMicrophone:(BOOL)muted;
    /// 设置本地音频帧回调
    - (void)setAudioFrameListener:(id<QNLocalAudioTrackDelegate>)listener;
    /// 设置本地视频帧回调
    - (void)setVideoFrameListener:(id<QNLocalVideoTrackDelegate>)listener;
    
    
    //获取混流器
    - (QMixStreamManager *)getMixStreamManager;
    

#### 混流器 QMixStreamManager

    - (instancetype)initWithPushUrl:(NSString *)publishUrl client:(QNRTCClient *)client streamID:(NSString *)streamID;
    //启动前台转推，默认实现推本地轨道
    - (void)startForwardJob;
    //停止前台推流
    - (void)stopForwardJob;
    //开始混流转推
    - (void)startMixStreamJob;
    //停止混流转推
    - (void)stopMixStreamJob;
    //设置混流参数
    - (void)setMixParams:(QNMergeOption *)params;
    //更新混流画布大小
    - (void)updateMixStreamSize:(CGSize)size;
    //设置某个音频track混流
    - (void)updateUserAudioMixStreamingWithTrackId:(NSString *)trackId;
    //设置某个视频track混流
    - (void)updateUserVideoMixStreamingWithTrackId:(NSString *)trackId option:(CameraMergeOption *)option;
    //删除某条track的混流
    - (void)removeUserVideoMixStreamingWithTrackId:(NSString *)trackId;

#### 观众操作
    
    
    @interface QNLivePullClient : QNLiveRoomClient
    
    /// 观众加入直播
    - (void)joinRoom:(NSString *)roomID callBack:(nullable void (^)(QNLiveRoomInfo *_Nullable roomInfo))callBack;
    /// 离开直播
    - (void)leaveRoom:(NSString *)roomID;
    
    //观众需要上麦
    
    // 观众上麦  参数1：推流token 参数2:用户信息（json字符串）
    [[QNLivePushClient createPushClient] joinLive:token userData:nil];
    //观众下麦
    [[QNLivePushClient createPushClient] LeaveLive];
    
    
    
#### 房间操作
    
    
    
    @interface QRooms : NSObject

    /// 创建房间
    /// @param param 创建房间参数
    /// @param callBack 回调房间信息
    - (void)createRoom:(QNCreateRoomParam *)param callBack:(nullable void (^)(QNLiveRoomInfo *roomInfo))callBack;

    /// 删除房间
    /// @param callBack 回调
    - (void)deleteRoom:(NSString *)liveId callBack:(void (^)(void))callBack;

    /// 房间列表
    /// @param pageNumber 页数
    /// @param pageSize 页面大小
    /// @param callBack 回调房间列表
    - (void)listRoom:(NSInteger)pageNumber pageSize:(NSInteger)pageSize callBack:(nullable void (^)(NSArray<QNLiveRoomInfo *> * list))callBack;

    /// 查询房间信息
    /// @param callBack 回调房间信息
    - (void)getRoomInfo:(NSString *)roomID callBack:(nullable void (^)(QNLiveRoomInfo *roomInfo))callBack;

    @end
    
    
#### 房间状态
       
    
    /// 房间生命周期
    @protocol QNRoomLifeCycleListener <NSObject>

    @optional
    /// 进入房间回调
    /// @param user 用户
    - (void)onRoomEnter:(QNLiveUser *)user;

    /// 加入房间回调
    /// @param roomInfo 房间信息
    - (void)onRoomJoined:(QNLiveRoomInfo *)roomInfo;

    //直播间某个属性变化
    - (BOOL)onRoomExtensions:(NSString *)extension;

    /// 离开回调
    - (void)onRoomLeave:(QNLiveUser *)user;

    /// 销毁回调
    - (void)onRoomClose;

    @end

    @interface QNLiveRoomClient : NSObject

    @property (nonatomic, weak) id <QNRoomLifeCycleListener> roomLifeCycleListener;

    /// 获取房间所有用户
    /// @param roomId 房间id
    /// @param pageNumber 页数
    /// @param pageSize 页面大小
    /// @param callBack 回调用户列表
    - (void)getUserList:(NSString *)roomId pageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize callBack:(void (^)(NSArray<QNLiveUser *> *   _Nonnull))callBack;

    //房间心跳
    - (void)roomHeartBeart:(NSString *)roomId;

    //更新直播扩展信息
    - (void)updateRoom:(NSString *)roomId extension:(NSString *)extension callBack:(void (^)(void))callBack;

    //某个房间在线用户
    - (void)getOnlineUser:(NSString *)roomId callBack:(void (^)(NSArray <QNLiveUser *> *list))callBack;

    //使用用户ID搜索房间用户
    - (void)searchUserByUserId:(NSString *)uid callBack:(void (^)(QNLiveUser *user))callBack;

    //使用用户im uid 搜索用户
    - (void)searchUserByIMUid:(NSString *)imUid callBack:(void (^)(QNLiveUser *user))callBack;

    

#### 连麦服务
    
    
    //连麦服务
    @interface QNLinkMicService : QNLiveService

    //初始化
    - (instancetype)initWithLiveId:(NSString *)liveId;

    //获取当前房间所有连麦用户
    - (void)getAllLinker:(void (^)(NSArray <QNMicLinker *> *list))callBack;

    //上麦
    - (void)onMic:(BOOL)mic camera:(BOOL)camera extends:(nullable NSDictionary *)extends callBack:(nullable void (^)(NSString *_Nullable rtcToken))callBack;

    //下麦
    - (void)downMicCallBack:(nullable void (^)(QNMicLinker *mic))callBack;

    //获取用户麦位状态
    - (void)getMicStatus:(NSString *)uid type:(NSString *)type callBack:(nullable void (^)(void))callBack;

    //踢人
    - (void)kickOutUser:(NSString *)uid msg:(nullable NSString *)msg callBack:(nullable void (^)(QNMicLinker * _Nullable))callBack ;

    //开关麦 type:mic/camera  flag:on/off
    - (void)updateMicStatus:(NSString *)uid type:(NSString *)type flag:(BOOL)flag callBack:(nullable void (^)(QNMicLinker *mic))callBack;

    //更新扩展字段
    - (void)updateExtension:(NSString *)extension callBack:(nullable void (^)(QNMicLinker *mic))callBack;

    @end
    
    
    
#### PK服务
    
    
    @interface QNPKService : QNLiveService

    - (instancetype)initWithRoomId:(NSString *)roomId ;

    //开始pk 
    - (void)startWithReceiverRoomId:(NSString *)receiverRoomId receiverUid:(NSString *)receiverUid extensions:(NSString *)extensions callBack:(nullable void (^)(QNPKSession *_Nullable pkSession))callBack;

    //获取pk token
    - (void)getPKToken:(NSString *)relayID callBack:(nullable void (^)(QNPKSession * _Nullable pkSession))callBack;

    //通知服务端跨房完成
    - (void)PKStartedWithRelayID:(NSString *)relayID;

    //结束pk
    - (void)stopWithRelayID:(NSString *)relayID callBack:(nullable void (^)(void))callBack;

    @end
    
    
    
#### 聊天/信令发送
    
    
    
    @interface QNChatRoomService : QNLiveService

    //初始化
    - (instancetype)initWithGroupId:(NSString *)groupId roomId:(NSString *)roomId;

    #pragma mark ----状态消息
    //发公聊消息
    - (void)sendPubChatMsg:(NSString *)msg callBack:(void (^)(QNIMMessageObject *msg))callBack;
    //发进房消息
    - (void)sendWelComeMsg:(void (^)(QNIMMessageObject *msg))callBack;
    //发离开消息
    - (void)sendLeaveMsg;
    //发上麦消息
    - (void)sendOnMicMsg;
    //发下麦消息
    - (void)sendDownMicMsg;
    //发麦克风开关消息
    - (void)sendMicrophoneMute:(BOOL)mute;
    //发视频开关消息
    - (void)sendCameraMute:(BOOL)mute;
    //踢人
    - (void)kickUser:(NSString *)msg memberId:(NSString *)memberId;
    //禁言
    - (void)muteUser:(NSString *)msg memberId:(NSString *)memberId duration:(long long)duration isMute:(BOOL)isMute;

    #pragma mark ----连麦消息
    //发送连麦申请
    - (void)sendLinkMicInvitation:(QNLiveUser *)receiveUser;
    //接受连麦申请
    - (void)sendLinkMicAccept:(QNInvitationModel *)invitationModel;
    //拒绝连麦申请
    - (void)sendLinkMicReject:(QNInvitationModel *)invitationModel;

    #pragma mark ----PK消息
    //发送PK申请
    - (void)sendPKInvitation:(NSString *)receiveRoomId receiveUser:(QNLiveUser *)receiveUser;
    //接受PK申请
    - (void)sendPKAccept:(QNInvitationModel *)invitationModel;
    //拒绝PK申请
    - (void)sendPKReject:(QNInvitationModel *)invitationModel;
    //开始pk信令 singleMsg：是否只发给对方主播
    -(void)createStartPKMessage:(QNPKSession *)pkSession singleMsg:(BOOL)singleMsg ;
    //结束pk信令
    - (void)createStopPKMessage:(QNPKSession *)pkSession;

    @end
    
    
#### 聊天/信令获取
    
    
    @protocol QNChatRoomServiceListener <NSObject>
    @optional
    //有人加入聊天室
    - (void)onUserJoin:(QNLiveUser *)user message:(QNIMMessageObject *)message;
    //有人离开聊天室
    - (void)onUserLeave:(QNLiveUser *)user message:(QNIMMessageObject *)message;
    //收到公聊消息
    - (void)onReceivedPuChatMsg:(PubChatModel *)msg message:(QNIMMessageObject *)message;
    //收到点赞消息
    - (void)onReceivedLikeMsgFrom:(QNLiveUser *)sendUser;
    //收到弹幕消息
    - (void)onReceivedDamaku:(PubChatModel *)msg;
    //有人被踢
    - (void)onUserBeKicked:(NSString *)uid msg:(NSString *)msg;
    //有人上麦
    - (void)onReceivedOnMic:(QNMicLinker *)linker;
    //有人下麦
    - (void)onReceivedDownMic:(QNMicLinker *)linker;
    //有人开关音频
    - (void)onReceivedAudioMute:(BOOL)mute user:(NSString *)uid;
    //有人开关视频
    - (void)onReceivedVideoMute:(BOOL)mute user:(NSString *)uid;
    //收到被禁音频的消息
    - (void)onReceivedAudioBeForbidden:(BOOL)forbidden user:(NSString *)uid;
    //收到被禁视频的消息
    - (void)onReceivedVideoBeForbidden:(BOOL)forbidden user:(NSString *)uid;
    //有人被禁言
    - (void)onUserBeMuted:(BOOL)isMuted memberId:(NSString *)memberId duration:(long long)duration;


    //收到连麦邀请
    - (void)onReceiveLinkInvitation:(QNInvitationModel *)model;
    //连麦邀请被接受
    - (void)onReceiveLinkInvitationAccept:(QNInvitationModel *)model;
    //连麦邀请被拒绝
    - (void)onReceiveLinkInvitationReject:(QNInvitationModel *)model;

    //收到PK邀请
    - (void)onReceivePKInvitation:(QNInvitationModel *)model;
    //PK邀请被接受
    - (void)onReceivePKInvitationAccept:(QNInvitationModel *)model;
    //PK邀请被拒绝
    - (void)onReceivePKInvitationReject:(QNInvitationModel *)model;
    //收到开始跨房PK信令
    - (void)onReceiveStartPKSession:(QNPKSession *)pkSession;
    //收到停止跨房PK信令
    - (void)onReceiveStopPKSession:(QNPKSession *)pkSession;

    @end
    
    
#### UI替换
    
    几个固定槽位均继承QLiveView类，可在外部替换。    
    
    
    //重新布置UI
    - (void)createCustomView:(UIView *)view onView:(UIView *)onView;
    
    //设置点击事件
    @property (nonatomic, copy)onClickBlock clickBlock;
    
    
        
    也可直接在源码修改样式
    
    QLiveListController //直播列表页
    QNAudienceController //观众页
    QCreateLiveController //创建直播页
    QLiveController //主播页
    
    
