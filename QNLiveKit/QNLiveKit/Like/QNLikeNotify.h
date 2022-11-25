//
//  QNLikeNotify.h
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//"data": {
//        "live_id":"",
//"user_id":"", 点赞用户id
//
//        "count":3 点赞数
//    }


@interface QNLikeNotify : NSObject

@property (nonatomic, copy) NSString *live_id;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, assign) NSInteger count;

@end

NS_ASSUME_NONNULL_END
