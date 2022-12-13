//
//  QNLiveStatisticView.h
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo;

@interface QNLiveStatisticView : UIView

@property (nonatomic, strong) QNLiveRoomInfo *roomInfo;

- (void)updateWith:(QNLiveRoomInfo *)roomInfo;

@end

NS_ASSUME_NONNULL_END
