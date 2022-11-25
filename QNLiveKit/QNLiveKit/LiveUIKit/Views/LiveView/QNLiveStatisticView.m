//
//  QNLiveStatisticView.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/25.
//

#import "QNLiveStatisticView.h"
#import "QStatisticalService.h"
#import "QNLiveStatisticView.h"
#import "QIMModel.h"
#import "QNLikeNotify.h"

@interface QNLiveStatisticView ()

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) QStatisticalService *statService;

@property (nonatomic, assign) NSInteger lastFetchTime;
@property (nonatomic, strong) dispatch_queue_t fetchQueue;

@property (nonatomic, assign) NSInteger watchCount;
@property (nonatomic, assign) NSInteger onlineCount;
@property (nonatomic, assign) NSInteger likeCount;


@end

@implementation QNLiveStatisticView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.contentLabel];
        self.fetchQueue = dispatch_queue_create("com.qiniu.livekit.livestatistic", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)layoutSubviews {
    [self makeConstraints];
}

- (void)makeConstraints {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self);
    }];
}


- (void)didMoveToSuperview {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIMMessageNotification:) name:ReceiveIMMessageNotification object:nil];
}

- (void)removeFromSuperview {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setRoomInfo:(QNLiveRoomInfo *)roomInfo {
    _roomInfo = roomInfo;
    _statService = [[QStatisticalService alloc] init];
    _statService.roomInfo = roomInfo;
    
    self.onlineCount = [roomInfo.online_count intValue];
    
    [self fetchRoomStatistics];
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        [_contentLabel setFont:[UIFont systemFontOfSize:9]];
        [_contentLabel setTextColor:[UIColor whiteColor]];
    }
    return _contentLabel;
}

- (void)fetchRoomStatistics {
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
                self.likeCount = [model.page_view intValue];
            } else if (model.type == QRoomDataTypeWatch) {
                self.watchCount = [model.page_view intValue];
            }
        }
        [self updateContent];
    }];
}

- (void)updateWith:(QNLiveRoomInfo *)roomInfo {
    self.onlineCount = [roomInfo.online_count intValue];
    [self updateContent];
}

- (void)updateContent {
    NSString *watchText = [self countText:self.watchCount];
    NSString *onlineText = [self countText:self.onlineCount];
    NSString *likeText = [self countText:self.likeCount];
    
    self.contentLabel.text = [NSString stringWithFormat:@"%@浏览 %@在线 %@赞", watchText, onlineText, likeText];
}

- (NSString *)countText:(NSInteger)count {
    if (count < 10000) {
        return [NSString stringWithFormat:@"%ld", count];
    } else {
        CGFloat w = (double)count / 10000.0;
        return [NSString stringWithFormat:@"%.1fw", w];
    }
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
    
    [self fetchRoomStatistics];
}

@end
