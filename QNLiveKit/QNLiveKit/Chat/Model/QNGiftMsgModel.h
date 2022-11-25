//
//  QNGiftMsgModel.h
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNGiftMsgModel : NSObject

//{
//    "action":"gift_notify",
//    "data": {
//        "live_id":"",
//"user_id":"", 发送礼物用户id
//"gift_id":1, 礼物类型
//
//        "amount":3 礼物金额
//    }
//}

@property(nonatomic, copy) NSString *live_id;
@property(nonatomic, copy) NSString *user_id;
@property(nonatomic, assign) NSInteger gift_id;
@property(nonatomic, assign) NSInteger amount;

@end

NS_ASSUME_NONNULL_END
