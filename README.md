# QNLiveKit_iOS

##互动直播低代码iOS

### qlive-sdk是七牛云推出的一款互动直播低代码解决方案sdk。只需几行代码快速接入互动连麦pk直播。


## SDK接入

### SDK下载地址
    
    
### podfile配置依赖 

    ```
        pod 'QNRTCKit-iOS','5.0.0'
        pod 'PLPlayerKit', '3.4.7'
        pod 'Masonry', '1.1.0'
        pod 'SDWebImage',' 5.12.2'
        pod 'AFNetworking','4.0.1'
    ```
    
### 代码接入

    
    ```
        //初始化SDK
        [QLive initWithToken:token];
        //绑定自己服务器的头像和昵称
        [QLive setUser:user.avatar nick:user.nickname extension:nil];
        
      
        如果需要使用内置UI，直接跳转至特定的ViewController即可
        
        跳转方式一
        
        ```
        //直播列表页：
        QLiveListController *listVc = [QLiveListController new];
        [self.navigationController pushViewController:listVc animated:YES];
        ```
        跳转方式二
        ```
        //创建直播页：（无参数跳转）
        QCreateLiveController *createLiveVc = [QCreateLiveController new];
        createLiveVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:createLiveVc animated:YES completion:nil];
        ```
        
        跳转方式三
        ```
        //直播进行页：（带QNLiveRoomInfo参数跳转）
        QLiveController *liveVc = [QLiveController new];
        liveVc.roomInfo = roomInfo;
        liveVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:liveVc animated:YES completion:nil];
        ```
    

