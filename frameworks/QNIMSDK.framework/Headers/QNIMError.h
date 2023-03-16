//
//  QNIMError.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QNIMErrorCode) {
    QNIMNoError = 0,
    
    QNIMGeneralError,
    QNIMInvalidParam,
    QNIMNotFound,
    QNIMDbOperationFailed,
    QNIMSignInCancelled,
    QNIMSignInTimeout,
    QNIMSignInFailed,

    QNIMUserNotLogin = 100,
    QNIMUserAlreadyLogin,
    QNIMUserAuthFailed,
    QNIMUserPermissionDenied,
    QNIMUserNotExist,
    QNIMUserAlreadyExist,
    QNIMUserFrozen,
    QNIMUserBanned,
    QNIMUserRemoved,
    QNIMUserTooManyDevice,
    QNIMUserPasswordChanged,
    QNIMUserKickedBySameDevice,
    QNIMUserKickedByOtherDevices,
    QNIMUserAbnormal,
    QNIMUserCancel,
    QNIMUserOldPasswordNotMatch,
    QNIMUserSigningIn,

    QNIMPushTokenInvalid = 200,
    QNIMPushAliasBindByOtherUser,
    QNIMPushAliasTokenNotMatch,

    QNIMInvalidVerificationCode = 300,
    QNIMInvalidRequestParameter,
    QNIMInvalidUserNameParameter,
    QNIMMissingAccessToken,
    QNIMCurrentUserIsInRoster,
    QNIMCurrentUserIsInBlocklist,
    QNIMAnswerFailed,
    QNIMInvalidToken,
    QNIMInvalidFileSign,
    QNIMInvalidFileObjectType,
    QNIMInvalidFileUploadToType,
    QNIMInvalidFileDownloadUrl,

    QNIMMessageInvalid = 400,
    QNIMMessageOutRecallTime,
    QNIMMessageRecallDisabled,
    QNIMMessageCensored,
    QNIMMessageInvalidType,

    QNIMRosterNotFriend = 500,
    QNIMRosterBlockListExist,
    QNIMRosterRejectApplication,

    QNIMGroupServerDbError = 600,
    QNIMGroupNotExist,
    QNIMGroupNotMemberFound,
    QNIMGroupMsgNotifyTypeUnknown,
    QNIMGroupOwnerCannotLeave,
    QNIMGroupTransferNotAllowed,
    QNIMGroupRecoveryMode,
    QNIMGroupExceedLimitGlobal,
    QNIMGroupExceedLimitUserCreate,
    QNIMGroupExceedLimitUserJoin,
    QNIMGroupCapacityExceedLimit,
    QNIMGroupMemberPermissionRequired,
    QNIMGroupAdminPermissionRequired,
    QNIMGroupOwnerPermissionRequired,
    QNIMGroupApplicationExpiredOrHandled,
    QNIMGroupInvitationExpiredOrHandled,
    QNIMGroupKickTooManyTimes,
    QNIMGroupMemberExist,
    QNIMGroupBlockListExist,
    QNIMGroupAnnouncementNotFound,
    QNIMGroupAnnouncementForbidden,
    QNIMGroupSharedFileNotFound,
    QNIMGroupSharedFileOperateNotAllowed,
    QNIMGroupMemberBanned,

    QNIMServerNotReachable = 700,
    QNIMServerUnknownError,
    QNIMServerInvalid,
    QNIMServerDecryptionFailed,
    QNIMServerEncryptMethodUnsupported,
    QNIMServerBusy,
    QNIMServerNeedRetry,
    QNIMServerTimeOut,
    QNIMServerConnectFailed,
    QNIMServerDNSFailed,
    QNIMServerNeedReconnected,
    QNIMServerFileUploadUnknownError,
    QNIMServerFileDownloadUnknownError,
    QNIMServerInvalidLicense,
    QNIMServerLicenseLimit,
    QNIMServerAppFrozen,
    QNIMServerTooManyRequest,
    QNIMServerNotAllowOpenRegister,
    QNIMServerFireplaceUnknownError,
    QNIMServerResponseInvalid,
    QNIMServerInvalidUploadUrl,
    QNIMServerAppLicenseInvalid,
    QNIMServerAppLicenseExpired,
    QNIMServerAppLicenseExceedLimit,
    QNIMServerAppIdMissing,
    QNIMServerAppIdInvalid,
    QNIMServerAppSignInvalid,
    QNIMServerAppNotifierNotExist,
    QNIMServerNoClusterInfoForClusterId,
    QNIMServerFileDownloadFailure,
    QNIMServerAppStatusNotNormal,

    };


@interface QNIMError : NSObject

@property (nonatomic,assign) QNIMErrorCode errorCode;
@property (nonatomic,copy) NSString *errorMessage;

+ (instancetype)errorCode:(QNIMErrorCode)code;

@end

NS_ASSUME_NONNULL_END
