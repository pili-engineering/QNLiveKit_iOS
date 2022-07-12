//
//  QNIMVideoAttachment.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import "QNIMFileAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNIMVideoAttachment : QNIMFileAttachment

/**
 video大小
 */
@property (nonatomic) CGSize videoSize;

/**
 时长
 */
@property (nonatomic,assign) int duration;

/**
 缩略图路径
 */
@property (nonatomic,copy) NSString *thumbnailPath;

/**
 缩略图url
 */
@property (nonatomic,copy) NSString *thumbnailUrl;


/**
 thumbnail文件大小
 */
@property (nonatomic) long long thumbnailFileLength;

/**
 视频下载状态
 */
@property (nonatomic,assign) QNIMAttachmentDownloadStatus thumbnaildownLoadStatus;


- (instancetype)initWithData:(NSData *)aData
                    duration:(int)duration
                   videoSize:(CGSize)videoSize
                 displayName:(NSString *)displayName
              conversationId:(NSString *)conversationId;

- (instancetype)initWithData:(NSData *)aData
                    duration:(int)duration
                   videoSize:(CGSize)videoSize
                 displayName:(NSString *)displayName
               thumbnailData:(NSData *)thumbnailData
              conversationId:(NSString *)conversationId;

- (instancetype)initWithLocalPath:(NSString *)aLocalPath
                         duration:(int)duration
                             size:(CGSize)size
                      displayName:(NSString *)aDisplayName
                   conversationId:(NSString *)conversationId;

- (instancetype)initWithLocalPath:(NSString *)aLocalPath
                         duration:(int)duration
                             size:(CGSize)size
                    thumbnailPath:(NSString *)thumbnailPath
                      displayName:(NSString *)aDisplayName
                   conversationId:(NSString *)conversationId;

@end

NS_ASSUME_NONNULL_END
