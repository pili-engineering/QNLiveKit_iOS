//
//  QNVoiceCollectionViewCell.h
//  QNRTCLiveDemo
//
//  Created by sunmu on 2023/01/10.
//  Copyright © 2023 sunmu. All rights reserved.
//

#import "QNVoiceCollectionViewCell.h"

@implementation QNVoiceCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_add_audio"]];
        self.avatarImageView.frame = self.bounds;
        self.avatarImageView.clipsToBounds = YES;
        self.avatarImageView.layer.cornerRadius = 50;
        [self.contentView addSubview:_avatarImageView];
        
        self.renderView = [[QRenderView alloc] initWithFrame:self.bounds];
        self.renderView.clipsToBounds = YES;
        self.renderView.layer.cornerRadius = 50;
        self.renderView.fillMode = QNVideoFillModeStretch;
        [self addSubview:self.renderView];
        
        self.microphoneButtonView = [[UIButton alloc] initWithFrame:CGRectMake(42, 88, 12, 12)];
        [self.microphoneButtonView setImage:[UIImage imageNamed:@"icon_Voice_status_0"] forState:UIControlStateNormal];
        [self.microphoneButtonView setImage:[UIImage imageNamed:@"icon_Voice_status_1"] forState:UIControlStateSelected];
        self.microphoneButtonView.selected = YES;
        [self.renderView addSubview:_microphoneButtonView];
        self.microphoneButtonView.hidden = YES;
       
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 73, 76, 15)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
        self.titleLabel.text = @"虚位以待";
        self.titleLabel.lineBreakMode= NSLineBreakByTruncatingMiddle;
//        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)configurateCollectionViewWithModle:(QNMicLinker *)micLinker{
    NSString *name = @"七牛";
    if (micLinker.user.nick && micLinker.user.nick.length != 0) {
        name = micLinker.user.nick;
    }
    if (micLinker.user.im_username && micLinker.user.im_username != 0) {
        name = micLinker.user.im_username;
    }
    NSString *imageString = @"icon_default_avator.png";
    if (micLinker.user.avatar && micLinker.user.avatar.length != 0) {
        imageString = micLinker.user.avatar;
    }
    if ([micLinker.track isKindOfClass:[QNRemoteVideoTrack class]]) {
        QNRemoteVideoTrack *track = (QNRemoteVideoTrack *)micLinker.track;
        [track play:_renderView];
    }

    if ([micLinker.track isKindOfClass:[QNLocalVideoTrack class]]) {
        QNLocalVideoTrack *track = (QNLocalVideoTrack *)micLinker.track;
        [track play:_renderView];
    }

    [self configurateCollectionViewCell:name avatar:micLinker.user.avatar state:micLinker.mic];
    
}

- (void)configurateCollectionViewCell:(NSString *)name avatar:(NSString *)avatar state:(BOOL)state {
    self.microphoneButtonView.hidden = NO;
    self.microphoneButtonView.selected = state;
    
    if ([avatar hasPrefix:@"https"] || [avatar hasPrefix:@"http"]) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatar]];
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        if ([avatar isEqual:@"icon_default_avator"]) {
            self.avatarImageView.image = [UIImage imageNamed:avatar];
            self.titleLabel.textColor = [UIColor whiteColor];
        } else {
            self.avatarImageView.image = [UIImage imageNamed:avatar];
            self.titleLabel.textColor = [UIColor colorWithRed:131/255 green:131/255  blue:131/255 alpha:1.0];
        }
    }
    self.titleLabel.text = name;
}
@end
