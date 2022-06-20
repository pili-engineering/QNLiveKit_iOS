//
//  QNHomeListView.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/15.
//

#import "QNHomeListView.h"
#import <Masonry/Masonry.h>
#import "QNSolutionListModel.h"
#import <SDWebImage/SDWebImage.h>
#import "MBProgressHUD+QNShow.h"
#import <QNLiveKit/QNLiveKit.h>


@interface QNHomeListView ()

@property (nonatomic, strong) UIImageView *itemImageView;

@property (nonatomic, strong) UILabel *itemLabel;

@end

@implementation QNHomeListView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self itemImageView];
        [self itemLabel];
    }
    return self;
}

- (void)viewForModel:(QNSolutionItemModel *)model {
    
    self.itemLabel.text = model.title;
    [self.itemImageView sd_setImageWithURL:[NSURL URLWithString:model.icon]];
    SEL itemSelector = NSSelectorFromString(model.itemSelectorNameStr);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:itemSelector];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
}

//面试点击
- (void)interviewClicked {
//    QNInterViewListViewController *vc = [QNInterViewListViewController new];
//    [[self topViewController].navigationController pushViewController:vc animated:YES];
}

//检修点击
- (void)repairClicked {
//    QNRepairListViewController *vc = [QNRepairListViewController new];
//    [[self topViewController].navigationController pushViewController:vc animated:YES];
}

//多人连麦直播
- (void)showLiveClicked {
//
//    QNFunnyListController *vc = [QNFunnyListController new];
//    [[self topViewController].navigationController pushViewController:vc animated:YES];
    
}

//一起看电影
- (void)movieClicked {
//    QNMovieListController *vc = [QNMovieListController new];
//    [[self topViewController].navigationController pushViewController:vc animated:YES];
}

//语聊房
- (void)voiceChatRoomClicked {
//    QNVoiceChatRoomListController *vc = [QNVoiceChatRoomListController new];
//    [[self topViewController].navigationController pushViewController:vc animated:YES];
}


- (void)others {
    QNLiveListController *vc = [QNLiveListController new];
    [[self topViewController].navigationController pushViewController:vc animated:YES];
}

- (UIViewController * )topViewController {
    UIViewController *resultVC;
    resultVC = [self recursiveTopViewController:[[UIApplication sharedApplication].windows.firstObject rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self recursiveTopViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController * )recursiveTopViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self recursiveTopViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self recursiveTopViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

- (UIImageView *)itemImageView {
    if (!_itemImageView) {
        _itemImageView = [[UIImageView alloc]init];
        [self addSubview:_itemImageView];
        
        [_itemImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.height.mas_equalTo(80);
            make.width.mas_equalTo(100);
        }];
    }
    return _itemImageView;
}

- (UILabel *)itemLabel {
    if (!_itemLabel) {
        _itemLabel = [[UILabel alloc]init];
        _itemLabel.font = [UIFont systemFontOfSize:14];
        _itemLabel.textAlignment = NSTextAlignmentCenter;
        _itemLabel.textColor = [UIColor blackColor];
        [self addSubview:_itemLabel];
        
        [_itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.itemImageView);
            make.top.equalTo(self.itemImageView.mas_bottom).offset(15);
            make.width.equalTo(self.itemImageView);
            make.height.mas_equalTo(15);
        }];
    }
    return _itemLabel;
}

@end
