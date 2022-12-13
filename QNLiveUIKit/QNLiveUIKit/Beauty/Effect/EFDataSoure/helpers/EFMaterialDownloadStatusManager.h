//
//  EFMaterialDownloadStatusManager.h
//  SenseMeEffects
//
//  Created by 马浩萌 on 2021/6/16.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EFDataSourcing.h"

typedef enum : NSUInteger {
    EFMaterialDownloadStatusNotDownload = 0,
    EFMaterialDownloadStatusDownloading,
    EFMaterialDownloadStatusDownloaded,
} EFMaterialDownloadStatus;

@interface EFMaterialDownloadStatusManager : NSObject

/// 构造方法
+(instancetype)sharedInstance;

/// 获取当前model的下载状态
/// @param model target model
-(EFMaterialDownloadStatus)efDownloadStatus:(id<EFDataSourcing>)model;

/// 开始下载
/// @param model 选中的model
/// @param processingCallBack 下载进度block
/// @param completeSuccess 下载成功block
/// @param completeFailure 下载失败block
-(void)efStartDownload:(id<EFDataSourcing>)model onProgress:(void (^)(id<EFDataSourcing> material , float fProgress , int64_t iSize))processingCallBack onSuccess:(void (^)(id<EFDataSourcing> material))completeSuccess onFailure:(void (^)(id<EFDataSourcing> material , int iErrorCode , NSString *strMessage))completeFailure;


-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end
