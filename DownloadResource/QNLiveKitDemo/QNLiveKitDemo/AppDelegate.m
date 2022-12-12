//
//  AppDelegate.h
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/20.
//

#import "AppDelegate.h"
#import "QNLoginViewController.h"
#import "QNAppStartPlayerController.h"
#import <QNRTCKit/QNRTCKit.h>
#import <SDWebImage/SDWebImage.h>
#import <YYCategories/YYCategories.h>
#import "QNNetworkUtil.h"
#import "QNAppConficModel.h"
#import <MJExtension/MJExtension.h>
#import "UIApplication+LaunchScreen.h"
#import "QNTabBarViewController.h"
#import <QNLiveKit/QNLiveKit.h>

@interface AppDelegate ()
@property (nonatomic , copy) NSString *urlStr;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self requestConficInfo];
    [self setUpStatusBar];
    if (QN_Live_Token.length > 0) {
        [self initQLive];
    }
    return YES;
}

- (void)initQLive {
    
    __weak typeof(self)weakSelf = self;
    [QLive initWithToken:QN_Live_Token serverURL:LiveAPI errorBack:^(NSError * _Nonnull error) {
        
        //如果token过期
        [weakSelf getLiveToken:^(NSString * _Nonnull token) {
            
            [QLive initWithToken:token serverURL:LiveAPI errorBack:nil];
        }];
        
    }];
    [QLive setBeauty:NO];
}

//获取liveToken
- (void)getLiveToken:(nullable void (^)(NSString * _Nonnull token))callBack {
    
    NSString *action = [NSString stringWithFormat:@"live/auth_token?userID=%@&deviceID=%@",QN_User_id,@"111"];
    [QNNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary *responseData) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:responseData[@"accessToken"] forKey:Live_Token];
        [defaults synchronize];
        
        callBack(responseData[@"accessToken"]);

        } failure:^(NSError *error) {
        
        }];
}

// 请求APP全局配置
- (void)requestConficInfo {
    
    __weak typeof(self) weakSelf = self;
    
    [QNNetworkUtil getRequestWithAction:@"appConfig" params:nil success:^(NSDictionary *responseData) {
        QNAppConficModel *configModel = [QNAppConficModel mj_objectWithKeyValues:responseData];
        
        [weakSelf setupStartVcWithWelcomeModel:configModel.welcome];
        
    } failure:^(NSError *error) {
        [weakSelf setupStartVcWithWelcomeModel:nil];
    }];
}

// 设置启动图
- (void)setupStartVcWithWelcomeModel:(QNWelcomeModel *)welcomeModel {
    
    [UIApplication.sharedApplication clearLaunchScreenCache];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSString *loginToken = [[NSUserDefaults standardUserDefaults] stringForKey:QN_LOGIN_TOKEN_KEY];
    
    if (loginToken.length == 0) {
        QNLoginViewController *loginVC = [[QNLoginViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = navigationController;
    } else {
        
        if (welcomeModel.image.length == 0) {
            QNTabBarViewController *tabBarVc = [[QNTabBarViewController alloc]init];
            self.window.rootViewController = tabBarVc;
        } else {
            self.urlStr = welcomeModel.url;
            QNAppStartPlayerController *startVc = [[QNAppStartPlayerController alloc]init];
            [startVc setImageInIndexWithURL:[NSURL URLWithString:welcomeModel.image] localImageName:@"niucube_bg" timeCount:3];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoPage)];
            [startVc.view addGestureRecognizer:tap];

            self.window.rootViewController = startVc;
        }
    }
    if (@available(iOS 13.0, *)) {
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    } else {
        // Fallback on earlier versions
    }
    [self.window makeKeyAndVisible];
}

- (void)gotoPage {
   
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlStr]];
}

// 设置全局的navigationBar样式
- (void)setUpStatusBar
{
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        [appearance setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        appearance.backgroundColor = [UIColor colorWithHexString:@"007AFF"];
        [UINavigationBar appearance].standardAppearance = appearance;
        [UINavigationBar appearance].scrollEdgeAppearance = [UINavigationBar appearance].standardAppearance;

    } else {
        // Fallback on earlier versions
    }
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"007AFF"]];
}

@end
