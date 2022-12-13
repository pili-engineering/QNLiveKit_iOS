//
//  ItemSlot.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/31.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QNInternalViewSlot.h"

NS_ASSUME_NONNULL_BEGIN

@interface ItemSlot : QNInternalViewSlot

- (void)normalImage:(NSString *)normalImage selectImage:(NSString *)selectImage;

@end

NS_ASSUME_NONNULL_END
