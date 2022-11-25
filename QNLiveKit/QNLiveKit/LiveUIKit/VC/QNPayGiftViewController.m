//
//  QNPayGiftViewController.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/22.
//

#import "QNPayGiftViewController.h"

@interface QNPayGiftViewController ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *amountTextField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *payButton;

@property (nonatomic, copy) void (^completeBlock)(NSInteger amount);

@end

@implementation QNPayGiftViewController

- (instancetype)initWithComplete:(void (^)(NSInteger amount))complete {
    if (self = [super init]) {
        [self.view setFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
        self.completeBlock = complete;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.backgroundView];
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        CGFloat x = (SCREEN_W - 320) / 2.0;
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(x, 240, 320, 209)];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        [_backgroundView.layer setCornerRadius:8];
        
        [_backgroundView addSubview:self.titleLabel];
        [_backgroundView addSubview:self.amountTextField];
        [_backgroundView addSubview:self.cancelButton];
        [_backgroundView addSubview:self.payButton];
    }
    return _backgroundView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 32, 272, 24)];
        _titleLabel.text = @"发红包";
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [_titleLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _titleLabel;
}

- (UITextField *)amountTextField {
    if (!_amountTextField) {
        _amountTextField = [[UITextField alloc] initWithFrame:CGRectMake(24, 72, 272, 48)];
        _amountTextField.backgroundColor = [UIColor colorWithHexString:@"#F3F3F3"];
        [_amountTextField.layer setCornerRadius:4];
        _amountTextField.keyboardType = UIKeyboardTypeNumberPad;
        
        _amountTextField.placeholder = @"请输入红包金额";
        _amountTextField.font = [UIFont systemFontOfSize:16];
    }
    return _amountTextField;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(23.5, 169, 112, 24)];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9] forState:UIControlStateNormal];
        
        [_cancelButton addTarget:self action:@selector(cancelPay) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)payButton {
    if (!_payButton) {
        _payButton = [[UIButton alloc] initWithFrame:CGRectMake(184.5, 169, 112, 24)];
        _payButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_payButton setTitle:@"支付" forState:UIControlStateNormal];
        [_payButton setTitleColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9] forState:UIControlStateNormal];
        [_payButton addTarget:self action:@selector(commitPay) forControlEvents:UIControlEventTouchUpInside];
    }
    return _payButton;
}

- (void)cancelPay {
    self.amount = 0;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)commitPay {
    if (self.amountTextField.text.length == 0) {
        return;
    }
    
    NSInteger amount = [self.amountTextField.text intValue];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    if (self.completeBlock) {
        self.completeBlock(amount);
    }
}
@end
