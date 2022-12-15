//
//  ApiDemoViewController.m
//  QNLiveKitDemo
//
//  Created by sheng wang on 2022/12/15.
//

#import "ApiDemoViewController.h"
#import "QNDemoUserFetchLoginUser.h"

@implementation QNApiDemoEntry

- (instancetype)initWithTitle:(NSString *)title desc:(NSString *)desc demo:(id<QNApiDemo>)demo {
    if (self = [super init]) {
        self.title = title;
        self.desc = desc;
        self.demo = demo;
    }
    return self;
}

@end

@interface ApiDemoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *demos;

@end

@implementation ApiDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QNApiDemoEntry *entry = [self.demos objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
    }
    
    [cell.textLabel setText:entry.title];
    [cell.detailTextLabel setText:entry.desc];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QNApiDemoEntry *entry = [self.demos objectAtIndex:indexPath.row];
    [entry.demo example];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSArray *)demos {
    if (!_demos) {
        NSMutableArray *demos = [NSMutableArray new];
        [demos addObject: [[QNApiDemoEntry alloc] initWithTitle:@"获取登录用户" desc:@"获取登录用户自己的信息" demo:[[QNDemoUserFetchLoginUser alloc] init]]];
        
        
        _demos = [demos copy];
    }
    return _demos;
}
@end
