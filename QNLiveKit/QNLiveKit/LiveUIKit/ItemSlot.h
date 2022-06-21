//
//  ItemSlot.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/31.
//

#import <QNLiveKit/QNLiveKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ItemSlot : QNInternalViewSlot

@property (nonatomic, assign) BOOL selected;

- (void)normalImage:(NSString *)normalImage selectImage:(NSString *)selectImage;

@end

NS_ASSUME_NONNULL_END
