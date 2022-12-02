//
//  QNIMVoiceAttachment.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import "QNIMFileAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNIMVoiceAttachment : QNIMFileAttachment

/**
 时长
 */
@property (nonatomic,assign) NSInteger duration;

/**
 初始化QNIMFileAttachment

 @param path 音频路径
 @param displayName 显示
 @param duration 时长
 @return QNIMFileAttachment
 */
- (instancetype)initWithPath:(NSString *)path
                 displayName:(NSString *)displayName
                    duration:(NSInteger)duration
              conversationId:(NSString *)conversationId;


   

/// 初始化QNIMFileAttachment
/// @param aData 音频Data
/// @param displayName 显示名称
/// @param duration 时长
/// @param conversationId 会话Id
- (instancetype)initWithData:(NSData *)aData
                 displayName:(NSString *)displayName
                  fileLength:(NSInteger)fileLength
                    duration:(NSInteger)duration
              conversationId:(NSString *)conversationId;



@end

NS_ASSUME_NONNULL_END
