//
//  QNAppReleaseInfoCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/13.
//

#import "QNAppReleaseInfoCell.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>

@interface QNAppReleaseInfoCell ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UILabel *releaseTimeTitleLabel;

@property (nonatomic, strong) UILabel *SDKVersionTitleLabel;

@property (nonatomic, strong) UILabel *releaseTimeLabel;

@property (nonatomic, strong) UILabel *SDKVersionLabel;

@end
@implementation QNAppReleaseInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        [self setBackgroundView:nil];
        [self bgView];
        [self releaseTimeTitleLabel];
        [self SDKVersionTitleLabel];
        [self releaseTimeLabel];
        [self SDKVersionLabel];
        
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = [UIColor colorWithHexString:@"EAEAEA"];
        [self.bgView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.releaseTimeTitleLabel);
            make.right.equalTo(self.bgView).offset(-25);
            make.top.equalTo(self.bgView.mas_top).offset(50);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
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

- (UILabel *)releaseTimeTitleLabel {
    if (!_releaseTimeTitleLabel) {
        _releaseTimeTitleLabel = [[UILabel alloc]init];
        _releaseTimeTitleLabel.text = @"发版时间";
        _releaseTimeTitleLabel.font = [UIFont systemFontOfSize:14];
        [self.bgView addSubview:_releaseTimeTitleLabel];
        
        [_releaseTimeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bgView).offset(25);
            make.top.equalTo(self.bgView).offset(15);
            make.height.mas_equalTo(20);
        }];
    }
    return _releaseTimeTitleLabel;
}

- (UILabel *)SDKVersionTitleLabel {
    if (!_SDKVersionTitleLabel) {
        _SDKVersionTitleLabel = [[UILabel alloc]init];
        _SDKVersionTitleLabel.text = @"SDK版本";
        _SDKVersionTitleLabel.font = [UIFont systemFontOfSize:14];
        [self.bgView addSubview:_SDKVersionTitleLabel];
        
        [_SDKVersionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.releaseTimeTitleLabel);
            make.top.equalTo(self.releaseTimeTitleLabel.mas_bottom).offset(25);
            make.height.mas_equalTo(20);
            make.bottom.equalTo(self.bgView.mas_bottom).offset(-15);
        }];
    }
    return _SDKVersionTitleLabel;
}

- (UILabel *)releaseTimeLabel {
    if (!_releaseTimeLabel) {
        _releaseTimeLabel = [[UILabel alloc]init];
        _releaseTimeLabel.text = @"2020.6.1";
        _releaseTimeLabel.textColor = [UIColor colorWithHexString:@"999999"];
        _releaseTimeLabel.textAlignment = NSTextAlignmentRight;
        _releaseTimeLabel.font = [UIFont systemFontOfSize:13];
        [self.bgView addSubview:_releaseTimeLabel];
        
        [_releaseTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bgView).offset(-25);
            make.top.equalTo(self.bgView).offset(15);
            make.height.mas_equalTo(20);
        }];
    }
    return _releaseTimeLabel;
}

- (UILabel *)SDKVersionLabel {
    if (!_SDKVersionLabel) {
        _SDKVersionLabel = [[UILabel alloc]init];
        NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        _SDKVersionLabel.text = currentVersion;
        _SDKVersionLabel.textColor = [UIColor colorWithHexString:@"999999"];
        _SDKVersionLabel.textAlignment = NSTextAlignmentRight;
        _SDKVersionLabel.font = [UIFont systemFontOfSize:13];
        [self.bgView addSubview:_SDKVersionLabel];
        
        [_SDKVersionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.releaseTimeLabel);
            make.top.equalTo(self.releaseTimeTitleLabel.mas_bottom).offset(25);
            make.height.mas_equalTo(20);
            make.bottom.equalTo(self.bgView.mas_bottom).offset(-15);
        }];
    }
    return _SDKVersionLabel;
}

@end
