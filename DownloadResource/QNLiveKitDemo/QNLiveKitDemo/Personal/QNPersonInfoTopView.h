//
//  QNPersonInfoTopView.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNPersonInfoModel;

@interface QNPersonInfoTopView : UIView

@property (nonatomic, copy) void (^changeInfoBlock) (void);

- (void)updateWithInfoModel:(QNPersonInfoModel *)infoModel;

@end

NS_ASSUME_NONNULL_END
