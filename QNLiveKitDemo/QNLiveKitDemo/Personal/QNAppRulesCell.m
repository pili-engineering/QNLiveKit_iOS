//
//  QNPersonInfoCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/8.
//

#import "QNAppRulesCell.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>

@interface QNAppRulesCell ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UILabel *privacyLabel;

@property (nonatomic, strong) UILabel *disclaimerLabel;

@end

@implementation QNAppRulesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        [self setBackgroundView:nil];
        [self bgView];
        [self privacyLabel];
        [self disclaimerLabel];
        
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = [UIColor colorWithHexString:@"EAEAEA"];
        [self.bgView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.privacyLabel);
            make.right.equalTo(self.bgView).offset(-25);
            make.top.equalTo(self.bgView.mas_top).offset(50);
            make.height.mas_equalTo(1);
        }];
        
        for (int i = 0 ; i < 2; i++) {
            UIImageView *imageView = [[UIImageView alloc]init];
            imageView.image = [UIImage imageNamed:@"icon_next"];
            [self.bgView addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.bgView).offset(-20);
                make.top.equalTo(self.bgView).offset(15 + 50 * i);
            }];
        }
    }
    return self;
}

- (void)policy {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:QN_POLICY_URL]];
}

- (void)agreement {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:QN_AGREEMENT_URL]];
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc]initWithFrame:CGRectMake(5, 5, kScreenWidth - 40, 100)];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 5;
        _bgView.layer.shadowColor = [UIColor blackColor].CGColor;
        _bgView.layer.shadowOffset = CGSizeMake(0,0);
        _bgView.layer.shadowOpacity = 0.3;
        _bgView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_bgView.bounds byRoundingCorners:5 cornerRadii:CGSizeMake(0, 0)].CGPath;
        [self.contentView addSubview:_bgView];
    }
    return _bgView;
}

- (UILabel *)privacyLabel {
    if (!_privacyLabel) {
        _privacyLabel = [[UILabel alloc]init];
        _privacyLabel.text = @"隐私权政策";
        _privacyLabel.font = [UIFont systemFontOfSize:14];
        [self.bgView addSubview:_privacyLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(policy)];
        _privacyLabel.userInteractionEnabled = YES;
        [_privacyLabel addGestureRecognizer:tap];
        
        [_privacyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bgView).offset(25);
            make.top.equalTo(self.bgView);
            make.height.mas_equalTo(50);
            make.right.equalTo(self.bgView);
        }];
    }
    return _privacyLabel;
}

- (UILabel *)disclaimerLabel {
    if (!_disclaimerLabel) {
        _disclaimerLabel = [[UILabel alloc]init];
        _disclaimerLabel.text = @"服务用户协议";
        _disclaimerLabel.font = [UIFont systemFontOfSize:14];
        [self.bgView addSubview:_disclaimerLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreement)];
        _disclaimerLabel.userInteractionEnabled = YES;
        [_disclaimerLabel addGestureRecognizer:tap];
        
        [_disclaimerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.privacyLabel);
            make.top.equalTo(self.privacyLabel.mas_bottom);
            make.height.mas_equalTo(50);
            make.right.equalTo(self.bgView);
        }];
    }
    return _disclaimerLabel;
}
@end
