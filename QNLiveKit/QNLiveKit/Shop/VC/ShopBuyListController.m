//
//  ShopBuyListController.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/14.
//

#import "ShopBuyListController.h"
#import "GoodBuyItemCell.h"
#import "GoodsModel.h"
#import "QLiveNetworkUtil.h"
#import "QShopService.h"
#import "QNLiveRoomInfo.h"

@interface ShopBuyListController ()<UITableViewDelegate,UITableViewDataSource,ShopServiceListener,QNChatRoomServiceListener>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QNLiveRoomInfo *roomInfo;
@property (nonatomic, strong) QShopService *shopService;
@property (nonatomic, strong) QNChatRoomService * chatService;
@property (nonatomic, strong) NSArray <GoodsModel *> *ListModel;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy) NSString *liveID;
@end

@implementation ShopBuyListController

- (instancetype)initWithLiveInfo:(QNLiveRoomInfo *)liveInfo{
    if (self = [super init]) {
        self.liveID = liveInfo.live_id;
        self.roomInfo = liveInfo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self.chatService addChatServiceListener:self];
    self.shopService.delegate = self;
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 240, SCREEN_W, 50)];
    headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView];
    
    _label = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_W - 100)/2, 10, 100, 20)];
    _label.text = @"商品列表";
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont systemFontOfSize:14];
    _label.textColor = [UIColor blackColor];
    [headView addSubview:_label];
    
    UIButton *button = [[UIButton alloc]init];
    [button setImage:[UIImage imageNamed:@"close_gray"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissController) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView).offset(20);
        make.centerY.equalTo(self.label);
    }];
    
    [self tableView];
    [self requestData];
}

//讲解商品切换监听
- (void)onExplainingUpdate:(GoodsModel *)good {
    [self getExplainGood];
}

//商品信息更新监听
- (void)onGoodsRefresh {
    [self requestData];
}

//刷新商品列表
- (void)requestData {
    
    [self.shopService getOnlineGoodList:^(NSArray<GoodsModel *> * _Nullable goodList) {
        self.ListModel = [NSArray arrayWithArray:goodList];
        [self getExplainGood];
    }];
   
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf requestData];
    });
}

//查看正在讲解的商品
- (void)getExplainGood {
    
    [self.shopService getExplainGood:^(GoodsModel * _Nullable good) {
        [self dealExplainGood:good];
    }];
}

//处理讲解商品
- (void)dealExplainGood:(GoodsModel *)good {
    NSMutableArray<GoodsModel *> *array = [NSMutableArray arrayWithArray:self.ListModel];
    
    [array enumerateObjectsUsingBlock:^(GoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([good.item_id isEqualToString:obj.item_id]) {
            obj.isExplaining = YES;
        } else {
            obj.isExplaining = NO;
        }
    }];
    self.ListModel = array;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    GoodBuyItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodBuyItemCell" forIndexPath:indexPath];
    [cell updateWithModel:self.ListModel[indexPath.row]];
    __weak typeof(self)weakSelf = self;
    cell.buyClickedBlock = ^(GoodsModel * _Nonnull itemModel) {
        if (weakSelf.buyClickedBlock) {
            weakSelf.buyClickedBlock(itemModel);
        }
        [weakSelf dismissController];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.buyClickedBlock) {
        self.buyClickedBlock(self.ListModel[indexPath.row]);
    }
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
        [_tableView registerClass:[GoodBuyItemCell class] forCellReuseIdentifier:@"GoodBuyItemCell"];
    }
    return _tableView;
}

- (QShopService *)shopService {
    if (!_shopService) {
        _shopService = [[QShopService alloc]init];
        _shopService.roomInfo = self.roomInfo;
    }
    return _shopService;
}

- (QNChatRoomService *)chatService {
    if (!_chatService) {
        _chatService = [[QNChatRoomService alloc] init];
        _chatService.roomInfo = self.roomInfo;
    }
    return _chatService;
}

@end
