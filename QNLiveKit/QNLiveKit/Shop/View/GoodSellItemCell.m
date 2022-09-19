//
//  GoodSellItemCell.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/13.
//

#import "GoodSellItemCell.h"
#import "GoodsModel.h"
#import "QAlertView.h"
#import "QTagList.h"
#import "QToastView.h"
#import "QShopService.h"

@interface GoodSellItemCell ()

{
    
    NSTimer * _timer;  //定时器
    
    NSInteger _seconds;
    
}
//商品图
@property (nonatomic,strong)UIImageView *iconImageView;
//下架覆盖层
@property (nonatomic,strong) UIButton *downView;
//商品序号
@property (nonatomic,strong)UILabel *orderLabel;
//商品名称
@property (nonatomic,strong)UILabel *titleLabel;
//标签
@property (nonatomic,strong)UILabel *tagLabel;
//现价
@property (nonatomic,strong)UILabel *currentPriceLabel;
//原价
@property (nonatomic,strong)UILabel *originPriceLabel;
//下架按钮
@property (nonatomic,strong)UIButton *takeDownButton;
//录制按钮
@property (nonatomic,strong)UIButton *recordButton;
//讲解按钮
@property (nonatomic,strong)UIButton *explainButton;

//录制状态的图片
@property (nonatomic,strong)UIImageView *recordStatusImageView;



@property (nonatomic, strong)QTagList *tagList;

@property (nonatomic,strong)GoodsModel *itemModel;

@end

@implementation GoodSellItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click)];
        [self.contentView addGestureRecognizer:tap];
        self.contentView.userInteractionEnabled = YES;
        [self iconImageView];
        [self downView];
        [self orderLabel];
        [self titleLabel];
        [self tagList];
        [self currentPriceLabel];
        [self originPriceLabel];
        [self takeDownButton];
        [self recordButton];
        [self recordStatusImageView];
        [self explainButton];
        
    }
    return self;
}

//商品被点击
- (void)click {
    if(self.goodClickedBlock) {
        self.goodClickedBlock(self.itemModel);
    }
}

- (void)updateWithModel:(GoodsModel *)itemModel {
    self.itemModel = itemModel;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:itemModel.thumbnail]];
    self.titleLabel.text = itemModel.title;
    self.orderLabel.text = itemModel.order;
    if (self.tagList.tagArray.count == 0) {
        [self.tagList addTags: [itemModel.tags componentsSeparatedByString:@","]];
    }    
    self.currentPriceLabel.text = itemModel.current_price;
    self.originPriceLabel.text = itemModel.origin_price;
    
    if (itemModel.status == QLiveGoodsStatusTakeOn) {
        self.downView.hidden = YES;
        [self.takeDownButton setTitle:@"下架商品" forState:UIControlStateNormal];
    } else {
        self.downView.hidden = NO;
        [self.takeDownButton setTitle:@"上架商品" forState:UIControlStateNormal];
    }
    
    self.recordButton.selected = !(itemModel.record.record_url.length == 0);
    
    UIColor *explainButtonTitleColor;
    NSString *explainButtonTitle;
    
    if (itemModel.isExplaining || itemModel.record.record_url.length > 0) {
        self.recordButton.hidden = NO;
    } else {
        self.recordButton.hidden = YES;
    }
    
    //录制按钮
    if (itemModel.record.record_url.length > 0) {
        self.recordStatusImageView.hidden = NO;
        self.recordStatusImageView.image = [UIImage imageNamed:@"recorded_icon"];
        [self.recordButton setTitle:@"00:22" forState:UIControlStateNormal];
    } else {
        [self.recordButton setTitle:@"录制" forState:UIControlStateNormal];
        self.recordStatusImageView.hidden = YES;
    }
        
    if (itemModel.isExplaining) {
        
        explainButtonTitle = @"结束讲解";
        self.explainButton.backgroundColor = [UIColor colorWithHexString:@"F5F5F5"];
        explainButtonTitleColor = [UIColor colorWithHexString:@"E34D59"];
        self.explainButton.userInteractionEnabled = YES;
        self.recordButton.hidden = NO;
        
    } else {
        //讲解按钮
        if (itemModel.status == QLiveGoodsStatusTakeOn) {
            self.explainButton.backgroundColor = [UIColor colorWithHexString:@"E34D59"];
            self.explainButton.userInteractionEnabled = YES;
        } else {
            self.explainButton.backgroundColor = [[UIColor colorWithHexString:@"E34D59"] colorWithAlphaComponent:0.4];
            self.explainButton.userInteractionEnabled = NO;
        }
        explainButtonTitle = @"讲解";
        explainButtonTitleColor = [UIColor whiteColor];
        
    }
        
    [self.explainButton setTitle:explainButtonTitle forState:UIControlStateNormal];
    [self.explainButton setTitleColor:explainButtonTitleColor forState:UIControlStateNormal];
}

//下架按钮点击
- (void)takeDown:(UIButton *)button {
    
    NSString *title = self.itemModel.status == QLiveGoodsStatusTakeOn ? @"确定下架该商品吗？" : @"确定上架该商品吗？";
    
    [QAlertView showBaseAlertWithTitle:title content:@"" cancelHandler:^(UIAlertAction * _Nonnull action) {
        
    } confirmHandler:^(UIAlertAction * _Nonnull action) {
        
        if (self.takeDownClickedBlock) {
            self.takeDownClickedBlock(self.itemModel);
        }
    }];
    
}

//讲解按钮点击
- (void)explain:(UIButton *)button {
    self.itemModel.isExplaining = !self.itemModel.isExplaining;
    if (!self.itemModel.isExplaining) {
        [_timer invalidate];
    } else {
        
    }
    if (self.explainClickedBlock) {
        self.explainClickedBlock(self.itemModel);
    }
}

//录制按钮点击
- (void)record:(UIButton *)button {
    
    //讲解时才可以删除上一次录制
    if (self.itemModel.isExplaining == NO) {
        return;
    }
    
    button.selected = !button.selected;
    if (button.selected) {
        [QToastView showToast:@"已开始录制"];
        self.recordStatusImageView.hidden = NO;
        self.recordStatusImageView.image = [UIImage imageNamed:@"recording_icon"];
        self.recordButton.userInteractionEnabled = NO;
        [self.recordButton setTitle:@"  00:00" forState:UIControlStateNormal];
        //计时
        _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        if (self.recordClickedBlock) {
            self.recordClickedBlock(self.itemModel);
        }
    } else {
        
        [QAlertView showBaseAlertWithTitle:@"确定删除商品讲解录像吗？" content:@"" cancelHandler:^(UIAlertAction * _Nonnull action) {
                    
                } confirmHandler:^(UIAlertAction * _Nonnull action) {
                    
                    if (self.recordClickedBlock) {
                        self.recordClickedBlock(self.itemModel);
                    }
                    button.selected = NO;
                    [self record:button];
                    
                }];
    }
            
}

- (void)runAction
{
    _seconds++;
    NSString * startTime=[NSString stringWithFormat:@"  %02li:%02li",_seconds/100%60,_seconds%100];
    [self.recordButton setTitle:startTime forState:UIControlStateNormal];
    
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.cornerRadius = 10;
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.backgroundColor = [UIColor colorWithHexString:@"E34D59"];
        [self.contentView addSubview:_iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.top.equalTo(self.contentView).offset(5);
            make.width.height.mas_equalTo(80);
        }];
    }
    return _iconImageView;
}

- (UIButton *)downView {
    if (!_downView) {
        _downView = [[UIButton alloc]init];
        _downView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
        [_downView setTitle:@"下架已隐藏" forState:UIControlStateNormal];
        _downView.clipsToBounds = YES;
        _downView.layer.cornerRadius = 10;
        [_downView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _downView.titleLabel.font = [UIFont systemFontOfSize:12];
        _downView.hidden = YES;
        [self.contentView addSubview:_downView];
        
        [_downView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(self.iconImageView);
        }];
    }
    return _downView;
}

- (UILabel *)orderLabel {
    if (!_orderLabel) {
        _orderLabel = [[UILabel alloc]init];
        _orderLabel.backgroundColor = [[UIColor colorWithHexString:@"000000"] colorWithAlphaComponent:0.6];
        _orderLabel.textColor = [UIColor whiteColor];
        _orderLabel.textAlignment = NSTextAlignmentCenter;
        _orderLabel.clipsToBounds = YES;
        _orderLabel.font = [UIFont systemFontOfSize:8];
        [self.iconImageView addSubview:_orderLabel];
        [_orderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.iconImageView);
            make.width.mas_equalTo(25);
            make.height.mas_equalTo(20);
        }];
    }
    return _orderLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(15);
            make.right.equalTo(self.contentView.mas_right).offset(-15);
            make.top.equalTo(self.iconImageView);
        }];
    }
    return _titleLabel;
}

- (QTagList *)tagList {
    if (!_tagList) {
        _tagList = [[QTagList alloc] init];
        _tagList.backgroundColor = [UIColor whiteColor];
        _tagList.frame = CGRectMake(110, 25, 250, 0);
        _tagList.tagBackgroundColor = [UIColor orangeColor];
        _tagList.tagColor = [UIColor whiteColor];
        _tagList.tagButtonMargin = 2;
        _tagList.tagMargin = 5;
        _tagList.tagSize = CGSizeMake(40, 0);
        _tagList.tagFont = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:_tagList];
    }
    return _tagList;
}

- (UILabel *)currentPriceLabel {
    if (!_currentPriceLabel) {
        _currentPriceLabel = [[UILabel alloc]init];
        _currentPriceLabel.textColor = [UIColor colorWithHexString:@"E34D59"];
        _currentPriceLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_currentPriceLabel];
        [_currentPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(15);
            make.bottom.equalTo(self.iconImageView.mas_bottom);
        }];
    }
    return _currentPriceLabel;
}

- (UILabel *)originPriceLabel {
    if (!_originPriceLabel) {
        _originPriceLabel = [[UILabel alloc]init];
        _originPriceLabel.textColor = [UIColor grayColor];
        _originPriceLabel.font = [UIFont systemFontOfSize:12];
        
        [self.contentView addSubview:_originPriceLabel];
        
        [_originPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.currentPriceLabel.mas_right).offset(5);
            make.bottom.equalTo(self.currentPriceLabel);
        }];
        
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor grayColor];
        [_originPriceLabel addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.originPriceLabel);
            make.left.right.equalTo(self.originPriceLabel);
            make.height.mas_equalTo(1);
        }];
    }
    return _originPriceLabel;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [[UIButton alloc]init];
        _recordButton.backgroundColor = [UIColor colorWithHexString:@"F5F5F5"];
        _recordButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_recordButton setTitle:@"录制" forState:UIControlStateNormal];
        [_recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_recordButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
        _recordButton.hidden = YES;
        [self.contentView addSubview:_recordButton];
        [_recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.explainButton.mas_left).offset(-10);
            make.top.equalTo(self.iconImageView.mas_bottom).offset(10);
            make.width.mas_equalTo(70);
            make.height.mas_equalTo(25);
        }];
        
    }
    return _recordButton;
}

- (UIImageView *)recordStatusImageView {
    if (!_recordStatusImageView) {
        _recordStatusImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"recording_icon"]];
        [self.recordButton addSubview:_recordStatusImageView];
        _recordStatusImageView.hidden = YES;
        [_recordStatusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.recordButton);
            make.left.equalTo(self.recordButton).offset(4);
            make.width.height.mas_equalTo(10);
        }];
    }
    return _recordStatusImageView;
}

- (UIButton *)takeDownButton {
    if (!_takeDownButton) {
        _takeDownButton = [[UIButton alloc]init];
        _takeDownButton.backgroundColor = [UIColor colorWithHexString:@"F5F5F5"];
        _takeDownButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_takeDownButton setTitle:@"下架商品" forState:UIControlStateNormal];
        [_takeDownButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_takeDownButton addTarget:self action:@selector(takeDown:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_takeDownButton];
        [_takeDownButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.iconImageView);
            make.top.equalTo(self.iconImageView.mas_bottom).offset(10);
            make.width.mas_equalTo(70);
            make.height.mas_equalTo(25);
        }];
    }
    return _takeDownButton;
}

- (UIButton *)explainButton {
    if (!_explainButton) {
        _explainButton = [[UIButton alloc]init];
        _explainButton.backgroundColor = [UIColor colorWithHexString:@"E34D59"];
        _explainButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_explainButton setTitle:@"讲解" forState:UIControlStateNormal];
        [_explainButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_explainButton addTarget:self action:@selector(explain:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_explainButton];
        [_explainButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.takeDownButton);
            make.right.equalTo(self.contentView.mas_right).offset(-15);
            make.width.mas_equalTo(75);
            make.height.mas_equalTo(25);
        }];
    }
    return _explainButton;
}


@end
