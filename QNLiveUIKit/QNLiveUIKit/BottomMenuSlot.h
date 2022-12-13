//
//  BottomMenuSlot.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/31.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNInternalViewSlot.h"
NS_ASSUME_NONNULL_BEGIN

@class ItemSlot;
@interface BottomMenuSlot : QNInternalViewSlot

//菜单列表
@property (nonatomic,copy)NSArray <ItemSlot *> *slotList;

@end

NS_ASSUME_NONNULL_END
