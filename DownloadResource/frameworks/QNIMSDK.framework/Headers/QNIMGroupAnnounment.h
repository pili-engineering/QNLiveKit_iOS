//
//  QNIMGroupAnnounment.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNIMGroupAnnounment : NSObject
@property (nonatomic,assign) long long groupId;
@property (nonatomic,copy) NSString *tittle;
@property (nonatomic,assign) long long author;
@property (nonatomic,assign) long long createTime;
@property (nonatomic,copy) NSString *content;
@end

NS_ASSUME_NONNULL_END
