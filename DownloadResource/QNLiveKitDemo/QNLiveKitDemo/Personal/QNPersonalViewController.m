//
//  QNPersonalViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/8.
//

#import "QNPersonalViewController.h"
#import "QNNetworkUtil.h"
#import "QNPersonInfoTopView.h"
#import "QNAppRulesCell.h"
#import "QNAppReleaseInfoCell.h"
#import "QNPersonInfoModel.h"
#import "QNPersonalViewModel.h"
#import "QNQuitLoginCell.h"
#import "QNLoginViewController.h"
#import <YYCategories/YYCategories.h>
#import <Masonry/Masonry.h>

@interface QNPersonalViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) QNPersonInfoTopView *topView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *versionLabel;
@end

@implementation QNPersonalViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的";
    self.view.backgroundColor = [UIColor whiteColor];
    [self topView];
    [self tableView];
    [self versionLabel];
    [self requestData];
    
}

- (void)requestData {
    
    __weak typeof(self) weakSelf = self;
    [QNPersonalViewModel requestPersonInfo:^(QNPersonInfoModel * _Nonnull personInfo) {
        [weakSelf.topView updateWithInfoModel:personInfo];        
    }];
}

//修改昵称弹窗
- (void)popChangeNameAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"昵称修改" message:@"当前昵称" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
    }];
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"修改" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[alertController.textFields firstObject] endEditing:YES];
        //修改昵称
        NSString *meetingId = [alertController.textFields firstObject].text;
        __weak typeof(self) weakSelf = self;
        [QNPersonalViewModel changePersonInfoWithNickName:meetingId success:^(QNPersonInfoModel * _Nonnull personInfo) {
            [weakSelf.topView updateWithInfoModel:personInfo]; 
        }];
            
    }];
    [alertController addAction:changeBtn];
    
    [self presentViewController:alertController animated:YES completion:nil];

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 2 ? 40 : 110;    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        QNAppRulesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QNAppRulesCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == 1) {
        QNAppReleaseInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QNAppReleaseInfoCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == 2) {
        QNQuitLoginCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QNQuitLoginCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    return nil;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        [self popChangeNameAlert];
    } else if (indexPath.section ==2) {
        __weak typeof(self)weakSelf = self;
        [QNNetworkUtil postRequestWithAction:@"signOut" params:nil success:^(NSDictionary *responseData) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:QN_LOGIN_TOKEN_KEY];
            [defaults synchronize];
            
            QNLoginViewController *loginVC = [[QNLoginViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
            weakSelf.view.window.rootViewController = navigationController;
            
        } failure:^(NSError *error) {
                    
        }];
    }
    
}

- (QNPersonInfoTopView *)topView {
    if (!_topView) {
        _topView = [[QNPersonInfoTopView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight/3.5)];
        _topView.backgroundColor = [UIColor colorWithHexString:@"007AFF"];
        __weak typeof(self) weakSelf = self;
        _topView.changeInfoBlock = ^{
            [weakSelf popChangeNameAlert];
        };
        [self.view addSubview:_topView];
    }
    return _topView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setBackgroundView:nil];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        [self.view addSubview:_tableView];
    
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15);
            make.right.equalTo(self.view).offset(-15);
            make.top.equalTo(self.topView.mas_bottom).offset(-25);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-30);
        }];
        
        [_tableView registerClass:[QNAppRulesCell class] forCellReuseIdentifier:@"QNAppRulesCell"];
        [_tableView registerClass:[QNAppReleaseInfoCell class] forCellReuseIdentifier:@"QNAppReleaseInfoCell"];
        [_tableView registerClass:[QNQuitLoginCell class] forCellReuseIdentifier:@"QNQuitLoginCell"];
        
    }
    return _tableView;
}

- (UILabel *)versionLabel {
    if (!_versionLabel) {
        _versionLabel = [[UILabel alloc]init];
        _versionLabel.text = [NSString stringWithFormat:@"v%@",QN_APP_VERSION];
        _versionLabel.textColor = [UIColor colorWithHexString:@"828282"];
        _versionLabel.font = [UIFont systemFontOfSize:11];
        [self.view addSubview:_versionLabel];
        
        [_versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-20);
        }];
    }
    return _versionLabel;
}

@end
