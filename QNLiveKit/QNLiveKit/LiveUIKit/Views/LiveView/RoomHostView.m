//
//  RoomHostView.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/31.
//

#import "RoomHostView.h"
#import "QNLiveRoomInfo.h"
#import "QNLiveUser.h"
#import <SDWebImage/SDWebImage.h>
#import <UIKit/UIKit.h>

static const CGFloat RoomNameLabel_W = 80;//名字宽 -
static const CGFloat RoomNameLabel_H = 15;//名字高 -
static const CGFloat RoomNameLabel_L = 5;//名字左间距
static const CGFloat RoomNameLabel_T = 5;//名字上间距
static const CGFloat People_Count_Icon_W = 10;//人数icon宽高
static const CGFloat People_Count_Icon_T = 5;//人数icon上间距
static const CGFloat People_Count_W = 80;//人数宽
static const CGFloat People_Count_H = 10;//人数高
static const CGFloat People_Count_T = 5;//人数上间距
static const CGFloat People_Count_L = 5;//人数左间距

@interface RoomHostView ()

@property (nonatomic, strong)UIImageView *avatarView;//房主头像
@property (nonatomic, strong)UILabel *roomNameLabel;//房间名
@property (nonatomic, strong)UIImageView *countImgView;
@property (nonatomic, strong)UILabel *hostNameLabel;//房主名

@end

@implementation RoomHostView

//默认
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25].CGColor;
        self.layer.cornerRadius = frame.size.height/2;
        
        self.avatarView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.height)];
        self.avatarView.layer.cornerRadius = frame.size.height/2;
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.avatarView];
        
        self.roomNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.avatarView.frame)+RoomNameLabel_L, RoomNameLabel_T, RoomNameLabel_W, RoomNameLabel_H)];
        self.roomNameLabel.textColor = [UIColor whiteColor];
        self.roomNameLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.roomNameLabel];
        
        self.countImgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.avatarView.frame)+RoomNameLabel_L, CGRectGetMaxY(self.roomNameLabel.frame)+People_Count_Icon_T, People_Count_Icon_W, People_Count_Icon_W)];
        self.countImgView.image = [UIImage imageNamed:@"people"];
        [self addSubview:self.countImgView];
        
        self.hostNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.countImgView.frame)+People_Count_L, CGRectGetMaxY(self.roomNameLabel.frame)+People_Count_T, People_Count_W, People_Count_H)];
        self.hostNameLabel.textColor = [UIColor whiteColor];
        self.hostNameLabel.font = [UIFont systemFontOfSize:9];
        [self addSubview:self.hostNameLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
        
    }

    return self;

}

- (void)click {
    if (self.clickBlock) {
        self.clickBlock(YES);
    }
}

- (void)updateWith:(QNLiveRoomInfo *)roomInfo {

    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:roomInfo.anchor_info.avatar] placeholderImage:[UIImage imageNamed:@"titleImage"]];
    self.roomNameLabel.text = roomInfo.title ?: @"房间名";
    self.hostNameLabel.text = roomInfo.anchor_info.nick ?: @"";
}

@end
