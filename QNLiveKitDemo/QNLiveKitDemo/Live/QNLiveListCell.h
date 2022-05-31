//
//  QNLiveListCell.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo;

@interface QNLiveListCell : UICollectionViewCell
- (void)updateWithModel:(QNLiveRoomInfo *)model;
@end

NS_ASSUME_NONNULL_END
