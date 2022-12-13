//
//  EFResource.m
//  Effects890Resource
//
//  Created by 马浩萌 on 2022/4/21.
//

#import "EFResource.h"
#import "NSString+materialAes.h"
#import "NSDictionary+sortedJson.h"
#import "NSString+sha1.h"
#import "AFNetworking.h"

//static NSString *const efAppId = @"e22024c218fd48638ca9d85514c36e66";
//static NSString *const efAppKey = @"c930320e4806494a817e5bb80278defc";

static NSString *const efAppId = @"d08472433715451c8544f5168181d559";
static NSString *const efAppKey = @"2e0b08686c234d598b47fe037796b8d6";

static NSString *const AES_IV_PARAMETER = @"5e8y6w45ju8w9jq8";

static NSString *const efBaseUrl = @"http://sensemarsplatform.softsugar.com";

static NSString *const efSdkAuthPath = @"/access/studio/v1/sdkAuth";
static NSString *const efMaterialsListPath = @"/api/studio/v1/materials/list";

static NSString * currentTimeStamp() {
    return [NSString stringWithFormat:@"%0.f", [[NSDate date] timeIntervalSince1970]];
}

@interface EFResource ()

@end

@implementation EFResource
static NSString *token;
static NSString *sdkKey;

+(void)requestMaterialByGroupID:(NSNumber *)groupID success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    if (!token || !sdkKey) {
        [self requestAuthSuccess:^(NSURLSessionDataTask *task, id  _Nullable responseObject) {
            NSString *tokenEncodedValue = responseObject[@"data"][@"data"];
            NSData *sdkKeyData = [tokenEncodedValue aes_decryptDataBy:efAppKey andIv:AES_IV_PARAMETER];
            NSError *error;
            NSDictionary *sdkKeyDict = [NSJSONSerialization JSONObjectWithData:sdkKeyData options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                NSLog(@"%@", error.localizedDescription);
                if (failure) {
                    failure(task, error);
                }
            } else {
                sdkKey = sdkKeyDict[@"sdkKey"];
            }
            token = responseObject[@"data"][@"token"];
            if (!token || !sdkKey) {
                failure(task, nil);
            } else {
                [self _requestMaterialByGroupID:groupID success:success failure:failure];
            }
        } failure:failure];
    } else {
        [self _requestMaterialByGroupID:groupID success:success failure:failure];
    }
}

+(void)_requestMaterialByGroupID:(NSNumber *)groupID success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    NSDictionary *data = @{
        @"effectsListId": groupID
    };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *parameters = @{
        @"appId": efAppId,
        @"timestamp": currentTimeStamp(),
        @"sdkVersion": @"xxx",
        @"appVersion": @"xxx",
        @"uuid": @"xxx",
        @"data": [jsonString aes_encryptStringBy:efAppKey andIv:AES_IV_PARAMETER]
    };
    parameters = [self generateSignByParameter:parameters andKey:sdkKey];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    
    [manager POST:[efBaseUrl stringByAppendingPathComponent:efMaterialsListPath]  parameters:parameters headers:nil constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(task, responseObject);
        }
        [manager invalidateSessionCancelingTasks:YES resetSession:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
        [manager invalidateSessionCancelingTasks:YES resetSession:YES];
    }];
}

+(void)requestAuthSuccess:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    NSDictionary *parameters = @{
        @"appId": efAppId,
        @"timestamp": @"1651135307220",
        @"sdkVersion": @"300",
        @"appVersion": @"3.1.3",
        @"uuid": @"0A8E90DD-4188-47D0-B041-F9BB364F6621",
    };
    
    parameters = [self generateSignByParameter:parameters andKey:efAppKey];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:[efBaseUrl stringByAppendingPathComponent:efSdkAuthPath] parameters:parameters headers:nil constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(task, responseObject);
        }
        [manager invalidateSessionCancelingTasks:YES resetSession:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
        [manager invalidateSessionCancelingTasks:YES resetSession:YES];
    }];
}

+(NSDictionary *)generateSignByParameter:(NSDictionary *)orginalParam andKey:(NSString *)key {
    NSMutableDictionary *result = [orginalParam mutableCopy];
    NSString *sign = [[orginalParam sortedJsonString] stringByAppendingString:key];
    result[@"sign"] = sign.sha1String;
    return [result copy];
}

@end
