//
//  QNAnchorForwardMicLinker.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//主播跨房连麦器
@interface QNAnchorForwardMicLinker : NSObject
//开始连麦
- (void)startLink:(NSString *)peerRoomId extensions:(NSString *)extensions callBack:(void (^)(void))callBack;
//结束连麦
- (void)startLink;
@end

NS_ASSUME_NONNULL_END
