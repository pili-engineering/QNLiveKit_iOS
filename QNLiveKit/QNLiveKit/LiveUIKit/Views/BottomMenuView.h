//
//  BottomMenuView.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/31.
//

#import <QNLiveKit/QNLiveKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ImageButtonView;
//底部操作栏槽位
@interface BottomMenuView : QLiveView

//菜单列表
@property (nonatomic,copy)NSArray <ImageButtonView *> *slotList;

@end

NS_ASSUME_NONNULL_END
