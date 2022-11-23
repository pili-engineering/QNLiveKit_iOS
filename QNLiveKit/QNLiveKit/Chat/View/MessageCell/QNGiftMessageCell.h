//
//  QNGiftMessageCell.h
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import <QNLiveKit/QNLiveKit.h>
#import "QMessageBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNGiftMessageCell : QMessageBaseCell

+ (CGSize)getMessageCellSize:(NSString *)content withWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
