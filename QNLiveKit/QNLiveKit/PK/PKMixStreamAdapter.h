//
//  PKMixStreamAdapter.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNMergeOption,PKSession;

@interface PKMixStreamAdapter : NSObject
//当pk开始 混流 返回混流参数
- (NSArray <QNMergeOption *> *)onPKLinkerJoin:(PKSession *)pkSession;
//当pk结束后如果还有其他普通连麦者 如何混流 如果pk结束后没有其他连麦者 则不会回调
- (NSArray <QNMergeOption *> *)onPKLinkerLeft;
@end

NS_ASSUME_NONNULL_END
