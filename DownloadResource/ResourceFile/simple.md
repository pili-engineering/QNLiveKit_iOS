# QNLiveKit_iOS

    
### 快速接入    
        
        #import <QNLiveKit/QNLiveKit.h>
        
        [QLive initWithToken:token serverURL:liveKitURL errorBack:errorBack];
        [QLive setUser:avatar nick:nickname extension:extension];
            
        QLiveListController *listVc = [QLiveListController new];
        [self.navigationController pushViewController:listVc animated:YES];