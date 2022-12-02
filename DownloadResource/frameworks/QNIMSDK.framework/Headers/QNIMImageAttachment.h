//
//  QNIMImageAttachment.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import "QNIMFileAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNIMImageAttachment : QNIMFileAttachment

@property (nonatomic,assign) QNIMAttachmentDownloadStatus thumbnailDownLoadStatus;

- (instancetype)initWithData:(NSData *)aData
               thumbnailData:(NSData *)aThumbnailData
                   imageSize:(CGSize)imageSize
              conversationId:(NSString *)conversationId;

- (instancetype)initWithLocalPath:(NSString *)aLocalPath
                    thumbnailPath:(NSString *)aThumbnailPath
                             size:(CGSize)size
                      displayName:(NSString *)aDisplayName
                   conversationId:(NSString *)conversationId;
/**
 * 设置接收图片消息缩略图
 **/
- (void)setReceiveThumbnailUrl:(NSString *)url
                 thumbnailSize:(CGSize)thumbnailSize
                    fileLength:(long long)fileLength;

/**
 * 设置发送图片消息缩略图
 **/
- (void)setsendThumbnailPath:(NSString *)path;



@end

NS_ASSUME_NONNULL_END
