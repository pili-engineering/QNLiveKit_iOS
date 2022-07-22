//
//  QNPKInvitationListCell.h
//  QNLiveKit
//
//  Created by 郭茜 on 2021/12/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo;

@interface QNPKInvitationListCell : UITableViewCell

@property (nonatomic,strong) QNLiveRoomInfo *itemModel;

@property (nonatomic, copy) void (^listClickedBlock)(QNLiveRoomInfo *itemModel);

@end

NS_ASSUME_NONNULL_END
