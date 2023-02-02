//
//  QNLikeSlotView.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/24.
//

#import "QNLikeMenuView.h"

@interface QNLikeMenuView ()

@property (nonatomic, copy) UILabel *totalLabel;
@property (nonatomic, strong) QStatisticalService *statService;

@property (nonatomic, assign) NSInteger lastFetchTime;
@property (nonatomic, strong) dispatch_queue_t fetchQueue;

@end

@implementation QNLikeMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.totalLabel];
        self.fetchQueue = dispatch_queue_create("com.qiniu.livekit.likemenu", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)didMoveToSuperview {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIMMessageNotification:) name:ReceiveIMMessageNotification object:nil];
}

- (void)removeFromSuperview {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(11);
        make.top.equalTo(self).offset(5);
        make.centerX.equalTo(self);
    }];
}

- (void)setTotal:(NSInteger)total {
    NSLog(@"sunmu---点赞数 （%d）",total);
    if (total == 0) {
        [self.totalLabel setHidden:YES];
    } else {
        NSString *text = [NSString stringWithFormat:@"%ld", total];
        if (total >= 10000) {
            CGFloat w = (double)total / 10000.0;
            text = [NSString stringWithFormat:@"%.1fw", w];
        }
        
        self.totalLabel.text = text;
        [self.totalLabel setHidden:NO];
    }
}

- (UILabel *)totalLabel {
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        [_totalLabel setBackgroundColor:[UIColor whiteColor]];
        [_totalLabel.layer setMasksToBounds:YES];
        [_totalLabel.layer setCornerRadius:5];
        
        [_totalLabel setFont:[UIFont systemFontOfSize:11]];
        [_totalLabel setTextColor:[UIColor colorWithHexString:@"#EF4149"]];
        [_totalLabel setTextAlignment:NSTextAlignmentCenter];
        
        [_totalLabel setHidden:YES];
    }
    return _totalLabel;
}

- (void)setRoomInfo:(QNLiveRoomInfo *)roomInfo {
    _roomInfo = roomInfo;
    _statService = [[QStatisticalService alloc] init];
    _statService.roomInfo = roomInfo;
    
    [self fetchRoomLike];
}

- (void)fetchRoomLike {
    if (!self.statService) {
        return;
    }
    
    
    __block BOOL needFetch = NO;
    dispatch_sync(self.fetchQueue, ^{
        NSInteger now = (NSInteger)[[NSDate date] timeIntervalSince1970];
        if (now - self.lastFetchTime > 2) {
            self.lastFetchTime = NO;
            needFetch = YES;
        }
    });
    if (!needFetch) {
        return;
    }
    
    [self.statService getRoomData:^(NSArray<QRoomDataModel *> * _Nonnull models) {
        for (QRoomDataModel *model in models) {
            if (model.type == QRoomDataTypeLike) {
                if (model.page_view > 0) {
                    [self setTotal:[model.page_view intValue]];
                }
            }
        }
    }];
}

- (void)click:(UIButton *)button {
    [super click:button];
    
    if (!self.roomInfo) {
        return;
    }
    
    [[QNLikeService sharedInstance] giveLike:self.roomInfo.live_id count:1 complete:^(NSInteger count, NSInteger total) {
        if (total > 0) {
            [self setTotal:total];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


- (void)receiveIMMessageNotification:(NSNotification *)notice {
    if (!self.roomInfo) {
        return;
    }
    
    NSDictionary *dic = notice.userInfo;
    QIMModel *imModel = [QIMModel mj_objectWithKeyValues:dic.mj_keyValues];
    //收到切换讲解商品信令
    if (![imModel.action isEqualToString:liveroom_like]) {
        return;
    }
    
    QNLikeNotify *model = [QNLikeNotify mj_objectWithKeyValues:imModel.data];
    if (![model.live_id isEqualToString:self.roomInfo.live_id]) {
        return;
    }
    
    [self fetchRoomLike];
}

@end
