//
//  RemoteUserVIew.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/7.
//

#import <QNRTCKit/QNRTCKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRenderView : QNVideoGLView

@property (nonatomic, strong) NSString *trackId;

@property (nonatomic, strong) NSString *userId;

@end

NS_ASSUME_NONNULL_END
