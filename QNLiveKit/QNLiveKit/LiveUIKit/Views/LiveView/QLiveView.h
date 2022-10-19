//
//  QLiveView.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomClient;

typedef void (^onClickBlock)(BOOL selected);

//UI组件基类
@interface QLiveView : UIView

@property (nonatomic, copy)onClickBlock clickBlock;

@end

NS_ASSUME_NONNULL_END
