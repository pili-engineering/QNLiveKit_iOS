//
//  QNInternalViewSlot.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomClient;

typedef void (^onClickBlock)(BOOL selected);

@interface QNInternalViewSlot : NSObject

@property (nonatomic, copy)onClickBlock clickBlock;

- (void)createDefaultView:(CGRect)frame onView:(UIView *)onView;

- (void)createCustomView:(UIView *)view onView:(UIView *)onView;

@end

NS_ASSUME_NONNULL_END
