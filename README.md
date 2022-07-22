# QNLiveKit_iOS

##互动直播低代码iOS

### qlive-sdk是七牛云推出的一款互动直播低代码解决方案sdk。只需几行代码快速接入互动连麦pk直播。


## SDK接入    

    下载路径：https://github.com/pili-engineering/QNLiveKit_iOS/tree/main/DownloadResource/
    
    
### 配置依赖 

    
    //  podfile文件中加入以下依赖项，如果项目中已经依赖可以忽略
        pod 'QNRTCKit-iOS','5.0.0'
        pod 'PLPlayerKit', '3.4.7'
        pod 'Masonry'
        pod 'MJExtension'
        pod 'SDWebImage'
        pod 'AFNetworking'
    
    信令依赖：将QNIMSDK拖入项目中，并在General的中选择 Embed & sign。
    图片资源：将livekitResource文件拖入项目的Assets中。
    系统库依赖：在Targets->Build Phases->Link Library With Libraries中添加AssetsLibrary.frameWork系统库。
    美颜依赖：1、将BeautyResource拖入项目中，
            2、在Targets->Build Settings->Framework Search Paths中添加BeautyResource路径
            3、Targets->Build Settings->Header Search Paths中添加BeautyResource/PLSTArEffects.framework/Headers路径
            4、请求美颜证书SENSEME.lic并放入项目（不使用美颜功能可不放）
    
    
### 快速接入

    
        
        //初始化SDK  errorBack错误回调，可在此处更新过期的token
        [QLive initWithToken:token serverURL:@"liveKit域名" errorBack:nil];
        //绑定自己服务器的头像和昵称 extension为扩展字段，可以自定义同步的内容
        [QLive setUser:user.avatar nick:user.nickname extension:nil];
        
        
        如果需要使用内置UI，直接跳转至特定的ViewController即可
        
        跳转方式一
        
        
        //直播列表页：
        QLiveListController *listVc = [QLiveListController new];
        [self.navigationController pushViewController:listVc animated:YES];
        
        跳转方式二
        
        //创建直播页：
        QCreateLiveController *createLiveVc = [QCreateLiveController new];
        createLiveVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:createLiveVc animated:YES completion:nil];
        
       //创建直播页：（需要美颜）
        CreateBeautyLiveController *createLiveVc = [CreateBeautyLiveController new];
        createLiveVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:createLiveVc animated:YES completion:nil];
        
        跳转方式三
        
        //直播进行页（不带美颜）：
        QLiveController *liveVc = [QLiveController new];
        liveVc.roomInfo = roomInfo;
        liveVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:liveVc animated:YES completion:nil];
        
        //直播进行页（带美颜）
        BeautyLiveViewController *liveVc = [BeautyLiveViewController new];
        liveVc.roomInfo = roomInfo;
        liveVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:liveVc animated:YES completion:nil];
        
        跳转方式四
        
        //观众观看页面：
        QNAudienceController *vc = [QNAudienceController new];
        vc.roomInfo = roomInfo;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
        
    
### 详细接入

#### 初始化类
    
    
    
    /// 房间业务管理
    @interface QLive : NSObject

    // 初始化
    + (void)initWithToken:(NSString *)token serverURL:(NSString *)serverURL errorBack:(nullable void (^)(NSError *error))errorBack;
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
    - (void)closeRoom;
    
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

#### 观众操作
    
    
    @interface QNLivePullClient : QNLiveRoomClient
    
    /// 观众加入直播
    - (void)joinRoom:(NSString *)roomID callBack:(nullable void (^)(QNLiveRoomInfo *_Nullable roomInfo))callBack;
    /// 离开直播
    - (void)leaveRoom;
    
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

    @property (nonatomic, weak)id<MicLinkerListener> micLinkerListener;

    //获取当前房间所有连麦用户
    - (void)getAllLinker:(void (^)(NSArray <QNMicLinker *> *list))callBack;

    //上麦
    - (void)onMic:(BOOL)mic camera:(BOOL)camera extends:(nullable NSDictionary *)extends;

    //下麦
    - (void)downMic;

    //踢人
    - (void)kickOutUser:(NSString *)uid msg:(nullable NSString *)msg callBack:(nullable void (^)(QNMicLinker * _Nullable))callBack ;

    //开关麦 type:mic/camera  flag:on/off
    - (void)updateMicStatusType:(NSString *)type flag:(BOOL)flag;

    //申请连麦
    - (void)ApplyLink:(QNLiveUser *)receiveUser;

    //接受连麦
    - (void)AcceptLink:(QInvitationModel *)invitationModel;

    //拒绝连麦
    - (void)RejectLink:(QInvitationModel *)invitationModel;
    @end
    
    
#### 连麦回调

        /// 有人上麦
    - (void)onUserJoinLink:(QNMicLinker *)micLinker;

    /// 有人下麦
    - (void)onUserLeave:(QNMicLinker *)micLinker;

    /// 有人麦克风变化
    - (void)onUserMicrophoneStatusChange:(NSString *)uid mute:(BOOL)mute;

    /// 有人摄像头状态变化
    - (void)onUserCameraStatusChange:(NSString *)uid mute:(BOOL)mute;

    /// 有人被踢
    - (void)onUserBeKick:(LinkOptionModel *)micLinker;

    //收到连麦邀请
    - (void)onReceiveLinkInvitation:(QInvitationModel *)model;

    //连麦邀请被接受
    - (void)onReceiveLinkInvitationAccept:(QInvitationModel *)model;

    //连麦邀请被拒绝
    - (void)onReceiveLinkInvitationReject:(QInvitationModel *)model;
    
    
#### PK服务
    
    
    @interface QNPKService : QNLiveService

    @property (nonatomic, weak)id<PKServiceListener> delegate;

    //申请pk
    - (void)applyPK:(NSString *)receiveRoomId receiveUser:(QNLiveUser *)receiveUser;

    //接受PK申请
    - (void)AcceptPK:(QInvitationModel *)invitationModel;

    //拒绝PK申请
    - (void)sendPKReject:(QInvitationModel *)invitationModel;

    //结束pk
    - (void)stopPK:(nullable void (^)(void))callBack;
    @end
    
#### pk回调

    //收到PK邀请
    - (void)onReceivePKInvitation:(QInvitationModel *)model;
    //PK邀请被接受
    - (void)onReceivePKInvitationAccept:(QNPKSession *)model;
    //PK邀请被拒绝
    - (void)onReceivePKInvitationReject:(QInvitationModel *)model;
    //PK开始
    - (void)onReceiveStartPKSession:(QNPKSession *)pkSession;
    //pk结束
    - (void)onReceiveStopPKSession:(QNPKSession *)pkSession;    
    
#### 聊天/信令发送
    
    
    
    @interface QNChatRoomService : QNLiveService

    //添加聊天监听
    - (void)addChatServiceListener:(id<QNChatRoomServiceListener>)listener;
    //移除聊天监听
    - (void)removeChatServiceListener;

    //发公聊消息
    - (void)sendPubChatMsg:(NSString *)msg callBack:(void (^)(QNIMMessageObject *msg))callBack;
    //发进房消息
    - (void)sendWelComeMsg:(void (^)(QNIMMessageObject *msg))callBack;
    //发离开消息
    - (void)sendLeaveMsg;

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
    
    
