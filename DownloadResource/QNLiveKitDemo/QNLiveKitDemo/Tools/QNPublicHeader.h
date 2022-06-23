//
//  QNPublicHeader.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/3/29.
//

#ifndef QNPublicHeader_h
#define QNPublicHeader_h

#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS

#ifndef ARRAY_SIZE
    #define ARRAY_SIZE(arr) (sizeof(arr) / sizeof(arr[0]))
#endif

//#ifdef DEBUG
//#define NSLog(FORMAT, ...) fprintf(stderr,"\n %s:%d   %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__LINE__, [[[NSString alloc] initWithData:[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] dataUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding] UTF8String]);
//#else
//#define NSLog(...)
//#endif

/*********************  宽高  *********************/

#define QRD_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define QRD_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define QRD_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define QRD_LOGIN_TOP_SPACE (QRD_iPhoneX ? 140: 100)

#define kStatusHeight  [[UIApplication sharedApplication] statusBarFrame].size.height

#define kNavigationHeight  [[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 88 : 64

#define kTabBarHeight  [[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 83 : 49

#define kNavigationAndStatusHeight  [[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 108 : 49

/*********************  颜色  *********************/
// 颜色RGB 通用
#define QRD_COLOR_RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

/*********************  字体  *********************/
#define QRD_LIGHT_FONT(FontSize) [UIFont fontWithName:@"PingFangSC-Light" size:FontSize]
#define QRD_REGULAR_FONT(FontSize) [UIFont fontWithName:@"PingFangSC-Regular" size:FontSize]
#define QRD_BOLD_FONT(FontSize) [UIFont fontWithName:@"HelveticaNeue-Bold" size:FontSize]

/********************* Key *********************/

#define QN_LOGIN_TOKEN_KEY @"QN_LOGIN_TOKEN"
#define QN_USER_AVATAR_KEY @"QN_USER_AVATAR"
#define QN_ACCOUNT_ID_KEY @"QN_ACCOUNT_ID"
#define QN_NICKNAME_KEY @"QN_NICKNAME"
#define QN_IM_APPID @"cigzypnhoyno"
#define APPSERVER @"http://seallive.qiniuapi.com/"
#define QN_IM_USER_ID_KEY @"QN_IM_USER_ID"
#define QN_IM_USER_NAME_KEY @"QN_IM_USER_NAME"
#define QN_IM_USER_PASSWORD_KEY @"QN_IM_USER_PASSWORD"

//get登录token
#define QN_Login_token  [[NSUserDefaults standardUserDefaults] stringForKey:QN_LOGIN_TOKEN_KEY]
//get头像
#define QN_User_avatar  [[NSUserDefaults standardUserDefaults] stringForKey:QN_USER_AVATAR_KEY]
//get用户ID
#define QN_User_id  [[NSUserDefaults standardUserDefaults] stringForKey:QN_ACCOUNT_ID_KEY]
//get用户昵称
#define QN_User_nickname  [[NSUserDefaults standardUserDefaults] stringForKey:QN_NICKNAME_KEY]
//getIM userid
#define QN_IM_userId  [[NSUserDefaults standardUserDefaults] stringForKey:QN_IM_USER_ID_KEY]
//get IM userName
#define QN_IM_userName  [[NSUserDefaults standardUserDefaults] stringForKey:QN_IM_USER_NAME_KEY]
//get IM psw
#define QN_IM_psw  [[NSUserDefaults standardUserDefaults] stringForKey:QN_IM_USER_PASSWORD_KEY]

//线上
#define MAINAPI @"https://niucube-api.qiniu.com/v1/%@"

//测试
//#define MAINAPI @"http://10.200.20.28:5080/v1/%@"


//面试：公司/部门
#define QN_GOVERMENT_KEY @"QN_GOVERMENT"
//职位
#define QN_CAREER_KEY @"QN_CAREER"

#define QN_APP_ID_KEY @"QN_APP_ID"
#define QN_SET_CONFIG_KEY @"QN_SET_CONFIG"
#define QN_ROOM_NAME_KEY @"QN_ROOM_NAME"
//RTC APP ID
//#define QN_RTC_DEMO_APPID @"fleqfq6yc"
#define QN_RTC_DEMO_APPID @"fnf0vr6gn"

//bugly app id
#define QN_BUGLY_APPID @"38a880afdd"
#define QN_BUGLY_APPKEY @"b44d6ac6-5a6d-46a9-aa21-a41c613d21fc"

/********************* 地址 *********************/
//..隐私权政策网址
#define QN_POLICY_URL @"https://www.qiniu.com/privacy-right"
//..服务用户协议
#define QN_AGREEMENT_URL @"https://www.qiniu.com/user-agreement"


#define QN_Room_Type_VoiceChatRoom @"voiceChatRoom"
#define QN_Room_Type_Movie @"movie"
#define QN_Room_Type_Show @"show"
#define QN_Room_Type_Repair @"repair"

#import "QNNetworkUtil.h"
#import <MJExtension/MJExtension.h>
#import <YYCategories/YYCategories.h>
#import <SDWebImage/SDWebImage.h>
#import "QNIMSDK/QNIMSDK.h"
#import <Masonry/Masonry.h>
#import "MBProgressHUD+QNShow.h"
#import <QNRTCKit/QNRTCKit.h>

/********************* 通用 *********************/

//..app版本号
#define QN_APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#ifndef dispatch_queue_async_safe
#define dispatch_queue_async_safe(queue, block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {\
block();\
} else {\
dispatch_async(queue, block);\
}
#endif

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block) dispatch_queue_async_safe(dispatch_get_main_queue(), block)
#endif

#ifndef dispatch_queue_sync_safe
#define dispatch_queue_sync_safe(queue, block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {\
block();\
} else {\
dispatch_sync(queue, block);\
}
#endif

#ifndef dispatch_main_sync_safe
#define dispatch_main_sync_safe(block) dispatch_queue_sync_safe(dispatch_get_main_queue(), block)
#endif

#endif /* QNPublicHeader_h */
