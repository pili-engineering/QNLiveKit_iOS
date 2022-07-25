//
//  GoodsOperationView.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//批量上下架view
@interface GoodsOperationView : UIView
//上架
@property (nonatomic, copy) void (^takeOnClickedBlock)(void);
//下架
@property (nonatomic, copy) void (^takeDownClickedBlock)(void);
//移除
@property (nonatomic, copy) void (^removeClickedBlock)(void);

@end

NS_ASSUME_NONNULL_END
