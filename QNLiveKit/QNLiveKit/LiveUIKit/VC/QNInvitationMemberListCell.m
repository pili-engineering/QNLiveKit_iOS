//
//  QNMovieMemberListCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/8.
//

#import "QNInvitationMemberListCell.h"
#import "QNLiveUser.h"
#import "QNLiveRoomInfo.h"

@interface QNInvitationMemberListCell ()

@property (nonatomic,strong)UIImageView *iconImageView;

@property (nonatomic,strong)UILabel *titleLabel;

@property (nonatomic,strong)UIImageView *selectImageView;

@property (nonatomic,strong) QNLiveRoomInfo *model;

@end

@implementation QNInvitationMemberListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(itemClieked)];
        self.contentView.userInteractionEnabled = YES;
        [self.contentView addGestureRecognizer:tap];
        
        [self iconImageView];
        [self titleLabel];
        [self selectImageView];
    }
    return self;
}

- (void)itemClieked {
    if (self.listClickedBlock) {
        self.listClickedBlock(self.model);
    }
}

- (void)setItemModel:(QNLiveRoomInfo *)itemModel {
    self.model = itemModel;
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:itemModel.anchor_info.avatar] placeholderImage:[UIImage imageNamed:@"titleImage"]];
    _titleLabel.text = itemModel.anchor_info.nick;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.cornerRadius = 17;
        [self.contentView addSubview:_iconImageView];
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.top.equalTo(self.contentView).offset(5);
            make.width.height.mas_equalTo(34);
        }];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(15);
            make.centerY.equalTo(self.iconImageView);
        }];
    }
    return _titleLabel;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"invitation_pk"]];
        [self.contentView addSubview:_selectImageView];
        [_selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.iconImageView);
            make.right.equalTo(self.contentView).offset(-20);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(itemClieked)];
        _selectImageView.userInteractionEnabled = YES;
        [_selectImageView addGestureRecognizer:tap];
    }
    return _selectImageView;
}


@end
