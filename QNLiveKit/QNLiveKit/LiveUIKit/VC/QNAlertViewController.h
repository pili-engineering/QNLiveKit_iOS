//
//  QNAlertViewController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNAlertViewController : NSObject
//基础弹窗（标题+提示）
+ (void)showBaseAlertWithTitle:(NSString *)title content:(NSString *)content handler:(void (^ __nullable)(UIAlertAction *action))handler;
//带背景色的弹窗（标题+提示）
+ (void)showBlackAlertWithTitle:(NSString *)title content:(NSString *)content cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler confirmHandler:(void (^ __nullable)(UIAlertAction *action))confirmHandler;
//带输入框的弹窗（标题+提示+输入框）
+ (void)showTextAlertWithTitle:(NSString *)title content:(NSString *)content cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler confirmHandler:(void (^)(NSString *text))confirmHandler;

@end

NS_ASSUME_NONNULL_END
