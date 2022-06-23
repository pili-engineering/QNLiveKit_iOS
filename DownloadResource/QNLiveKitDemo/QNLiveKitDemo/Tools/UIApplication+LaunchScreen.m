//
//  UIApplication+LaunchScreen.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/5/10.
//

#import "UIApplication+LaunchScreen.h"

@implementation UIApplication (LaunchScreen)

- (void)clearLaunchScreenCache {
    NSError *error;
    [NSFileManager.defaultManager removeItemAtPath:[NSString stringWithFormat:@"%@/Library/SplashBoard",NSHomeDirectory()] error:&error];
    if (error) {
        NSLog(@"Failed to delete launch screen cache: %@",error);
    }
}

@end
