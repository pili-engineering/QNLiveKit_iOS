//
//  QNTabBarViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/8.
//

#import "QNTabBarViewController.h"
#import "QNPersonalViewController.h"
#import <QNLiveKit/QNLiveKit.h>
#import <QNLiveUIKit/QNLiveUIKit.h>
#import <YYCategories/YYCategories.h>
#import <QNLiveUIKit/QLiveListController.h>
#import "ApiDemoViewController.h"
@interface QNTabBarViewController ()

@end

@implementation QNTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addViewController];
}

- (void)addViewController {
    
    QLiveListController *vc = [QLiveListController new];

    UINavigationController *homeListNav = [[UINavigationController alloc]initWithRootViewController:vc];
    homeListNav.tabBarItem.title = @"应用";
    homeListNav.tabBarItem.image = [UIImage imageNamed:@"icon_app_list"];
    homeListNav.tabBarItem.selectedImage = [UIImage imageNamed:@"icon_apply_list_selected"];
    [self addChildViewController:homeListNav];
    
    QNPersonalViewController *personalVc = [[QNPersonalViewController alloc]init];
    UINavigationController *personalNav = [[UINavigationController alloc]initWithRootViewController:personalVc];
    personalNav.tabBarItem.title = @"我的";
    personalNav.tabBarItem.image = [UIImage imageNamed:@"icon_user"];
    personalNav.tabBarItem.selectedImage = [UIImage imageNamed:@"icon_user_selected"];
    [self addChildViewController:personalNav];
    
    
    ApiDemoViewController *demoVc = [[ApiDemoViewController alloc]init];
    UINavigationController *demoNav = [[UINavigationController alloc]initWithRootViewController:demoVc];
    demoNav.tabBarItem.title = @"API测试";
    demoNav.tabBarItem.image = [UIImage imageNamed:@"icon_user"];
    demoNav.tabBarItem.selectedImage = [UIImage imageNamed:@"icon_user_selected"];
    [self addChildViewController:demoNav];
}


@end
