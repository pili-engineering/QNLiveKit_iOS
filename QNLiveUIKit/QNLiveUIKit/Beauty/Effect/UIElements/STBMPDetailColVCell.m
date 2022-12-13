
//
//  STBMPDetailColVCell.m
//  SenseMeEffects
//
//  Created by sensetimesunjian on 2019/5/10.
//  Copyright © 2019 SenseTime. All rights reserved.
//

#import "STBMPDetailColVCell.h"

@implementation STBMPDetailColVCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.m_icon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
        [self addSubview:self.m_icon];
        self.m_icon.layer.borderWidth = 2.0f;
        self.m_icon.layer.cornerRadius = 50/2;
        self.m_icon.layer.masksToBounds = YES;
        
        //add doenloading image
        self.m_downloading = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self addSubview:self.m_downloading];
        self.m_downloading.center = self.m_icon.center;
        self.m_downloading.image = [UIImage imageNamed:@"loader"];
        self.m_downloading.hidden = YES;
        
        //add download image
        self.m_download = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 25, self.frame.size.height - 40, 20, 20)];
        [self addSubview:self.m_download];
        self.m_download.image = [UIImage imageNamed:@"download"];

        self.m_labelName = [[UILabel alloc] initWithFrame:CGRectMake(0,  CGRectGetMaxY(self.m_icon.frame), self.frame.size.width, 20)];
        self.m_labelName.textAlignment = NSTextAlignmentCenter;
        self.m_labelName.textColor = [UIColor whiteColor];
        self.m_labelName.font = [UIFont systemFontOfSize:14];
        self.m_labelName.backgroundColor = [UIColor clearColor];
        [self addSubview:self.m_labelName];
        CGPoint m_labelNameCenter = self.m_labelName.center;
        self.m_icon.center = CGPointMake(m_labelNameCenter.x, 25);
    }
    
    return self;
}

- (void)setName:(NSString *)name{
    self.m_labelName.text = name;
}

- (void)setIcon:(id)icon{
    if (!icon) return;
    if ([icon isMemberOfClass:[UIImage class]]){
        [self.m_icon setImage:(UIImage *)icon];
    }else if([icon isKindOfClass:[NSString class]]){
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", icon]];
        [self.m_icon setImage:image];
    }
}

- (void)setState:(STState)state{
    switch (state) {
        case STStateNotNeedDownload:
            self.m_download.hidden = YES;
            self.m_downloading.hidden = YES;
            break;
        case STStateNeedDownlad:
            self.m_download.hidden = NO;
            self.m_downloading.hidden = YES;
            break;
        case STStateDownloading:
            [self startDownloadAnimation];
            break;
        case STStateDownloaded:
            [self stopDownloadAnimation];
            break;
        default:
            break;
    }
}

- (void)startDownloadAnimation
{
    self.m_download.hidden = YES;
    self.m_downloading.hidden = NO;
    [self.m_downloading.layer removeAnimationForKey:@"rotation"];
    
    CABasicAnimation *circleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    circleAnimation.duration = 2.5f;
    circleAnimation.repeatCount = MAXFLOAT;
    circleAnimation.toValue = @(M_PI * 2);
    [self.m_downloading.layer addAnimation:circleAnimation forKey:@"rotation"];
}

- (void)stopDownloadAnimation
{
    self.m_download.hidden = YES;
    self.m_downloading.hidden = YES;
    [self.m_downloading.layer removeAnimationForKey:@"rotation"];
}

- (void)setDidSelected:(BOOL)didSelected;
{
    if (didSelected) {
        _m_icon.layer.borderColor = [UIColor purpleColor].CGColor;
    }else{
        _m_icon.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
