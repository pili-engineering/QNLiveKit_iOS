//
//  QNQuitLoginCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/27.
//

#import "QNQuitLoginCell.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>

@interface QNQuitLoginCell ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UILabel *quitLabel;
@end

@implementation QNQuitLoginCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        [self setBackgroundView:nil];
        [self bgView];
        [self quitLabel];
        
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.image = [UIImage imageNamed:@"icon_next"];
        [self.bgView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bgView).offset(-20);
            make.top.equalTo(self.bgView).offset(15);
        }];

    }
    return self;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc]initWithFrame:CGRectMake(5, 5, kScreenWidth - 40, 50)];
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

- (UILabel *)quitLabel {
    if (!_quitLabel) {
        _quitLabel = [[UILabel alloc]init];
        _quitLabel.text = @"退出登录";
        _quitLabel.font = [UIFont systemFontOfSize:14];
        [self.bgView addSubview:_quitLabel];
        
        [_quitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bgView).offset(25);
            make.top.equalTo(self.bgView).offset(15);
            make.height.mas_equalTo(20);
        }];
    }
    return _quitLabel;
}

@end
