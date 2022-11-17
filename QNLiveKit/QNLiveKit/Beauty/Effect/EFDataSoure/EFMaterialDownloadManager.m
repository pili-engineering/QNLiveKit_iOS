//
//  EFMaterialDownloadManager.m
//  Effects890Resource
//
//  Created by 马浩萌 on 2022/4/28.
//

#import "EFMaterialDownloadManager.h"
#import "AFNetworking.h"

@interface EFMaterialDownloadManager ()

@property (nonatomic, strong) NSMutableDictionary *downloadingHashmap;
@property (nonatomic, strong) NSMutableDictionary *downloadedHashmap; // 下载完成需要能归档

@end

static NSString * const efMaterialDownloadManagerHashKey = @"materials_downloaded_hashmap";

@implementation EFMaterialDownloadManager

+(instancetype)shared {
    static EFMaterialDownloadManager *manager = nil;
    static dispatch_once_t downloadManagerToken;
    dispatch_once(&downloadManagerToken, ^{
        manager = [[EFMaterialDownloadManager alloc] init];
    });
    return manager;
}

-(void)download:(NSString *)urlString progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    NSString *fileName = [self _parsingFileNameFrom:urlString];
    if ([self isDowloaded:fileName]) {
        if (completionHandler) {
            completionHandler(nil, [NSURL URLWithString:[self getLocalFilePath:fileName]], nil);
        }
        return;
    }
    if ([self isDownloading:fileName]) {
        return;
    }
    
    self.downloadingHashmap[fileName] = urlString;
    NSString *filePath = [_getMatertailDirectoryPath() stringByAppendingPathComponent:fileName];
    [self download:urlString toPath:filePath progress:downloadProgressBlock completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (!error) {
            self.downloadedHashmap[fileName] = fileName;
            [self saveDownloadedHashmap];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.downloadingHashmap removeObjectForKey:fileName];
        if (completionHandler) {
            completionHandler(response, filePath, error);
        }
    }];
}

-(BOOL)isDownloading:(NSString *)urlString {
    NSString *fileName = [self _parsingFileNameFrom:urlString];
    return self.downloadingHashmap[fileName];
}

-(BOOL)isDowloaded:(NSString *)urlString {
    NSString *fileName = [self _parsingFileNameFrom:urlString];
    return self.downloadedHashmap[fileName];
}

-(void)download:(NSString *)packageUrlString toPath:(NSString *)path progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {
    NSURL *packageUrl = [NSURL URLWithString:packageUrlString];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:[NSURLRequest requestWithURL:packageUrl] progress:downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (completionHandler) {
            completionHandler(response, filePath, error);
        }
        [manager invalidateSessionCancelingTasks:YES resetSession:YES];
    }];
    [task resume];
}

-(NSString *)getLocalFilePath:(NSString *)urlString {
    NSString *fileName = [self _parsingFileNameFrom:urlString];
    if (!self.downloadedHashmap[fileName]) { return nil; }
    NSString *filePath = [_getMatertailDirectoryPath() stringByAppendingPathComponent:fileName];
    return filePath;
}

-(NSMutableDictionary *)downloadingHashmap {
    if (!_downloadingHashmap) {
        _downloadingHashmap = [NSMutableDictionary dictionary];
    }
    return _downloadingHashmap;
}

-(NSMutableDictionary *)downloadedHashmap {
    if (!_downloadedHashmap) {
        NSString *baseFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        NSDictionary *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[baseFilePath stringByAppendingPathComponent:efMaterialDownloadManagerHashKey]];
        _downloadedHashmap = [NSMutableDictionary dictionaryWithDictionary:cache];
    }
    return _downloadedHashmap;
}

-(void)saveDownloadedHashmap {
    NSString *baseFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    [NSKeyedArchiver archiveRootObject:self.downloadedHashmap.copy toFile:[baseFilePath stringByAppendingPathComponent:efMaterialDownloadManagerHashKey]];
}

static NSString * _getMatertailDirectoryPath() {
    NSString *baseFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    baseFilePath = [baseFilePath stringByAppendingPathComponent:@"materials"];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:baseFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    return baseFilePath;
}

-(NSString *)_parsingFileNameFrom:(NSString *)packageUrlString {
    NSURL *url = [NSURL URLWithString:packageUrlString];
    NSString *fileName = url.lastPathComponent;
    return fileName;
}

@end
