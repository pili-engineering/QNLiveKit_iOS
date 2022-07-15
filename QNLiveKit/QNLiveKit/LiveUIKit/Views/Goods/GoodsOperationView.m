//
//  GoodsOperationView.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/15.
//

#import "GoodsOperationView.h"

@interface GoodsOperationView ()

@property (nonatomic,strong)UIButton *takeOnButton;

@property (nonatomic,strong)UIButton *takeDownButton;

@property (nonatomic,strong)UIButton *removeButton;

@end

@implementation GoodsOperationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 0.5)];
        line.backgroundColor = [UIColor colorWithHexString:@"E5E5E5"];
        [self addSubview:line];
        
        [self takeOnButton];
        [self takeDownButton];
        [self removeButton];
    }
    return self;
}

- (void)takeOnClick {
    if (self.takeOnClickedBlock) {
        self.takeOnClickedBlock();
    }
}

- (void)takeDownClick {
    if (self.takeDownClickedBlock) {
        self.takeDownClickedBlock();
    }
}

- (void)removeClick {
    if (self.removeClickedBlock) {
        self.removeClickedBlock();
    }
}

- (UIButton *)takeOnButton {
    if (!_takeOnButton) {
        _takeOnButton = [[UIButton alloc]init];
        [_takeOnButton setTitle:@"上架" forState:UIControlStateNormal];
        [_takeOnButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_takeOnButton addTarget:self action:@selector(takeOnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_takeOnButton];
        [_takeOnButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self);
            make.width.mas_equalTo(SCREEN_W/3);
            make.height.mas_equalTo(self.frame.size.height);
        }];
    }
    return _takeOnButton;
}

- (UIButton *)takeDownButton {
    if (!_takeDownButton) {
        _takeDownButton = [[UIButton alloc]init];
        [_takeDownButton setTitle:@"下架" forState:UIControlStateNormal];
        [_takeDownButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_takeDownButton addTarget:self action:@selector(takeDownClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_takeDownButton];
        [_takeDownButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.takeOnButton.mas_right).offset(0);
            make.width.mas_equalTo(SCREEN_W/3);
            make.height.mas_equalTo(self.frame.size.height);
        }];
    }
    return _takeDownButton;
}

- (UIButton *)removeButton {
    if (!_removeButton) {
        _removeButton = [[UIButton alloc]init];
        [_removeButton setTitle:@"移除" forState:UIControlStateNormal];
        [_removeButton setTitleColor:[UIColor colorWithHexString:@"EF4149"] forState:UIControlStateNormal];
        [_removeButton addTarget:self action:@selector(removeClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_removeButton];
        [_removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.takeDownButton.mas_right).offset(0);
            make.width.mas_equalTo(SCREEN_W/3);
            make.height.mas_equalTo(self.frame.size.height);
        }];
    }
    return _removeButton;
}
@end
