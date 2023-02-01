//
//  QNVoiceCollectionViewCell.h
//  QNRTCLiveDemo
//
//  Created by sunmu on 2023/01/10.
//  Copyright © 2023 sunmu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRenderView.h"
#import <QNLiveKit/QNLiveKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNVoiceCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton *microphoneButtonView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) QRenderView *renderView;

- (void)configurateCollectionViewWithModle:(QNMicLinker *)micLinker;



@end

NS_ASSUME_NONNULL_END
