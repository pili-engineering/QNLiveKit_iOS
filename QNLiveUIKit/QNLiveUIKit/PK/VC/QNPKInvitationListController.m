//
//  QNPKInvitationListController.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/8.
//

#import "QNPKInvitationListController.h"
#import "QNPKInvitationListCell.h"

@interface QNPKInvitationListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <QNLiveRoomInfo *> *ListModel;
@property (nonatomic, strong) UILabel *label;
@end

@implementation QNPKInvitationListController

- (instancetype)initWithList:(NSArray<QNLiveRoomInfo *> *)list {
    if (self = [super init]) {
        self.ListModel = list;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _label = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 100, 20)];
    _label.text = @"正在直播的好友";
    _label.font = [UIFont systemFontOfSize:14];
    _label.textColor = [UIColor blackColor];
    [self.view addSubview:_label];
    
    UIButton *button = [[UIButton alloc]init];
    [button setImage:[UIImage imageNamed:@"close_gray"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20);
        make.centerY.equalTo(self.label);
    }];

    [self tableView];

}

- (void)dismissController {
    if (self.cancelBlock) {
        self.cancelBlock();
        self.cancelBlock = nil;
    }
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ListModel.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    QNPKInvitationListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QNInvitationMemberListCell" forIndexPath:indexPath];
    cell.itemModel = self.ListModel[indexPath.row];
    __weak typeof(self)weakSelf = self;
    cell.listClickedBlock = ^(QNLiveRoomInfo * _Nonnull itemModel) {
        if (weakSelf.invitationClickedBlock) {
            weakSelf.invitationClickedBlock(self.ListModel[indexPath.row]);
        }
        [weakSelf removeFromParentViewController];
        [weakSelf.view removeFromSuperview];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.invitationClickedBlock) {
        self.invitationClickedBlock(self.ListModel[indexPath.row]);
    }
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
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
            make.top.equalTo(self.label.mas_bottom).offset(10);
        }];
        
        [_tableView registerClass:[QNPKInvitationListCell class] forCellReuseIdentifier:@"QNInvitationMemberListCell"];
        
    }
    return _tableView;
}

@end
