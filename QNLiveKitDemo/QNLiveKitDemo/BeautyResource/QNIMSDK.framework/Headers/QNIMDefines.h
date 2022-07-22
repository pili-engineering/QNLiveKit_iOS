//
//  QNIMDefines.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QNIMNetworkType) {
    QNIMNetworkTypeMobile,
    QNIMNetworkTypeWifi,
    QNIMNetworkTypeCable,
    QNIMNetworkTypeNone
};

typedef NS_ENUM(NSUInteger, QNIMConnectStatus) {
    QNIMConnectStatusDisconnected,
    QNIMConnectStatusConnected,
};

typedef NS_ENUM(NSUInteger, QNIMSignInStatus) {
    QNIMSignInStatusSignOut,
    QNIMSignInStatusSignIn,
};

typedef NS_ENUM(NSUInteger, QNIMLogLevel) {
    QNIMLogLevelError,
    QNIMLogLevelWarning,
    QNIMLogLevelDebug,
};
