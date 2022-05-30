//
//  QNHomeListViewModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNSolutionListModel;

@interface QNHomeListViewModel : NSObject

+ (void)requestListModel:(void (^)(QNSolutionListModel *list))success;

@end

NS_ASSUME_NONNULL_END
