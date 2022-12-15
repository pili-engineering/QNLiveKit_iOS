//
//  QNDemoUserFetchLoginUser.m
//  QNLiveKitDemo
//
//  Created by sheng wang on 2022/12/15.
//

#import "QNDemoUserFetchLoginUser.h"
#import <QNLiveKit/QNLiveKit.h>

@implementation QNDemoUserFetchLoginUser

- (void)example {
    [[QNUserService sharedInstance] fetchLoginUserComplete:^(QNLiveUser * _Nonnull user) {
        NSLog(@"fetch user success %@", user);
    } failure:^(NSError * _Nullable error) {
        NSLog(@"fetch user error %@", error);
    }];
}

@end
