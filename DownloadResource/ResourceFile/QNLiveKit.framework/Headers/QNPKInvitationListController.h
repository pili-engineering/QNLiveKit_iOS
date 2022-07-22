//
//  QNPKInvitationListController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNLiveRoomInfo;

@interface QNPKInvitationListController : UIViewController

@property (nonatomic, copy) void (^invitationClickedBlock)(QNLiveRoomInfo *itemModel);

- (instancetype)initWithList:(NSArray<QNLiveRoomInfo *> *)list;

@end

NS_ASSUME_NONNULL_END
