//
//  QAlertView.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/3/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QAlertView : NSObject
//基础弹窗（标题+提示）
+ (void)showBaseAlertWithTitle:(NSString *)title content:(NSString *)content cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler confirmHandler:(void (^ __nullable)(UIAlertAction *action))confirmHandler;
//有三个操作按钮的弹窗
+ (void)showThreeActionAlertWithTitle:(NSString *)title content:(NSString *)content firstAction:(NSString *)firstAction firstHandler:(void (^ __nullable)(UIAlertAction *action))firstHandler secondAction:(NSString *)secondAction secondHandler:(void (^ __nullable)(UIAlertAction *action))secondHandler threeHandler:(void (^ __nullable)(UIAlertAction *action))threeHandler;
//带背景色的弹窗（标题+提示）
+ (void)showBlackAlertWithTitle:(NSString *)title content:(NSString *)content cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler confirmHandler:(void (^ __nullable)(UIAlertAction *action))confirmHandler;
//带输入框的弹窗（标题+提示+输入框）
+ (void)showTextAlertWithTitle:(NSString *)title content:(NSString *)content cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler confirmHandler:(void (^)(NSString *text))confirmHandler;

@end

NS_ASSUME_NONNULL_END
