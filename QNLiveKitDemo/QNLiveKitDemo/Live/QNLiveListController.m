//
//  QNLiveListController.m
//  QNLiveKitDemo
//
//  Created by 郭茜 on 2022/5/30.
//

#import "QNLiveListController.h"
#import <QNLiveKit/QNLiveKit.h>
#import "QNLiveListCell.h"
#import "QNCreateLiveController.h"


@interface QNLiveListController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray <QNLiveRoomInfo *> *rooms;

@end

@implementation QNLiveListController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

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
    [QNLiveRoomEngine listRoomWithPageNumber:1 pageSize:20 callBack:^(NSArray<QNLiveRoomInfo *> * _Nonnull list) {
        self.rooms = list;
        [self.collectionView reloadData];
    }];
}

- (void)createButton {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((kScreenWidth - 150)/2, kScreenHeight - 100, 150, 40)];
    button.backgroundColor = [UIColor blueColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.clipsToBounds = YES;
    button.layer.cornerRadius = 20;
    [button setTitle:@"创建直播房间" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addLiveRoom) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)addLiveRoom {
    
    QNCreateLiveController *vc = [QNCreateLiveController new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)showIntoRoomWayAlertWithModel:(QNLiveRoomInfo *)model {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择进房方式" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"拉流播放" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        
        
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"加入订阅" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
        
    }];
    [alertController addAction:changeBtn];
    
    [self presentViewController:alertController animated:YES completion:nil];
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
    [self showIntoRoomWayAlertWithModel:model];
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
        [_collectionView registerClass:[QNLiveListCell class] forCellWithReuseIdentifier:@"QNLiveListCell"];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

@end
