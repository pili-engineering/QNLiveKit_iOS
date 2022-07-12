//
//  QNIMMessageAttachment.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QNIMAttachmentType) {
    QNIMMessageAttactmentTypeLocation,
    QNIMMessageAttactmentTypeFile,
    QNIMMessageAttactmentTypeVoice,
    QNIMMessageAttactmentTypeImage,
    QNIMMessageAttactmentTypeVideo
};

typedef NS_ENUM(NSUInteger, QNIMAttachmentDownloadStatus) {
    QNIMAttachmentDownloadStatusDownloaing,
    QNIMAttachmentDownloadStatusSuccessed,
    QNIMAttachmentDownloadStatusFailed,     // 下载失败
    QNIMAttachmentDownloadStatusNotStart,   // 下载尚未开始
    QNIMAttachmentDownloadStatusCanceled,    /// 下载被取消

};

@interface QNIMMessageAttachment : NSObject

@property (nonatomic) CGSize size;

@property (nonatomic,copy) NSString *localPath;
@property (nonatomic,copy) NSString *thumbnailPath;
@property (nonatomic,assign)  long long thumbnailFileLength;
@property (nonatomic) CGSize thumbnailSize;
@property (nonatomic) CGSize pictureSize;
@property (nonatomic,strong) NSData *aData;
@property (nonatomic,strong) NSData *aThumbnailData;
@property (nonatomic) CGSize imageSize;
@property (nonatomic,copy) NSString *conversationId;
@property (nonatomic,copy) NSString *aDisplayName;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,assign) int duration;
/**
 文件大小
 */
@property (nonatomic,assign) long long fileLength;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
