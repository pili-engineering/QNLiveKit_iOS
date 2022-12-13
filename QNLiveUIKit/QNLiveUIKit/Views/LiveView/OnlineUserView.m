//
//  OnlineUserView.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/31.
//

#import "OnlineUserView.h"

static const CGFloat countLabel_H = 15;//数字高

@interface OnlineUserView ()

@property (nonatomic, strong)UILabel *countLabel;//房间人数

@property (nonatomic, strong)UILabel *liveIDLabel;
@end

@implementation OnlineUserView

//默认
- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        UIView *countBgView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width - 60, 0, 40, 40)];
        
        countBgView.backgroundColor = [UIColor whiteColor];
        countBgView.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25].CGColor;
        countBgView.layer.cornerRadius = 20;
        
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (countBgView.frame.size.height - countLabel_H)/2, countBgView.frame.size.width, countLabel_H)];
        self.countLabel.textAlignment = NSTextAlignmentCenter;
        self.countLabel.textColor = [UIColor whiteColor];
        self.countLabel.font = [UIFont systemFontOfSize:14];
        [countBgView addSubview:self.countLabel];
        
        self.liveIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, frame.size.width - 15, 10)];
        self.liveIDLabel.textAlignment = NSTextAlignmentRight;
        self.liveIDLabel.textColor = [UIColor whiteColor];
        self.liveIDLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:self.liveIDLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click)];
        countBgView.userInteractionEnabled = YES;
        [countBgView addGestureRecognizer:tap];
        
        [self addSubview:countBgView];
        
    }
        
    return self;
}

- (void)click {
    if (self.clickBlock) {
        self.clickBlock(YES);
    }
}

- (void)updateWith:(QNLiveRoomInfo *)roomInfo {
    self.countLabel.text = roomInfo.online_count ?: @"0";
    self.liveIDLabel.text = roomInfo.live_id ?: @"";
}


@end
