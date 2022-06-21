//
//  BottomMenuSlot.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/31.
//

#import <QNLiveKit/QNLiveKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ImageButtonComponent;
//底部操作栏槽位
@interface BottomMenuSlot : QLiveComponent

//菜单列表
@property (nonatomic,copy)NSArray <ImageButtonComponent *> *slotList;

@end

NS_ASSUME_NONNULL_END
