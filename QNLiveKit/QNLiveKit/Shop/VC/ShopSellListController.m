//
//  ShopSellListController.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/13.
//

#import "ShopSellListController.h"
#import "GoodSellItemCell.h"
#import "GoodsOperationCell.h"
#import "GoodsModel.h"
#import "QLiveNetworkUtil.h"
#import "GoodsOperationView.h"
#import "GoodStatusView.h"
#import "UITableView+MoveCell.h"
#import "QAlertView.h"
#import "QShopService.h"
#import "QNLiveRoomInfo.h"

@interface ShopSellListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QNLiveRoomInfo *roomInfo;
@property (nonatomic, strong) QShopService *shopService;
@property (nonatomic, strong) NSArray <GoodsModel *> *ListModel;//展示的商品
@property (nonatomic, strong) NSArray <GoodsModel *> *totalListModel;//所有商品
@property (nonatomic, strong) NSMutableArray <GoodsModel *> *selectModel;//选中的商品
@property (nonatomic, strong) GoodsOperationView *operationView;//底部批量操作视图
//@property (nonatomic, strong) GoodStatusView *statusView;//状态分类试图
@property (nonatomic, assign) BOOL isEditing;//商品管理编辑中
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy) NSString *liveID;
@end

@implementation ShopSellListController

- (instancetype)initWithLiveInfo:(QNLiveRoomInfo *)liveInfo {
    if (self = [super init]) {
        self.roomInfo = liveInfo;
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
    [button addTarget:self action:@selector(manageGoods:) forControlEvents:UIControlEventTouchUpInside];
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
    [self.shopService getGoodList:^(NSArray<GoodsModel *> * _Nullable goodList) {
        if (goodList.count > 0) {
            NSLog(@"刷新商品列表成功");
        }
        self.totalListModel = goodList;
        self.ListModel = self.totalListModel;
        [self.tableView reloadData];
    }];
}

//点击管理商品
- (void)manageGoods:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [button setTitle:@"完成" forState:UIControlStateNormal];
    } else {
        [button setTitle:@"管理" forState:UIControlStateNormal];
    }
    self.operationView.hidden = !button.selected;
    self.isEditing = button.selected;
    self.tableView.editing = self.isEditing;
    __weak typeof(self)weakSelf = self;
    [self.tableView setDataWithArray:self.ListModel withBlock:^(NSMutableArray *newArray) {
        weakSelf.ListModel = newArray;
    }];
    [self.tableView reloadData];
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    //移动cell前交换数据源
//    [self.ListModel exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    
    [self sortGood:self.ListModel[sourceIndexPath.row] fromIndex:self.ListModel[sourceIndexPath.row].order.integerValue toIndex:self.ListModel[destinationIndexPath.row].order.integerValue];
    [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.isEditing) {
        GoodStatusView *statusView=[[GoodStatusView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 25)];
        [statusView updateWithModel:self.totalListModel];
        __weak typeof(self)weakSelf = self;
        statusView.typeClickedBlock = ^(QLiveGoodsStatus status) {
            
            NSMutableArray *arr = [NSMutableArray array];
            for (GoodsModel *good in weakSelf.totalListModel) {
                if (good.status == status) {
                    [arr addObject:good];
                }
            }
            weakSelf.ListModel = arr.count == 0 ? weakSelf.totalListModel : arr;
            [weakSelf.tableView reloadData];
        };
        return statusView;
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.isEditing ? 25 : 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.isEditing ? 130 : 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    if (self.isEditing) {
        //编辑中的cell
        GoodsOperationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsOperationCell" forIndexPath:indexPath];
        [cell updateWithModel:self.ListModel[indexPath.row]];
        
        __weak typeof(self)weakSelf = self;
        cell.selectButtonClickedBlock = ^(GoodsModel * _Nonnull itemModel) {
            
            if (itemModel.isSelected) {
                [weakSelf.selectModel addObject:itemModel];
                
            } else {
                [weakSelf.selectModel enumerateObjectsUsingBlock:^(GoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.item_id isEqualToString:itemModel.item_id]) {
                        [weakSelf.selectModel removeObject:obj];
                    }
                }];
            }
            
            weakSelf.ListModel[indexPath.row].isSelected = itemModel.isSelected;
            [weakSelf.tableView reloadData];
        };
        return cell;
    }
    
    //正常显示的cell
    GoodSellItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodSellItemCell" forIndexPath:indexPath];
    [cell updateWithModel:self.ListModel[indexPath.row]];
    __weak typeof(self)weakSelf = self;
    cell.takeDownClickedBlock = ^(GoodsModel * _Nonnull itemModel) {
        if (itemModel.status == QLiveGoodsStatusTakeOn) {
            [weakSelf updateGoodsStatus:@[itemModel] status:QLiveGoodsStatusTakeDown];
        } else {
            [weakSelf updateGoodsStatus:@[itemModel] status:QLiveGoodsStatusTakeOn];
        }
    };
    cell.explainClickedBlock = ^(GoodsModel * _Nonnull itemModel) {
        if (itemModel.isExplaining) {
            NSLog(@"开始讲解");
            [weakSelf explainGood:itemModel];
        } else {
            NSLog(@"结束讲解");
            [weakSelf endExplainGood];
            [weakSelf requestData];
        }
    };
    cell.recordClickedBlock = ^(GoodsModel * _Nonnull itemModel) {
        if (itemModel.record.record_url.length == 0) {
            NSLog(@"录制开启");
            [weakSelf.shopService recordGood:itemModel.item_id callBack:nil];
        } else {
            [weakSelf.shopService deleteGoodRecordIDs:@[itemModel.item_id] callBack:nil];
        }
        
    };
    cell.goodClickedBlock = ^(GoodsModel * _Nonnull itemModel) {
        NSLog(@"商品被点击");
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;;
}

//调整商品顺序
- (void)sortGood:(GoodsModel *)good fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    [self.shopService sortGood:good fromIndex:fromIndex toIndex:toIndex callBack:^{
        [self requestData];
    }];
}

//讲解商品
- (void)explainGood:(GoodsModel *)itemModel {
    [self.shopService explainGood:itemModel callBack:^{
        [self getExplainGood];
    }];
}

//取消讲解商品
- (void)endExplainGood {
    
    [self.shopService endExplainAndRecordGood:^{
        
        NSMutableArray<GoodsModel *> *array = [NSMutableArray arrayWithArray:self.ListModel];
        [array enumerateObjectsUsingBlock:^(GoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isExplaining = NO;
        }];
        self.ListModel = array;
        [self.tableView reloadData];
    }];

}

//查看正在讲解的商品
- (void)getExplainGood {
    
    [self.shopService getExplainGood:^(GoodsModel * _Nullable good) {
        GoodsModel *explainGood = good;
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
    }];
}

//批量修改商品状态
- (void)updateGoodsStatus:(NSArray <GoodsModel *>*)goods status:(QLiveGoodsStatus)status {
    
    [self.shopService updateGoodsStatus:goods status:status callBack:^{
        [self requestData];
    }];
}

//移除商品
- (void)removeGoods:(NSArray <GoodsModel *>*)goods {
    
    [self.shopService removeGoods:goods callBack:^{
        [self requestData];
    }];
    
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
        [_tableView registerClass:[GoodSellItemCell class] forCellReuseIdentifier:@"GoodSellItemCell"];
        [_tableView registerClass:[GoodsOperationCell class] forCellReuseIdentifier:@"GoodsOperationCell"];
        
        
    }
    return _tableView;
}

- (NSMutableArray<GoodsModel *> *)selectModel {
    if (!_selectModel) {
        _selectModel = [NSMutableArray array];
    }
    return _selectModel;
}

- (GoodsOperationView *)operationView {
    if (!_operationView) {
        _operationView = [[GoodsOperationView alloc] initWithFrame:CGRectMake(0, SCREEN_H - 50, SCREEN_W, 50)];
        _operationView.hidden =YES;
        [self.view addSubview:_operationView];
        __weak typeof(self)weakSelf = self;
        _operationView.takeOnClickedBlock = ^{
            
            [QAlertView showBaseAlertWithTitle:@"确定上架商品吗？" content:@"" cancelHandler:^(UIAlertAction * _Nonnull action) {
                
            } confirmHandler:^(UIAlertAction * _Nonnull action) {
                
                [weakSelf updateGoodsStatus:weakSelf.selectModel status:QLiveGoodsStatusTakeOn];
                [weakSelf.selectModel removeAllObjects];
            }];
            
        };
        _operationView.takeDownClickedBlock = ^{
            
            [QAlertView showBaseAlertWithTitle:@"确定下架商品吗" content:@"下架后，买家将无法在商品列表查看本商品，确定下架？" cancelHandler:^(UIAlertAction * _Nonnull action) {
                
            } confirmHandler:^(UIAlertAction * _Nonnull action) {
                [weakSelf updateGoodsStatus:weakSelf.selectModel status:QLiveGoodsStatusTakeDown];
                [weakSelf.selectModel removeAllObjects];
            }];
        };
        _operationView.removeClickedBlock = ^{
            
            [QAlertView showBaseAlertWithTitle:@"确定移除商品吗？" content:@"" cancelHandler:^(UIAlertAction * _Nonnull action) {
                
            } confirmHandler:^(UIAlertAction * _Nonnull action) {
                [weakSelf removeGoods:weakSelf.selectModel];
                [weakSelf.selectModel removeAllObjects];
            }];
            
        };
    }
    return _operationView;
}

- (QShopService *)shopService {
    if (!_shopService) {
        _shopService = [[QShopService alloc]init];
        _shopService.roomInfo = self.roomInfo;
    }
    return _shopService;
}
 
@end
