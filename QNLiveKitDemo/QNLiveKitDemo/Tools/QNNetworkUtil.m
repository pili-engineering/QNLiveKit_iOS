//
//  QNNetworkUtil.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/13.
//

#import "QNNetworkUtil.h"
#import <YYCategories/YYCategories.h>
#import "QNLoginViewController.h"

@implementation QNNetworkUtil

+ (AFHTTPSessionManager *)manager {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:
                                                              @"application/xml",
                                                              @"text/xml",
                                                              @"text/html",
                                                              @"application/json",
                                                              @"text/plain",
                                                              @"image/jpeg",
                                                              @"image/png",
                                                              @"application/octet-stream",
                                                              @"text/json",
                                                              @"charset=utf-8",nil];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:QN_LOGIN_TOKEN_KEY];
    if (token.length > 0) {
        [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
    }
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

//    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    return manager;
}

+ (void)getRequestWithAction:(NSString *)action params:(NSDictionary *)params success:(void (^)(NSDictionary *responseData))success failure:(void (^)(NSError *error))failure {
    
    NSString *mainUrl = MAINAPI;
    if ([action containsString:@"v2/"]) {
        mainUrl = [MAINAPI stringByReplacingOccurrencesOfString:@"v1/" withString:@""];
    }
    NSString *requestUrl = [[NSString alloc]initWithFormat:mainUrl,action];
    
    AFHTTPSessionManager *manager = [QNNetworkUtil manager];
    
    [manager GET:requestUrl parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSLog(@"\n GET \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,responseObject);
        if ([responseObject[@"code"] isEqualToNumber:@(401003)]) {
            QNLoginViewController *loginVC = [[QNLoginViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [UIApplication sharedApplication].keyWindow.rootViewController = navigationController;
            return;
        }
        if ([responseObject[@"code"] isEqualToNumber:@(0)]) {
            success(responseObject[@"data"] ?: nil);
        } else {
            failure(nil);
        }
        

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"\n GET \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n error = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,error);
        failure(error);
    }];
}


+ (void)postRequestWithAction:(NSString *)action params:(NSDictionary *)params success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [QNNetworkUtil manager];

    NSString *mainUrl = MAINAPI;
    if ([action containsString:@"v2/"]) {
        mainUrl = [MAINAPI stringByReplacingOccurrencesOfString:@"v1/" withString:@""];
    }
    NSString *requestUrl = [[NSString alloc]initWithFormat:mainUrl,action];
    
    [manager POST:requestUrl parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"\n POST \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,responseObject);
        if ([responseObject[@"code"] isEqualToNumber:@(401003)]) {
            QNLoginViewController *loginVC = [[QNLoginViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [UIApplication sharedApplication].keyWindow.rootViewController = navigationController;
            return;
        }
        if ([responseObject[@"code"] isEqualToNumber:@(0)]) {
            success(responseObject[@"data"] ?: nil);
        } else {
            failure(nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"\n POST \n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n error = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,error);
        failure(error);
    }];
    
}

@end
