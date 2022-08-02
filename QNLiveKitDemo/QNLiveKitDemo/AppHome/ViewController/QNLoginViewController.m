//
//  QNLoginViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/7.
//

#import "QNLoginViewController.h"
#import "QNTabBarViewController.h"
#import "QNCountdownButton.h"
#import "QNNetworkUtil.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "QNLoginInfoModel.h"
#import <MJExtension/MJExtension.h>
#import "MBProgressHUD+QNShow.h"
#import <QNIMSDK/QNIMSDK.h>
#import <QNLiveKit/QNLiveKit.h>


@interface QNLoginViewController ()

@property (nonatomic, strong) UIImageView *mainImageView;

@property (nonatomic, strong) UITextField *phoneTf;

@property (nonatomic, strong) UITextField *codeTf;

@property (nonatomic, strong) QNCountdownButton *sendCodeButton;

@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) UIButton *selectButton;

@property (nonatomic, strong) UIButton *privacyButton;

@property (nonatomic, strong) UIButton *disclaimerButton;

@property (nonatomic, strong) UILabel *label1;

@property (nonatomic, strong) UILabel *label2;
@end

@implementation QNLoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpUI];
}

- (void)setUpUI {
    [self mainImageView];
    [self phoneTf];
    [self codeTf];
    [self sendCodeButton];
    [self tipsLabel];
    [self loginButton];
    [self selectButton];
    [self label1];
    [self privacyButton];
    [self label2];
    [self disclaimerButton];

    
    UIView *topLineView = [[UIView alloc]init];
    topLineView.backgroundColor = [UIColor colorWithHexString:@"EAEAEA"];
    [self.view addSubview:topLineView];
    [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.phoneTf.mas_bottom).offset(5);
        make.height.mas_equalTo(1);
    }];
    
    UIView *bottomLineView = [[UIView alloc]init];
    bottomLineView.backgroundColor = [UIColor colorWithHexString:@"EAEAEA"];
    [self.view addSubview:bottomLineView];
    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.codeTf.mas_bottom).offset(5);
        make.height.mas_equalTo(1);
    }];
}

- (void)sendCodeMsgButtonClick {
    [self getSmsCode];
    __weak typeof(self) weakSelf = self;
    [_sendCodeButton countDownWithDuration:60 completion:^(BOOL finished) {
        [weakSelf.sendCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        weakSelf.sendCodeButton.selected = NO;
        weakSelf.sendCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [weakSelf.sendCodeButton setTitleColor:[UIColor colorWithHexString:@"007AFF"] forState:UIControlStateNormal];
    }];
}

//登录
- (void)loginButtonClick {
    
    if (self.phoneTf.text.length == 0) {
        [MBProgressHUD showText:@"请填写手机号"];
        return;
    }
    
    if (self.codeTf.text.length == 0) {
        [MBProgressHUD showText:@"请填写验证码"];
        return;
    }
    
    if (!self.selectButton.selected) {
        [MBProgressHUD showText:@"请先同意用户协议和隐私权政策"];
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"phone"] = self.phoneTf.text;
    params[@"smsCode"] = self.codeTf.text;
    [QNNetworkUtil postRequestWithAction:@"signUpOrIn" params:params success:^(NSDictionary *responseData) {
        
        QNLoginInfoModel *loginModel = [QNLoginInfoModel mj_objectWithKeyValues:responseData];
        [self saveLoginInfoToUserDefaults:loginModel];
        [self initQNLiveWithUser:loginModel deviceID:@"1111"];
        
    } failure:^(NSError *error) {
        
        [MBProgressHUD showText:@"登录失败"];
        
    }];

}

//初始化QNLive
- (void)initQNLiveWithUser:(QNLoginInfoModel *)user deviceID:(NSString *)deviceID {
    
    NSString *action = [NSString stringWithFormat:@"live/auth_token?userID=%@&deviceID=%@",user.accountId,deviceID];
    [QNNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary *responseData) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:responseData[@"accessToken"] forKey:DEMO_LIVE_TOKEN];
        [defaults synchronize];
        
        [QLive initWithToken:responseData[@"accessToken"] serverURL:DEMOLiveAPI errorBack:^(NSError * _Nonnull error) {
            if (error) {
                NSLog(@"QLive初始化错误%@",error);
            }
        }];
        [QLive setUser:user.avatar nick:user.nickname extension:nil];
//        [QLive setBeauty:YES];
        } failure:^(NSError *error) {
        
        }];
}


//记录登录信息
- (void)saveLoginInfoToUserDefaults:(QNLoginInfoModel *)loginModel {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:loginModel.loginToken forKey:DEMO_LOGIN_TOKEN_KEY];
    [defaults setObject:loginModel.accountId forKey:DEMO_ACCOUNT_ID_KEY];
    [defaults setObject:loginModel.nickname forKey:DEMO_NICKNAME_KEY];
    
    [defaults synchronize];

    QNTabBarViewController *tabBarVc = [[QNTabBarViewController alloc]init];
    UIWindow *window =  [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    window.rootViewController = tabBarVc;
}

- (void)getSmsCode {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"phone"] = self.phoneTf.text;
    [QNNetworkUtil postRequestWithAction:@"getSmsCode" params:params success:^(NSDictionary *responseData) {
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark ------------------------------Lazy Load

- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"qiniu_main"]];
        [self.view addSubview:_mainImageView];
        
        [_mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(150);
            make.width.mas_equalTo(112);
            make.height.mas_equalTo(30);
        }];
    }
    return _mainImageView;
}

- (UITextField *)phoneTf {
    if (!_phoneTf) {
        _phoneTf = [[UITextField alloc]init];
        _phoneTf.font = [UIFont systemFontOfSize:15];
        _phoneTf.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
        _phoneTf.leftViewMode = UITextFieldViewModeAlways;
        _phoneTf.textColor = [UIColor blackColor];
        _phoneTf.textAlignment = NSTextAlignmentLeft;
        NSAttributedString *placeHolderStr = [[NSAttributedString alloc]initWithString:@"请输入手机号" attributes:@{
            NSForegroundColorAttributeName:[UIColor lightGrayColor],
            NSFontAttributeName:_phoneTf.font
        }];
        _phoneTf.attributedPlaceholder = placeHolderStr;
        [self.view addSubview:_phoneTf];
        [_phoneTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(40);
            make.right.equalTo(self.view).offset(-40);
            make.top.equalTo(self.mainImageView.mas_bottom).offset(100);
            make.height.mas_equalTo(30);
        }];
    }
    return _phoneTf;
}

- (UITextField *)codeTf {
    if (!_codeTf) {
        _codeTf = [[UITextField alloc]init];
        _codeTf.font = [UIFont systemFontOfSize:15];
        _codeTf.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 0)];
        _codeTf.leftViewMode = UITextFieldViewModeAlways;
        _codeTf.textColor = [UIColor blackColor];
        _codeTf.textAlignment = NSTextAlignmentLeft;
        _codeTf.layer.cornerRadius = 10;
        NSAttributedString *placeHolderStr = [[NSAttributedString alloc]initWithString:@"请输入验证码" attributes:@{
            NSForegroundColorAttributeName:[UIColor lightGrayColor],
            NSFontAttributeName:_codeTf.font
        }];
        _codeTf.attributedPlaceholder = placeHolderStr;
        [self.view addSubview:_codeTf];
        [_codeTf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right .equalTo(self.phoneTf);
            make.top.equalTo(self.phoneTf.mas_bottom).offset(30);
            make.height.mas_equalTo(30);
        }];
    }
    return _codeTf;
}

- (QNCountdownButton *)sendCodeButton {
    if (!_sendCodeButton) {
        _sendCodeButton = [[QNCountdownButton alloc]init];
        [_sendCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        _sendCodeButton.selected = NO;
        _sendCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendCodeButton setTitleColor:[UIColor colorWithHexString:@"007AFF"] forState:UIControlStateNormal];
        [_sendCodeButton addTarget:self action:@selector(sendCodeMsgButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.codeTf addSubview:_sendCodeButton];
        
        [_sendCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.codeTf.mas_right).offset(-5);
            make.centerY.equalTo(self.codeTf);
        }];
    }
    return _sendCodeButton;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc]init];
        _tipsLabel.text = @"Tips:新用户可以直接通过验证码进行注册登录";
        _tipsLabel.textColor = [UIColor colorWithHexString:@"999999"];
        _tipsLabel.font = [UIFont systemFontOfSize:12];
        [self.view addSubview:_tipsLabel];
        
        [_tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.codeTf).offset(10);
            make.top.equalTo(self.codeTf.mas_bottom).offset(15);
            make.height.mas_offset(15);
        }];
    }
    return _tipsLabel;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [[UIButton alloc]init];
        _loginButton.backgroundColor = [UIColor colorWithHexString:@"007AFF"];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        _loginButton.layer.cornerRadius = 4;
        [self.view addSubview:_loginButton];
        [_loginButton addTarget:self action:@selector(loginButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(50);
            make.right.equalTo(self.view).offset(-50);
            make.top.equalTo(self.tipsLabel.mas_bottom).offset(50);
            make.height.mas_offset(40);
        }];
    }
    return _loginButton;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [[UIButton alloc]init];
        [_selectButton setImage:[UIImage imageNamed:@"icon_pitch_off"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"icon_pitch_on"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(selectedButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_selectButton];
        
        [_selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.loginButton);
            make.top.equalTo(self.loginButton.mas_bottom).offset(15);
        }];

    }
    return _selectButton;
}

- (UILabel *)label1 {
    if (!_label1) {
        _label1 = [[UILabel alloc]init];
        _label1.text = @"我已阅读并同意";
        _label1.textColor = [UIColor colorWithHexString:@"007AFF"];
        _label1.font = [UIFont systemFontOfSize:11];
        [self.view addSubview:_label1];
        
        [_label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.selectButton.mas_right).offset(3);
            make.centerY.equalTo(self.selectButton);
        }];
    }
    return _label1;
}

- (UIButton *)privacyButton {
    if (!_privacyButton) {
        _privacyButton = [[UIButton alloc]init];
        [_privacyButton setTitle:@"七牛云服务用户协议" forState:UIControlStateNormal];
        [_privacyButton setTitleColor:[UIColor colorWithHexString:@"007AFF"] forState:UIControlStateNormal];
        _privacyButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        [_privacyButton addTarget:self action:@selector(agreement) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_privacyButton];
        
        [_privacyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.label1.mas_right).offset(3);
            make.centerY.equalTo(self.selectButton);
        }];
        
    }
    return _privacyButton;
}

- (UILabel *)label2 {
    if (!_label2) {
        _label2 = [[UILabel alloc]init];
        _label2.text = @"和";
        _label2.textColor = [UIColor colorWithHexString:@"007AFF"];
        _label2.font = [UIFont systemFontOfSize:11];
        [self.view addSubview:_label2];
        
        [_label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.privacyButton.mas_right).offset(3);
            make.centerY.equalTo(self.selectButton);
        }];
    }
    return _label2;
}

- (UIButton *)disclaimerButton {
    if (!_disclaimerButton) {
        _disclaimerButton = [[UIButton alloc]init];
        [_disclaimerButton setTitle:@"隐私权政策" forState:UIControlStateNormal];
        [_disclaimerButton setTitleColor:[UIColor colorWithHexString:@"007AFF"] forState:UIControlStateNormal];
        _disclaimerButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        [_disclaimerButton addTarget:self action:@selector(policy) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_disclaimerButton];
        
        [_disclaimerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.label2.mas_right).offset(3);
            make.centerY.equalTo(self.selectButton);
        }];
    }
    return _disclaimerButton;
}

- (void)selectedButtonClick {
    _selectButton.selected = !_selectButton.selected;
}

- (void)policy {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:QN_POLICY_URL]];
}

- (void)agreement {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:QN_AGREEMENT_URL]];
}


@end
