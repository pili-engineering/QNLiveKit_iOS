//
//  QNTabBarViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/8.
//

#import "QNTabBarViewController.h"
#import "QNHomeListViewController.h"
#import "QNPersonalViewController.h"

#import <YYCategories/YYCategories.h>
@interface QNTabBarViewController ()

@end

@implementation QNTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addViewController];
}

- (void)addViewController {
    QNHomeListViewController *homeListVc = [[QNHomeListViewController alloc]init];
    UINavigationController *homeListNav = [[UINavigationController alloc]initWithRootViewController:homeListVc];
    homeListNav.tabBarItem.title = @"应用";
    homeListNav.tabBarItem.image = [UIImage imageNamed:@"icon_app_list"];
    homeListVc.tabBarItem.selectedImage = [UIImage imageNamed:@"icon_apply_list_selected"];
    [self addChildViewController:homeListNav];
    
    QNPersonalViewController *personalVc = [[QNPersonalViewController alloc]init];
    UINavigationController *personalNav = [[UINavigationController alloc]initWithRootViewController:personalVc];
    personalNav.tabBarItem.title = @"我的";
    personalNav.tabBarItem.image = [UIImage imageNamed:@"icon_user"];
    personalNav.tabBarItem.selectedImage = [UIImage imageNamed:@"icon_user_selected"];
    [self addChildViewController:personalNav];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
