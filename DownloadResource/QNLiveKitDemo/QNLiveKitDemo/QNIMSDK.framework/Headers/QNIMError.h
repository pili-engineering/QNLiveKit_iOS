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
    
    QNIMGeneralError = 1,
    QNIMInvalidParam = 2,
    QNIMNotFound = 3,

    QNIMUserNotLogin = 4,
    QNIMUserAlreadyLogin = 5,
    QNIMUserAuthFailed = 6,
    QNIMUserPermissionDenied = 7,
    QNIMUserNotExist = 8,
    QNIMUserAlreadyExist = 9,
    QNIMUserFrozen = 10,
    QNIMUserBanned = 11,
    QNIMUserRemoved = 12,
    QNIMUserTooManyDevice = 13,
    QNIMUserPasswordChanged = 14,
    QNIMUserKickedBySameDevice = 15,
    QNIMUserKickedByOtherDevices = 16,
    QNIMUserAbnormal = 17,
    QNIMUserCancel = 18,
    
    QNIMInvalidVerificationCode = 19,
    QNIMInvalidRequestParameter = 20,
    QNIMInvalidUserNameParameter = 21,
    QNIMMissingAccessToken = 22,
    QNIMCurrentUserIsInRoster = 23,
    QNIMCurrentUserIsInBlocklist = 24,
    QNIMAnswerFailed = 25,
    QNIMInvalidToken = 26,
    
    QNIMRosterNotFriend = 27,
    QNIMRosterBlockListExist = 28,
    QNIMRosterRejectApplication = 29,
    
    QNIMGroupServerDbError = 30,
    QNIMGroupNotExist = 31,
    QNIMGroupNotMemberFound = 32,
    QNIMGroupMsgNotifyTypeUnknown = 33,
    QNIMGroupOwnerCannotLeave = 34,
    QNIMGroupTransferNotAllowed = 35,
    QNIMGroupRecoveryMode = 36,
    QNIMGroupExceedLimitGlobal = 37,
    QNIMGroupExceedLimitUserCreate = 38,
    QNIMGroupExceedLimitUserJoin = 39,
    QNIMGroupCapacityExceedLimit = 40,
    QNIMGroupMemberPermissionRequired = 41,
    QNIMGroupAdminPermissionRequired = 42,
    QNIMGroupOwnerPermissionRequired = 43,
    QNIMGroupApplicationExpiredOrHandled = 44,
    QNIMGroupInvitationExpiredOrHandled = 45,
    QNIMGroupKickTooManyTimes = 46,
    QNIMGroupMemberExist = 47,
    QNIMGroupBlockListExist = 48,
    QNIMGroupAnnouncementNotFound = 49,
    QNIMGroupAnnouncementForbidden = 50,
    QNIMGroupSharedFileNotFound = 51,
    QNIMGroupSharedFileOperateNotAllowed = 52,
    QNIMGroupMemberBanned = 53,

    QNIMSignInCancelled = 54,
    QNIMSignInTimeout = 55,
    QNIMSignInFailed = 56,
    
    QNIMDbOperationFailed = 57,
    
    QNIMMessageInvalid = 58,
    QNIMMessageOutRecallTime = 59,
    QNIMMessageRecallDisabled = 60,
    QNIMMessageCensored = 61,
    QNIMMessageInvalidType = 62,
    
    QNIMServerNotReachable = 63,
    QNIMServerUnknownError = 64,
    QNIMServerInvalid = 65,
    QNIMServerDecryptionFailed = 66,
    QNIMServerEncryptMethodUnsupported = 67,
    QNIMServerBusy = 68,
    QNIMServerNeedRetry = 69,
    QNIMServerTimeOut = 70,
    QNIMServerConnectFailed = 71,
    QNIMServerDNSFailed = 72,
    QNIMServerNeedReconnected = 73,
    QNIMServerFileUploadUnknownError = 74,
    QNIMServerFileDownloadUnknownError = 75,
    QNIMServerInvalidLicense = 76,
    QNIMServerLicenseLimit = 77,
    QNIMServerAppFrozen = 78,
    QNIMServerTooManyRequest = 79,
};


@interface QNIMError : NSObject

@property (nonatomic,assign) QNIMErrorCode errorCode;
@property (nonatomic,copy) NSString *errorMessage;

+ (instancetype)errorCode:(QNIMErrorCode)code;

@end

NS_ASSUME_NONNULL_END
