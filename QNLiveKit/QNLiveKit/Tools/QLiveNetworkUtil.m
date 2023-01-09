//
//  QLiveNetworkUtil.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import "QLiveNetworkUtil.h"
#import "QLive.h"
//#import <YYCategories/YYCategories.h>
#import <AFNetworking/AFNetworking.h>

NSString *const ResponseErrorKey = @"com.alamofire.serialization.response.error.response";
NSInteger const Interval = 8;

@implementation QLiveNetworkUtil

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
                                                              @"text/javascript",
                                                              @"application/octet-stream",
                                                              @"text/json",
                                                              @"multipart/form-data",
                                                              @"charset=utf-8",
                                                              @"application/xml",nil];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *token = LIVE_Live_Token;
    if (token.length > 0) {
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
    }
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return manager;
}


+ (void)getRequestWithAction:(NSString *)action params:(nullable NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure {
        
    NSString *url = LIVE_Live_URL;
    if (url.length == 0) {
        url = @"https://live-api.qiniu.com/%@";
    }
    NSString *requestUrl = [[NSString alloc]initWithFormat:url,action];
    AFHTTPSessionManager *manager = [QLiveNetworkUtil manager];
    
    [manager GET:requestUrl parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"\n GET\n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,responseObject);
        [self dealSuccessResult:responseObject success:^(NSDictionary * _Nonnull responseData) {
            success(responseData);
                } failure:^(NSError * _Nonnull error) {
                    failure(error);
                }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"\n GET\n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n error = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,error);
        [self dealFailure:error failure:^(NSError * _Nonnull error) {
            failure(error);
        }];
    }];
    
    //原生网络请求实现
//    NSString *urlString = [NSString stringWithFormat:@"%@%@",LIVE_Live_URL,action];
//    if (params) {
//        NSString *paramStr = [self dealWithParam:params];
//        urlString = [urlString stringByAppendingString:paramStr];
//    }
//       //对URL中的中文进行转码
//    NSString *pathStr = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:pathStr]];
//
//    request.timeoutInterval = Interval;
//
//    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (data) {
//                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//                NSString *code = dict[@"code"];
//                NSDictionary *response = dict[@"response"];
//                success(response);
//            }else{
//                NSHTTPURLResponse *httpResponse = error.userInfo[ResponseErrorKey];
//                if (httpResponse.statusCode != 0) {
//                    NSString *ResponseStr = [self showErrorInfoWithStatusCode:httpResponse.statusCode];
//                    failure(ResponseStr);
//                } else {
//                    NSString *ErrorCode = [self showErrorInfoWithStatusCode:error.code];
//                    failure(ErrorCode);
//                }
//            }
//        });
//    }];
//
//    [task resume];
}

+ (void)postRequestWithAction:(NSString *)action params:(nullable NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    AFHTTPSessionManager *manager = [QLiveNetworkUtil manager];
    NSString *url = LIVE_Live_URL;
    if (url.length == 0) {
        url = @"https://live-api.qiniu.com/%@";
    }
    NSString *requestUrl = [[NSString alloc]initWithFormat:url,action];
    
    [manager POST:requestUrl parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"\n POST\n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,responseObject);

        [self dealSuccessResult:responseObject success:^(NSDictionary * _Nonnull responseData) {
            success(responseData);
                } failure:^(NSError * _Nonnull error) {
                    failure(error);
                }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"\n POST\n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n error = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,error);
        [self dealFailure:error failure:^(NSError * _Nonnull error) {
            failure(error);
        }];
    }];
    //原生网络请求实现
//    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",LIVE_Live_URL,action];
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
//    [request setHTTPMethod:HTTPMethod];
//    //把字典中的参数进行拼接
//    NSString *body = [self dealWithParam:params];
//    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
////    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
//    [request setHTTPBody:bodyData];
//
//    [request setValue:QNLiveToken forHTTPHeaderField:@"Authorization"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    request.timeoutInterval = Interval;
//
//    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//
//        if (data) {
//            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//
//            NSString *code = dict[@"code"];
//            NSDictionary *response = dict[@"response"];
//            success(response);
//
//            NSLog(@"\n POST \n action : %@ \nparams:%@ \n responseObject = %@",requestUrl,params,dict);
//
//        }else{
//            NSHTTPURLResponse *httpResponse = error.userInfo[ResponseErrorKey];
//            if (httpResponse.statusCode != 0) {
//                NSString *ResponseStr = [self showErrorInfoWithStatusCode:httpResponse.statusCode];
//                failure(ResponseStr);
//            } else {
//                NSString *ErrorCode = [self showErrorInfoWithStatusCode:error.code];
//                failure(ErrorCode);
//                NSLog(@"\n POST \n action : %@ \nparams:%@ \n error = %@",requestUrl,params,error);
//            }
//        }
//    }];
//    [task resume];
}

+ (void)deleteRequestWithAction:(NSString *)action params:(nullable NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    AFHTTPSessionManager *manager = [QLiveNetworkUtil manager];
    NSString *url = LIVE_Live_URL;
    if (url.length == 0) {
        url = @"https://live-api.qiniu.com/%@";
    }
    NSString *requestUrl = [[NSString alloc]initWithFormat:url,action];
    
    [manager DELETE:requestUrl parameters:params headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"\n DELETE\n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,responseObject);
        [self dealSuccessResult:responseObject success:^(NSDictionary * _Nonnull responseData) {
            success(responseData);
                } failure:^(NSError * _Nonnull error) {
                    failure(error);
                }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"\n DELETE\n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n error = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,error);
        [self dealFailure:error failure:^(NSError * _Nonnull error) {
            failure(error);
        }];
    }];
}

+ (void)putRequestWithAction:(NSString *)action params:(nullable NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    AFHTTPSessionManager *manager = [QLiveNetworkUtil manager];
    NSString *url = LIVE_Live_URL;
    if (url.length == 0) {
        url = @"https://live-api.qiniu.com/%@";
    }
    NSString *requestUrl = [[NSString alloc]initWithFormat:url,action];
    
    [manager PUT:requestUrl parameters:params headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"\n PUT\n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n responseObject = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,responseObject);
        [self dealSuccessResult:responseObject success:^(NSDictionary * _Nonnull responseData) {
            success(responseData);
                } failure:^(NSError * _Nonnull error) {
                    failure(error);
                }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"\n PUT\n action : %@ \n HTTPRequestHeaders:%@ \n params:%@ \n error = %@",requestUrl,manager.requestSerializer.HTTPRequestHeaders,params,error);
        [self dealFailure:error failure:^(NSError * _Nonnull error) {
            failure(error);
        }];
    }];
}

+ (void)dealSuccessResult:(id)responseObject success:(SuccessBlock)success failure:(FailureBlock)failure {
    if ([responseObject[@"code"] isEqualToNumber:@(499)]) {
        
        NSString *action = [NSString stringWithFormat:@"live/auth_token?userID=%@&deviceID=1111",LIVE_User_id];
        [QLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:responseData[@"accessToken"] forKey:Live_Token];
            [defaults synchronize];
            
        } failure:^(NSError * _Nonnull error) {}];
        
        return;
    }
    success(responseObject[@"data"] ?: @{});

}

+ (void)dealFailure:(NSError *)error failure:(FailureBlock)failure {
    NSData * data =error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    NSInteger resultCode = 0;
    if (data.length > 0) {
        NSError *jsonError;
        NSDictionary *liveError = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        if (!jsonError) {
            resultCode = [liveError[@"code"] intValue];
        }
    }
    if (error.code == 401 && resultCode == 499) {
        NSLog(@"toke timeout");
        [[QLive sharedInstance] refreshToken];
        
//        NSString *action = [NSString stringWithFormat:@"live/auth_token?userID=%@&deviceID=1111",LIVE_User_id];
//        [QLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
//
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setObject:responseData[@"accessToken"] forKey:Live_Token];
//            [defaults synchronize];
//            return;
//        } failure:^(NSError * _Nonnull error) {}];
    }

    failure(error);
}

+ (NSString *)showErrorInfoWithStatusCode:(NSInteger)statusCode{
    
    NSString *message = nil;
    switch (statusCode) {
        case 401: {
        
        }
            break;
            
        case 500: {
            message = @"服务器异常！";
        }
            break;
            
        case -1001: {
            message = @"网络请求超时，请稍后重试！";
        }
            break;
            
        case -1002: {
            message = @"不支持的URL！";
        }
            break;
            
        case -1003: {
            message = @"未能找到指定的服务器！";
        }
            break;
            
        case -1004: {
            message = @"服务器连接失败！";
        }
            break;
            
        case -1005: {
            message = @"连接丢失，请稍后重试！";
        }
            break;
            
        case -1009: {
            message = @"互联网连接似乎是离线！";
        }
            break;
            
        case -1012: {
            message = @"操作无法完成！";
        }
            break;
            
        default: {
            message = @"网络请求发生未知错误，请稍后再试！";
        }
            break;
    }
    return message;
    
}

#pragma mark -- 拼接参数
+ (NSString *)dealWithParam:(NSDictionary *)param
{
    NSArray *allkeys = [param allKeys];
    NSMutableString *result = [NSMutableString string];
    
    for (NSString *key in allkeys) {
        NSString *string = [NSString stringWithFormat:@"%@=%@&", key, param[key]];
        [result appendString:string];
    }
//    result = [result substringToIndex:result.length - 1];
    return result;
}

+(NSString *)JSONString:(NSString *)aString {
    NSMutableString *s = [NSMutableString stringWithString:aString];
    [s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

@end
