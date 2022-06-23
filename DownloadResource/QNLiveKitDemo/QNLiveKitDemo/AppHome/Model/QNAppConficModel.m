//
//  QNAppConficModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/20.
//

#import "QNAppConficModel.h"
#import "QNNetworkUtil.h"
@implementation QNAppConficModel


//更新版本
- (void)updateAppVersion {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    params[@"version"] = version;
    params[@"msg"] = @"更新";
    params[@"packagePage"] = @"http://fir.qnsdk.com/9l5z";
    params[@"arch"] = @"ios";
    
    [QNNetworkUtil postRequestWithAction:@"v2/app/updates" params:params success:^(NSDictionary *responseData) {
            
        } failure:^(NSError *error) {
            
        }];
}

//获取最新版本
+ (void)getAppVersion:(void (^)(NSURL *packagePage))complete {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    params[@"version"] = version;
    params[@"arch"] = @"ios";
    
    [QNNetworkUtil getRequestWithAction:@"v2/app/updates" params:params success:^(NSDictionary *responseData) {
        
        //当前版本号是否为最新
        BOOL isNew = [[QNAppConficModel new] compareVersion:responseData[@"version"]];
        
        if (isNew) {
            //上传当前版本
            [[QNAppConficModel new] updateAppVersion];
            
        } else {
            //返回最新的下载地址
            NSURL *url = [NSURL URLWithString:responseData[@"packagePage"]];
            complete(url);
        }
        
        } failure:^(NSError *error) {
            
            [[QNAppConficModel new] updateAppVersion];
        }];
}

//比较版本号(返回当前版本号是否是最新)

- (BOOL)compareVersion:(NSString *)version {
    
    //获取当前版本号
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    // 都为空，返回yes
        if (!currentVersion && !version) {
            return YES;
        }
        
        // 当前版本号为空，远端版本号不为空，返回no
        if (!currentVersion && version) {
            return NO;
        }
        
        // 远端版本号为空，当前版本号不为空，返回yes
        if (currentVersion && !version) {
            return YES;
        }
    
    // 获取版本号字段
        NSArray *v1Array = [currentVersion componentsSeparatedByString:@"."];
        NSArray *v2Array = [version componentsSeparatedByString:@"."];
        // 取字段最大的，进行循环比较
        NSInteger bigCount = (v1Array.count > v2Array.count) ? v1Array.count : v2Array.count;
        
        for (int i = 0; i < bigCount; i++) {
            // 字段有值，取值；字段无值，置0。
            NSInteger value1 = (v1Array.count > i) ? [[v1Array objectAtIndex:i] integerValue] : 0;
            NSInteger value2 = (v2Array.count > i) ? [[v2Array objectAtIndex:i] integerValue] : 0;
            if (value1 > value2) {
                // currentVersion版本字段大于verson版本字段
                return YES;
            } else if (value1 < value2) {
                // verson版本字段大于currentVersion版本字段
                return NO;
            }
        }

        // 版本号相等
        return YES;
}

@end

//@implementation QNIMInfoModel
//
//@end
//
//@implementation QNWelcomeModel
//
//@end
