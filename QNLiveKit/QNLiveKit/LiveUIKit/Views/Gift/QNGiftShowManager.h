//
//  GiftShowManager.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.

//  送礼物逻辑的管理

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SendGiftModel;
typedef void(^completeBlock)(BOOL finished);

@interface GiftShowManager : NSObject

+ (instancetype)sharedManager;

/**
 送礼物
 
 @param backView 礼物动效展示父view
 @param giftModel 礼物的数据
 @param completeBlock 展示完毕回调
 */

- (void)showGiftViewWithBackView:(UIView *)backView
                            info:(SendGiftModel *)giftModel
                   completeBlock:(completeBlock)completeBlock;

@end
