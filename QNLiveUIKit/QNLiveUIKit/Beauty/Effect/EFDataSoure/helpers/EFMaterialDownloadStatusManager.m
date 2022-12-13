//
//  EFMaterialDownloadStatusManager.m
//  SenseMeEffects
//
//  Created by 马浩萌 on 2021/6/16.
//  Copyright © 2021 SenseTime. All rights reserved.
//

#import "EFMaterialDownloadStatusManager.h"
#import "EFMaterialDownloadManager.h"

@interface EFMaterialDownloadStatusManager ()

@end

static NSString * efCachePath;

@implementation EFMaterialDownloadStatusManager

+(instancetype)sharedInstance {
    static EFMaterialDownloadStatusManager * _sharedDownloadStatusManager = nil;
    static dispatch_once_t materialDownloadStatusManagerOnceToken;
    dispatch_once(&materialDownloadStatusManagerOnceToken, ^{
        if (!_sharedDownloadStatusManager) _sharedDownloadStatusManager = [[self alloc] init];
    });
    return _sharedDownloadStatusManager;
}

# pragma mark - public
/// 获取当前model的下载状态
/// @param model target model
-(EFMaterialDownloadStatus)efDownloadStatus:(id<EFDataSourcing>)model {
    if (model.efMaterialPath) {
        return EFMaterialDownloadStatusDownloaded;
    }
    if (model.efSubDataSources && model.efSubDataSources.count > 0) {
        return EFMaterialDownloadStatusDownloaded;
    }
    if (model.efType >> 5 > 100 && (model.efType >> 5 < 400 || model.efType >> 5 >= 500)) {
        return EFMaterialDownloadStatusDownloaded;
    }
    NSString *strMaterialURL = model.strMaterialURL;
    EFMaterialDownloadManager *manager = [EFMaterialDownloadManager shared];
    if ([manager isDowloaded:strMaterialURL] || model.efIsLocal || model.efFromBundle) {
        if (!model.efMaterialPath) {
            model.efMaterialPath = [manager getLocalFilePath:model.strMaterialURL];
        }
        return EFMaterialDownloadStatusDownloaded;
    } else if ([manager isDownloading:strMaterialURL]) {
        return EFMaterialDownloadStatusDownloading;
    } else {
        return EFMaterialDownloadStatusNotDownload;
    }
}

/// 开始下载
/// @param model 选中的model
/// @param processingCallBack 下载进度block
/// @param completeSuccess 下载成功block
/// @param completeFailure 下载失败block
-(void)efStartDownload:(id<EFDataSourcing>)model onProgress:(void (^)(id<EFDataSourcing> material , float fProgress , int64_t iSize))processingCallBack onSuccess:(void (^)(id<EFDataSourcing> material))completeSuccess onFailure:(void (^)(id<EFDataSourcing> material , int iErrorCode , NSString *strMessage))completeFailure {
    NSString *strMaterialURL = model.strMaterialURL;
    EFMaterialDownloadManager *manager = [EFMaterialDownloadManager shared];
    [manager download:strMaterialURL progress:^(NSProgress * _Nonnull downloadProgress) {
        if (processingCallBack) {
            processingCallBack(model, downloadProgress.completedUnitCount / downloadProgress.totalUnitCount, downloadProgress.completedUnitCount);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
        if (error) {
            if (completeFailure) {
                completeFailure(model, (int)error.code, error.localizedDescription);
            }
        } else {
            model.efMaterialPath = filePath.path;
            if (completeSuccess) {
                completeSuccess(model);
            }
        }
    }];
}

/// 由数据源model置换出已下载素材model （如果没有下载成功则返回原model）
/// @param orginModel 数据源model
-(id<EFDataSourcing>)efDisplacesWith:(id<EFDataSourcing>)orginModel {
    EFMaterialDownloadManager *manager = [EFMaterialDownloadManager shared];
    orginModel.efMaterialPath = [manager getLocalFilePath:orginModel.strMaterialURL];
    return orginModel;
}

@end
