//
//  QNAnchorHostMicLinker.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MixStreamAdapter;
//主播端连麦器
@interface QNAnchorHostMicLinker : NSObject
//设置混流适配器
- (void)setMixStreamAdapter:(MixStreamAdapter *)mixStreamAdapter;

@end

NS_ASSUME_NONNULL_END
