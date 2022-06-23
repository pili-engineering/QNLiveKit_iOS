//
//  MixStreamAdapter.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QNMergeOption,QNMicLinker;

@interface MixStreamAdapter : NSObject

/// 混流布局适配
/// @param micLinkers 所有连麦者
/// @return 返回重设后的每个连麦者的混流布局
- (NSArray <QNMergeOption *> *)onResetMixParam:(NSArray <QNMicLinker *> *)micLinkers;

@end

NS_ASSUME_NONNULL_END
