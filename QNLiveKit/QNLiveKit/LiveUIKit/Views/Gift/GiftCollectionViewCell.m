//
//  GiftCollectionViewCell.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//

#import "GiftCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "SendGiftModel.h"

@interface GiftCollectionViewCell()
/** bg */
@property(nonatomic,strong) UIView *bgView;
/** image */
@property(nonatomic,strong) UIImageView *giftImageView;
/** name */
@property(nonatomic,strong) UILabel *giftNameLabel;
/** money */
@property(nonatomic,strong) UILabel *moneyLabel;
/** moneyicon */
@property(nonatomic,strong) UIImageView *moneyImage;

@end

@implementation GiftCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self p_SetUI];
    }
    return self;
}

#pragma mark -设置UI
- (void)p_SetUI {
    
    self.bgView = [[UIView alloc] initWithFrame:self.bounds];
    self.bgView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:self.bgView];
    
    self.giftImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-70)*0.5, 11, 70, 55)];
    [self.contentView addSubview:self.giftImageView];
    
    self.giftNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.giftImageView.frame), self.bounds.size.width, 16)];
    self.giftNameLabel.text = @"礼物名";
    self.giftNameLabel.textColor = [UIColor whiteColor];
    self.giftNameLabel.textAlignment = NSTextAlignmentCenter;
    self.giftNameLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.giftNameLabel];
    
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.giftNameLabel.frame), 30, 16)];
    moneyLabel.textColor = [UIColor whiteColor];
    moneyLabel.font = [UIFont systemFontOfSize:12];
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    self.moneyLabel = moneyLabel;
    [self.contentView  addSubview:moneyLabel];
    
    UIImageView *moneyImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(moneyLabel.frame)-4, moneyLabel.frame.origin.y+4, 10, 10)];
    self.moneyImage = moneyImage;
    [self.contentView  addSubview:moneyImage];
}

- (void)setModel:(SendGiftModel *)model {
    
    _model = model;
    self.giftImageView.image = [UIImage imageNamed:model.giftImage];
//    [self.giftImageView sd_setImageWithURL:[NSURL URLWithString:model.giftImage] placeholderImage:[UIImage imageNamed:@""]];
    self.giftNameLabel.text = model.giftName;
    self.bgView.backgroundColor = model.isSelected ? [UIColor orangeColor] : [UIColor blackColor];
    UIImage *img = [UIImage imageNamed:@"Live_Red_ccb"];
    self.moneyImage.image = img;
    
    self.moneyLabel.text = model.giftPrice;
    
    CGSize size = [model.giftPrice sizeWithAttributes:@{NSFontAttributeName:self.moneyLabel.font}];
    CGFloat w = size.width+1;
    CGFloat labelX = (self.contentView.bounds.size.width-w+4+10)*0.5;
    self.moneyLabel.frame = CGRectMake(labelX, CGRectGetMaxY(self.giftNameLabel.frame), w, 16);
    CGFloat imageX = CGRectGetMinX(self.moneyLabel.frame)-4-10;
    self.moneyImage.frame = CGRectMake(imageX, self.moneyLabel.frame.origin.y+4, 10, 10);
}

@end
