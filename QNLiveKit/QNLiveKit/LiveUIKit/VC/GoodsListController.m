//
//  GoodsListController.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/13.
//

#import "GoodsListController.h"
#import "GoodsItemCell.h"
#import "GoodsModel.h"
#import "QLiveNetworkUtil.h"

@interface GoodsListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <GoodsModel *> *ListModel;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy) NSString *liveID;
@end

@implementation GoodsListController

- (instancetype)initWithLiveID:(NSString *)liveID{
    if (self = [super init]) {
        self.liveID = liveID;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 240, SCREEN_W, 50)];
    headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView];
    
    _label = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 100, 20)];
    _label.text = @"商品列表";
    _label.font = [UIFont systemFontOfSize:14];
    _label.textColor = [UIColor blackColor];
    [headView addSubview:_label];
    
    UIButton *button = [[UIButton alloc]init];
    [button setTitle:@"管理" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissController) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headView.mas_right).offset(-20);
        make.centerY.equalTo(self.label);
    }];
    
    [self tableView];
    [self requestData];
}

//刷新商品列表
- (void)requestData {
    
    NSString *action = [NSString stringWithFormat:@"client/item/%@",self.liveID];
    [QLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        self.ListModel = [GoodsModel mj_objectArrayWithKeyValuesArray:responseData];
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


- (void)dismissController {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ListModel.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    GoodsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsItemCell" forIndexPath:indexPath];
    [cell updateWithModel:self.ListModel[indexPath.row]];
    __weak typeof(self)weakSelf = self;
    cell.takeDownClickedBlock = ^(GoodsModel * _Nonnull itemModel) {
        [weakSelf takeDownGoods:itemModel];
    };
    cell.explainClickedBlock = ^(GoodsModel * _Nonnull itemModel) {
        if (itemModel.isExplaining) {
            [weakSelf explainGood:itemModel];            
        } else {
            [weakSelf endExplainGood];
        }
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;;
}

//讲解商品
- (void)explainGood:(GoodsModel *)itemModel {
    NSString *action = [NSString stringWithFormat:@"client/item/demonstrate/%@/%@",self.liveID,itemModel.item_id];
    [QLiveNetworkUtil postRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        [self getExplainGood];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//取消讲解商品
- (void)endExplainGood {
    NSString *action = [NSString stringWithFormat:@"client/item/demonstrate/%@",self.liveID];
    [QLiveNetworkUtil deleteRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        
        NSMutableArray<GoodsModel *> *array = [NSMutableArray arrayWithArray:self.ListModel];
        
        [array enumerateObjectsUsingBlock:^(GoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isExplaining = NO;
        }];
        self.ListModel = array;
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//查看正在讲解的商品
- (void)getExplainGood {
    NSString *action = [NSString stringWithFormat:@"client/item/demonstrate/%@",self.liveID];
    [QLiveNetworkUtil getRequestWithAction:action params:nil success:^(NSDictionary * _Nonnull responseData) {
        
        GoodsModel *explainGood = [GoodsModel mj_objectWithKeyValues:responseData];
        NSMutableArray<GoodsModel *> *array = [NSMutableArray arrayWithArray:self.ListModel];
        
        [array enumerateObjectsUsingBlock:^(GoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([explainGood.item_id isEqualToString:obj.item_id]) {
                obj.isExplaining = YES;
            } else {
                obj.isExplaining = NO;
            }
        }];
        self.ListModel = array;
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

//上/下架某商品
- (void)takeDownGoods:(GoodsModel *)itemModel {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"live_id"] = self.liveID;
    GoodsModel *model = [GoodsModel new];
    model.item_id = itemModel.item_id;
    if (itemModel.status == QLiveGoodsStatusTakeOn) {
        model.status = QLiveGoodsStatusTakeDown;
    } else {
        model.status = QLiveGoodsStatusTakeOn;
    }
    params[@"items"] = @[model.mj_keyValues];
    [QLiveNetworkUtil postRequestWithAction:@"client/item/status" params:params success:^(NSDictionary * _Nonnull responseData) {
        [self requestData];
        } failure:^(NSError * _Nonnull error) {}];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissController];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.label.mas_bottom).offset(15);
        }];
        [_tableView registerClass:[GoodsItemCell class] forCellReuseIdentifier:@"GoodsItemCell"];
    }
    return _tableView;
}

@end
