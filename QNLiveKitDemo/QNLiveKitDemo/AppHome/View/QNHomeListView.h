//
//  QNHomeListView.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNSolutionItemModel,QNSolutionListModel;

@interface QNHomeListView : UICollectionViewCell

- (void)viewForModel:(QNSolutionItemModel *)model;

@end

NS_ASSUME_NONNULL_END
