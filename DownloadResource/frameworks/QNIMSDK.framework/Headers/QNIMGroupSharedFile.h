//
//  QNIMGroupSharedFile.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNIMGroupSharedFile : NSObject
@property (nonatomic) long long fileId;
@property (nonatomic) long long groupId;
@property (nonatomic) long long upLoader;
@property (nonatomic, assign) int fileSize;

@property (nonatomic, assign) long long createTime;
@property (nonatomic) long long updateTime;

@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *displayName;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *path;
@end

NS_ASSUME_NONNULL_END
