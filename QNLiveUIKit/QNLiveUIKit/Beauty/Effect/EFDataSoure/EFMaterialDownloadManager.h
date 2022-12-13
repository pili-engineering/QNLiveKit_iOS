//
//  EFMaterialDownloadManager.h
//  Effects890Resource
//
//  Created by 马浩萌 on 2022/4/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    EFMaterialDownloading,
    EFMaterialDownloaded,
    EFMaterialNotDownload
} EFRemoteMaterialDownloadStatus;

@interface EFMaterialDownloadManager : NSObject

+(instancetype)shared;

-(void)download:(NSString *)urlString progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;
-(BOOL)isDownloading:(NSString *)urlString;
-(BOOL)isDowloaded:(NSString *)urlString;
-(NSString *)getLocalFilePath:(NSString *)urlString;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
