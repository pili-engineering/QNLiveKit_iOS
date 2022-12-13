//
//  QNLiveListCell.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import "QNLiveListCell.h"
#import <QNLiveKit/QNLiveKit.h>
#import "QGradient.h"

@interface QNLiveListCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *bg;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *numLabel;

@end

@implementation QNLiveListCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self imageView];
        [self bg];
        [self nameLabel];
        [self numLabel];
        
    }
    return self;
}

- (void)updateWithModel:(QNLiveRoomInfo *)model {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.cover_url] placeholderImage:[UIImage imageNamed:@"titleImage"]];
    self.nameLabel.text = model.title;
    self.numLabel.text = model.total_count;
}


- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.layer.cornerRadius = 5;
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.contentView).offset(5);
            make.right.bottom.equalTo(self.contentView).offset(5);
        }];
    }
    return _imageView;
}

- (UIView *)bg {
    if (!_bg) {
        _bg = [[UIView alloc]initWithFrame:CGRectMake(5, self.contentView.frame.size.height - 45, self.contentView.frame.size.width, 50)];
        [self.contentView addSubview:_bg];
        
        [QGradient setTopToBottomGradientColor:[UIColor blackColor] view:_bg];
    }
    return _bg;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        [self.bg addSubview:_nameLabel];
        
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.bottom.equalTo(self.imageView).offset(-15);
        }];
    }
    return _nameLabel;
}

- (UILabel *)numLabel {
    if (!_numLabel) {
        _numLabel = [[UILabel alloc]init];
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.font = [UIFont systemFontOfSize:13];
        [self.bg addSubview:_numLabel];
        
        [_numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-10);
            make.bottom.equalTo(self.imageView).offset(-15);
        }];
    }
    return _numLabel;
}


@end
