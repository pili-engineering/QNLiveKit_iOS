//
//  GiftOperation.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//  送礼物的操作

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SendGiftModel,GiftShowView;

typedef void(^completeOpBlock)(BOOL finished,NSString *giftKey);

@interface GiftOperation : NSOperation

/**
 增加一个操作

 @param giftShowView 礼物显示的View
 @param backView 礼物要显示在的父view
 @param model 礼物的数据
 @param completeBlock 回调操作结束
 @return 操作
 */
+ (instancetype)addOperationWithView:(GiftShowView *)giftShowView
                              OnView:(UIView *)backView
                                Info:(SendGiftModel *)model
                       completeBlock:(completeOpBlock)completeBlock;


/** 礼物展示的父view */
@property(nonatomic,strong) UIView *backView;
/** ext */
@property(nonatomic,strong) SendGiftModel *model;
/** block */
@property(nonatomic,copy) completeOpBlock opFinishedBlock;
/** showview */
@property(nonatomic,strong) GiftShowView *giftShowView;

@end
