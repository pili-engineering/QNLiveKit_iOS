//
//  QLiveListController.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import "QLiveListController.h"
#import <QNLiveKit/QNLiveKit.h>
#import "QNLiveListCell.h"
#import "QCreateLiveController.h"
#import "CreateBeautyLiveController.h"
#import "QLiveController.h"
#import "QNLiveRoomInfo.h"
#import "BeautyLiveViewController.h"

@interface QLiveListController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray <QNLiveRoomInfo *> *rooms;

@end

@implementation QLiveListController

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    self.tabBarController.tabBar.hidden = YES;
//    
////    [self.navigationController setNavigationBarHidden:YES animated:NO];
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"直播列表";
    [self collectionView];
    [self requestData];
    [self createButton];
}



//请求直播房间列表
- (void)requestData {
    [[QLive getRooms] listRoom:1 pageSize:20 callBack:^(NSArray<QNLiveRoomInfo *> * _Nonnull list) {
        self.rooms = list;
        [self.collectionView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (void)createButton {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_W - 200)/2, SCREEN_H - 150, 200, 40)];
    button.backgroundColor = [UIColor blueColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.clipsToBounds = YES;
    button.layer.cornerRadius = 20;
    [button setImage:[UIImage imageNamed:@"create_live"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addLiveRoom) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)addLiveRoom {
    
    
    if (self.createRoomClickedBlock) {
        self.createRoomClickedBlock();
        return;
    }
    
    if ([QLive createPusherClient].needBeauty) {
        
        CreateBeautyLiveController *vc = [CreateBeautyLiveController new];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
        
    } else {
        
        QCreateLiveController *vc = [QCreateLiveController new];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    
        
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.rooms.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QNLiveListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QNLiveListCell" forIndexPath:indexPath];
    [cell updateWithModel:self.rooms[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    QNLiveRoomInfo *model = self.rooms[indexPath.item];
    
    if ([model.anchor_info.user_id isEqualToString:LIVE_User_id]) {
        
        if (self.masterJoinBlock) {
            self.masterJoinBlock(model);
            return;
        }
        
        if ([QLive createPusherClient].needBeauty) {
            
            //带美颜
            BeautyLiveViewController *vc = [BeautyLiveViewController new];
            vc.roomInfo = model;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
            
        } else {
            //不带美颜
            QLiveController *vc = [QLiveController new];
            vc.roomInfo = model;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:vc animated:YES completion:nil];
        }
        
    } else {
        
        if (self.audienceJoinBlock) {
            self.audienceJoinBlock(model);
            return;
        }
        QNAudienceController *vc = [QNAudienceController new];
        vc.roomInfo = model;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
                
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.itemSize = CGSizeMake((self.view.frame.size.width - 15)/2, (self.view.frame.size.width - 15)/2);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 5, self.view.frame.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.refreshControl = self.refreshControl;
        [_collectionView registerClass:[QNLiveListCell class] forCellWithReuseIdentifier:@"QNLiveListCell"];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc]init];
        [_refreshControl addTarget:self action:@selector(requestData) forControlEvents:UIControlEventValueChanged];
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"松手刷新"];
        _refreshControl.tintColor = [UIColor lightGrayColor];

    }
    return _refreshControl;
}

@end
