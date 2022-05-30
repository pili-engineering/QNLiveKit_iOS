//
//  QNHomeListViewController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/8.
//

#import "QNHomeListViewController.h"
#import "QNLoginViewController.h"
#import "QNSolutionListModel.h"
#import "QNHomeListViewModel.h"
#import "QNHomeListView.h"
#import "NSArray+Sudoku.h"
#import <YYCategories/YYCategories.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "QNAppConficModel.h"

@interface QNHomeListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;


@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) QNSolutionListModel *listModel;

@end

@implementation QNHomeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"应用列表";
    self.view.backgroundColor = [UIColor whiteColor];
    [self bgView];
    [self collectionView];
    
    __weak typeof(self) weakSelf = self;
    if (self.listModel.list.count == 0) {
        [QNHomeListViewModel requestListModel:^(QNSolutionListModel * _Nonnull list) {
            weakSelf.listModel = list;
            [weakSelf.collectionView reloadData];
        }];
    }
    
    //检测新版本
    [QNAppConficModel getAppVersion:^(NSURL * _Nonnull packagePage) {
        [weakSelf alertWithPackagePage:packagePage];
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)alertWithPackagePage:(NSURL *)packagePage {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"检测到新版本，是否下载？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"不用" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelBtn];
    
    UIAlertAction *changeBtn = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[UIApplication sharedApplication] openURL:packagePage];

            
    }];
    [alertController addAction:changeBtn];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listModel.list.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QNHomeListView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QNHomeListView" forIndexPath:indexPath];
    [cell viewForModel:self.listModel.list[indexPath.item]];
    return cell;
}


#pragma mark --Lazy Load

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 5;
        _bgView.layer.shadowColor = [UIColor blackColor].CGColor;
        _bgView.layer.shadowOffset = CGSizeMake(0,0);
        _bgView.layer.shadowOpacity = 0.3;
        _bgView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_bgView.bounds byRoundingCorners:5 cornerRadii:CGSizeMake(0, 0)].CGPath;
        [self.view addSubview:_bgView];
        
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.top.equalTo(self.view).offset(20);
            make.bottom.equalTo(self.view).offset(-80);
        }];
    }
    return _bgView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.itemSize = CGSizeMake((kScreenWidth - 80)/2, (kScreenWidth - 80)/2);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[QNHomeListView class] forCellWithReuseIdentifier:@"QNHomeListView"];
        [self.bgView addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.top.equalTo(self.view).offset(20);
            make.bottom.equalTo(self.view).offset(-80);
        }];
    }
    return _collectionView;
}


@end
