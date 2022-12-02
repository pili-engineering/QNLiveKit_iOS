//
//  QNIMMessageConfig.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNIMMessageConfig : NSObject
@property (nonatomic, assign) BOOL mentionAll;
@property (nonatomic, strong) NSArray<NSString *> *mentionList;
@property (nonatomic,copy) NSString *mentionMessage;
@property (nonatomic,copy) NSString *pushMessage;
@property (nonatomic,copy) NSString *senderName;
@property (nonatomic, strong) NSArray<NSString *> *groupMemberList;

- (instancetype)initConfigWithMentionAll:(BOOL)isMentionAll;
- (void)addGroupMember:(NSString *)rosterId;
- (void)removeGroupMember:(NSString *)rosterId;
- (void)clealerGroupMemberList;
@end

NS_ASSUME_NONNULL_END
