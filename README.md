# QNLiveKit_iOS

## 互动直播低代码iOS

qlive-sdk是七牛云推出的一款互动直播低代码解决方案sdk。只需几行代码快速接入互动连麦pk直播。

## SDK下载与Demo 使用    

### 资源下载

[DownloadResource](https://github.com/pili-engineering/QNLiveKit_iOS/tree/main/DownloadResource/)

### 资源目录说明

* frameworks：相关framework
* livekitResource：低代码库使用的资源文件
* BeautyResource：美颜资源文件
* QNLiveKitDemo：demo 工程

### Demo 使用说明

* 进入QNLiveKitDemo
* 执行 pod install
* 打开 QNLiveKitDemo.xcworkspace
* 选择真机运行。



## SDK 接入

### 配置依赖 

SDK 依赖一下资源库，具体可以参考 QNLiveKitDemo/Podfile


      pod 'QNRTCKit-iOS','5.1.1'
      pod 'Bugly','2.5.91'
      pod 'PLPlayerKit', '3.4.7'
      pod 'Masonry', '1.1.0'
      pod 'MJExtension','3.4.1'
      pod 'YYCategories','1.0.4'
      pod 'YYModel','1.0.4'
      pod 'YYWebImage','1.0.4'
      pod 'SDWebImage',' 5.12.2'
      pod 'AFNetworking','4.0.1'
      pod 'IQKeyboardManager','6.5.9'
      pod 'MBProgressHUD','1.2.0'
      pod 'MJRefresh', '3.5.0'
      pod 'SocketRocket','0.6.0'




### 接入framework

* 引入系统库：在Targets->Build Phases->Link Library With Libraries中添加如下系统库：
  * AssetsLibrary.framework
  * CoreService.framework
  * MapKit.framework
* 将framework 中的库加入工程。
* 在Targets->Build Settings->Framework Search Paths中添加 framework 路径
* 在Targets->Build Phases 中，增加一个Copy Phase。添加 QNIMSDK.framework，并设置 Code Sign On
* 引入项目文件下的QNLiveKit.xcodeproj和QNLiveUIKit.xcodeproj，并在Targets->Build Phases->Link Library With Libraries中添加：
  - QNLiveKit.framework和QNLiveUIKit.framework

### 引入资源文件

* 将 livekitResource 中的资源文件，拖入项目的 Assets 中。
* 如果需要美颜，将 BeautyResource 中的资源，加入到项目中。



### 快速接入

如果您想要在您的iOS应用程序中集成一些直播功能，我们为您提供了一个名为 "QLive" 的SDK。下面是一些快速接入该SDK的示例代码：

1. 初始化SDK：在您的应用程序中初始化SDK，以便进行进一步的操作。您需要使用一个访问令牌和服务器地址来调用此方法，并可以选择提供一个错误回调函数。

```objective-c
// 初始化SDK
[QLive initWithToken:token serverURL:@"liveKit域名" errorBack:nil];
```

2. 绑定用户信息：绑定用户的头像和昵称，以便其他用户可以看到。您还可以选择传递一个扩展对象来同步自定义内容。

```objective-c
// 绑定用户信息
[QLive setUser:user.avatar nick:user.nickname extension:nil];
```

3. 美颜设置：如果您的应用程序需要内置美颜功能，您可以在初始化SDK之后调用以下方法来启用它。



4. 直播列表页：如果您想要显示一个直播列表页面，您可以创建并推入 `QLiveListController` 视图控制器。

```objective-c
// 显示直播列表页面
QLiveListController *listVc = [QLiveListController new];
[self.navigationController pushViewController:listVc animated:YES];
```

5. 观众观看页面：如果您的应用程序允许用户成为观众并查看直播流，您可以创建并呈现 `QNAudienceController` 视图控制器。请注意，您需要提供一个房间信息对象作为参数。

```objective-c
// 显示观众观看页面
QNAudienceController *vc = [QNAudienceController new];
vc.roomInfo = roomInfo;
vc.modalPresentationStyle = UIModalPresentationFullScreen;
[self presentViewController:vc animated:YES completion:nil];
```




​    

### 详细接入

#### 初始化类

```objective-c
// 房间业务管理
@interface QLive : NSObject

/// 初始化
/// @param token token
/// @param serverURL 域名
/// @param errorBack 错误回调
+ (void)initWithToken:(NSString *)token serverURL:(NSString *)serverURL errorBack:(nullable void (^)(NSError *error))errorBack;

/// 使用低代码Token 进行登录鉴权
/// @param token 低代码服务token，需要通过业务服务获取到。
/// @param complete 成功回调
/// @param failure 失败回调
+ (void)authWithToken:(NSString *)token complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure;




/// 获取当前登录用户信息
+ (QNLiveUser *)getLoginUser;

/// 设置登录用户的用户信息
/// @param avatar 头像图片URL
/// @param nick 昵称
/// @param extension 扩展信息
+ (void)setUser:(NSString *)avatar nick:(NSString *)nick extension:(NSDictionary * _Nullable)extension;

/// 设置登录用户的用户信息
/// @param userInfo 用户信息
/// @param complete 成功回调
/// @param failure 失败回调
+ (void)setUser:(QNLiveUser *)userInfo complete:(QNCompleteCallback)complete failure:(QNFailureCallback)failure;

//创建主播端
+ (QNLivePushClient *)createPusherClient;
//创建观众端
+ (QNLivePullClient *)createPlayerClient;
//获得直播场景
+ (QRooms *)getRooms;


@end
```




​    

#### 主播操作


```objective-c
@interface QNLivePushClient : QNLiveRoomClient

//直播操作
  

/// 开始直播
- (void)startLive:(NSString *)roomID callBack:(nullable void (^)(QNLiveRoomInfo *_Nullable roomInfo))callBack;
/// 停止直播
- (void)closeRoom;
// 主播暂时离开直播
- (void)leaveRoom;

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
@end
```




#### 观众操作


```objective-c
@interface QNLivePullClient : QNLiveRoomClient

/// 观众加入直播
/// @param callBack 回调
- (void)joinRoom:(NSString *)roomID callBack:(nullable void (^)(QNLiveRoomInfo *_Nullable roomInfo))callBack;
/// 离开直播
- (void)leaveRoom;

@end
```

#### 房间操作



```objective-c
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
```



#### 房间状态


```objective-c
/// 房间生命周期
@protocol QNRoomLifeCycleListener <NSObject>

@optional

/// 加入房间回调
/// @param roomInfo 房间信息
- (void)onRoomJoined:(QNLiveRoomInfo *)roomInfo;

//直播间某个属性变化
- (BOOL)onRoomExtensions:(NSString *)extension;

/// 房间被销毁
- (void)onRoomClose:(QNLiveRoomInfo *)roomInfo;

@end

@interface QNLiveRoomClient : NSObject

@property (nonatomic, weak) id <QNRoomLifeCycleListener> roomLifeCycleListener;

/// 获取房间所有用户
/// @param roomId 房间id
/// @param pageNumber 页数
/// @param pageSize 页面大小
/// @param callBack 回调用户列表
- (void)getUserList:(NSString *)roomId pageNumber:(NSInteger)pageNumber pageSize:(NSInteger)pageSize callBack:(void (^)(NSArray<QNLiveUser *> * _Nonnull))callBack;

//房间心跳
- (void)startRoomHeartBeart:(NSString *)roomId callBack:(nullable void (^)(QNLiveRoomInfo *roomInfo))callBack;

-(void)stopRoomHeartBeart;

//更新直播扩展信息
- (void)updateRoom:(NSString *)roomId extension:(NSString *)extension callBack:(void (^)(void))callBack;

//某个房间在线用户
- (void)getOnlineUser:(NSString *)roomId callBack:(void (^)(NSArray <QNLiveUser *> *list))callBack;

//使用用户ID搜索房间用户
- (void)searchUserByUserId:(NSString *)uid callBack:(void (^)(QNLiveUser *user))callBack;

//使用用户im uid 搜索用户
- (void)searchUserByIMUid:(NSString *)imUid callBack:(void (^)(QNLiveUser *user))callBack;


@end
```


​    

#### 连麦服务


```objective-c
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
```


​    

#### 连麦回调

```objective-c
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
```


​    

#### PK服务


```objective-c
@interface QPKService : QNLiveService

@property (nonatomic, weak)id<PKServiceListener> delegate;

//申请pk
- (void)applyPK:(NSString *)receiveRoomId receiveUser:(QNLiveUser *)receiveUser;
//接受PK申请
- (void)acceptPK:(QInvitationModel *)invitationModel;
//拒绝PK申请
- (void)rejectPK:(QInvitationModel *)invitationModel;
//结束pk
- (void)stopPK:(nullable void (^)(void))success failure:(nullable QNPKFailureBlock)failure;
//开始PK
- (void)startPK:(QNPKSession *)pkSession timeoutInterval:(double)timeoutInterval success:(nullable QNPKSuccessBlock)success failure:(nullable QNPKFailureBlock)failure timeout:(nullable QNPKTimeoutBlock)timeout;

@end
```

#### pk回调

```objective-c
@protocol PKServiceListener <NSObject>
@optional
//收到PK邀请
- (void)onReceivePKInvitation:(QInvitationModel *)model;
//PK邀请被拒绝
- (void)onReceivePKInvitationReject:(QInvitationModel *)model;
//PK邀请被接受
- (void)onReceivePKInvitationAccept:(QNPKSession *)pkSession;
//PK开始
- (void)onReceiveStartPKSession:(QNPKSession *)pkSession;
//pk结束
- (void)onReceiveStopPKSession:(QNPKSession *)pkSession;
//pk扩展字段有变化
//（可在model.extends中，添加自定义字段）
- (void)onReceivePKExtendsChange:(QNPKExtendsModel *)model;

@end 
```

#### 聊天/信令发送

```objective-c
@interface QNChatRoomService : QNLiveService

//添加聊天监听
- (void)addChatServiceListener:(id<QNChatRoomServiceListener>)listener;
//移除聊天监听
- (void)removeChatServiceListener;


//状态消息

//发公聊消息
- (void)sendPubChatMsg:(NSString *)msg callBack:(void (^)(QNIMMessageObject *msg))callBack;
//发进房消息
- (void)sendWelComeMsg:(void (^)(QNIMMessageObject *msg))callBack;
//发离开消息
- (void)sendLeaveMsg;
//私聊消息
- (void)sendCustomC2CMsg:(NSString *)msg memberID:(NSString *)memberID callBack:(void (^)(QNIMMessageObject *msg))callBack;
// 自定义群聊
- (void)sendCustomGroupMsg:(NSString *)msg callBack:(void (^)(QNIMMessageObject *msg))callBack;

// 踢人
- (void)kickUserMsg:(NSString *)msg memberID:(NSString *)memberID callBack:(void(^)(QNIMError *error))aCompletionBlock;

//禁言
- (void)muteUserMsg:(NSString *)msg memberId:(NSString *)memberId duration:(long long)duration isMute:(BOOL)isMute callBack:(void(^)(QNIMError *error))aCompletionBlock;

// 禁言列表
- (void)getBannedMembersCompletion:(void(^)(NSArray<QNIMGroupBannedMember *> *bannedMemberList,
                                        QNIMError *error))aCompletionBlock;

//@param-isBlock:是否拉黑    @param-memberID:成员im ID    @param-callBack:回调
- (void)blockUserMemberId:(NSString *)memberId isBlock:(BOOL)isBlock callBack:(void(^)(QNIMError *error))aCompletionBlock;

/**
 * 获取黑名单
 **/
- (void)getBlockListForceRefresh:(BOOL)forceRefresh
                     completion:(void(^)(NSArray<QNIMGroupMember *> *groupMember,QNIMError *error))aCompletionBlock;

/**
  添加管理员
 */
- (void)addAdminsWithAdmins:(NSArray<NSNumber *> *)admins
          message:(NSString *)message
                  completion:(void(^)(QNIMError *error))aCompletionBlock;

/**
  移除管理员
 */
- (void)removeAdminsWithAdmins:(NSArray<NSNumber *> *)admins
          message:(NSString *)message
                  completion:(void(^)(QNIMError *error))aCompletionBlock;
@end
```



#### 聊天/信令获取


```objective-c
@protocol QNChatRoomServiceListener <NSObject>
@optional
//有人加入聊天室
- (void)onUserJoin:(QNLiveUser *)user message:(QNIMMessageObject *)message;
//有人离开聊天室
- (void)onUserLeave:(QNLiveUser *)user message:(QNIMMessageObject *)message;
//收到公聊消息
- (void)onReceivedPuChatMsg:(PubChatModel *)msg message:(QNIMMessageObject *)message;
//收到弹幕消息
- (void)onReceivedDamaku:(PubChatModel *)msg;
//收到点赞消息
- (void)onReceivedLikeMsg:(QNIMMessageObject *)msg;
//收到礼物消息
- (void)onreceivedGiftMsg:(QNIMMessageObject *)msg;

@end

```

   

#### 购物服务

```objective-c
@interface QShopService : QNLiveService

@property (nonatomic, weak)id<ShopServiceListener> delegate;

//获取所有商品
- (void)getGoodList:(nullable void (^)(NSArray <GoodsModel *> * _Nullable goodList))callBack;

//获取上架中的商品
- (void)getOnlineGoodList:(nullable void (^)(NSArray <GoodsModel *> * _Nullable goodList))callBack;

//调整商品顺序
- (void)sortGood:(GoodsModel *)good fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex callBack:(nullable void (^)(void))callBack;

//讲解商品
- (void)explainGood:(GoodsModel *)model callBack:(nullable void (^)(void))callBack;

//录制商品
- (void)recordGood:(NSString *)itemID callBack:(nullable void (^)(void))callBack;

//获取商品讲解回放
- (void)getGoodRecord:(NSString *)itemID callBack:(nullable void (^)(GoodsModel * _Nullable good))callBack;

//获取当前直播间所有商品讲解的录制
- (void)getAllGoodRecord:(nullable void (^)(NSArray <GoodsModel *> * _Nullable goodList))callBack;

//删除商品录制回放
- (void)deleteGoodRecordIDs:(NSArray *)recordIDs callBack:(nullable void (^)(void))callBack;

//取消讲解商品
- (void)endExplainAndRecordGood:(nullable void (^)(void))callBack;

//查看正在讲解的商品
- (void)getExplainGood:(nullable void (^)(GoodsModel * _Nullable good))callBack;

//批量修改商品状态
- (void)updateGoodsStatus:(NSArray <GoodsModel *>*)goods status:(QLiveGoodsStatus)status callBack:(nullable void (^)(void))callBack;

//移除商品
- (void)removeGoods:(NSArray <GoodsModel *>*)goods callBack:(nullable void (^)(void))callBack;

@end
```



#### 购物回调

```objective-c
@protocol ShopServiceListener <NSObject>
@optional

//正在讲解商品更新通知
- (void)onExplainingUpdate:(GoodsModel *)good;
//商品列表更新通知
- (void)onGoodsRefresh;

@end
```





#### 统计信息服务

```objective-c
//统计信息服务
@interface QStatisticalService : QNLiveService

//房间数据上报
- (void)roomDataStatistical:(NSArray *)roomData;

//获取房间统计数据
- (void)getRoomData:(void (^)(NSArray <QRoomDataModel *> *model))callBack;

//上报评论互动
- (void)uploadComments;

//上报商品点击
- (void)uploadGoodClick;

@end
```



​    
