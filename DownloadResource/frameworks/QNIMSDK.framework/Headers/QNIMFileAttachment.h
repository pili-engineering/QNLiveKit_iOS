//
//  QNIMFileAttachment.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import "QNIMMessageAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNIMFileAttachment : QNIMMessageAttachment

/**
 本地路径
 */
@property (nonatomic,copy) NSString *path;

/**
 显示名称
 */
@property (nonatomic,copy) NSString *displayName;

/**
 文件url
 */
@property (nonatomic,copy) NSString *url;

/**
 文件大小
 */
@property (nonatomic,assign) long long fileLength;

/**
 下载状态
 */
@property (nonatomic,assign) QNIMAttachmentDownloadStatus downLoadStatus;


/**
 初始化文件QNIMFileAttachment

 @param aData 文件数据
 @param displayName 文件名称
 @param conversationId 会话id
 @return QNIMFileAttachment
 */
- (instancetype)initWithData:(NSData *)aData
                   displayName:(NSString *)displayName
              conversationId:(NSString *)conversationId;

/// 初始化文件QNIMFileAttachment
/// @param path 文件路径
/// @param displayName 文件名称
/// @param conversationId 会话id
- (instancetype)initWithPath:(NSString *)path
                 displayName:(NSString *)displayName
              conversationId:(NSString *)conversationId;



@end

NS_ASSUME_NONNULL_END
