//
//  HomeViewController.m
//  Bugly-iOS
//
//  Created by 陈晋 on 2018/6/8.
//  Copyright © 2018年 ajhin. All rights reserved.
//

#import "HomeViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "CYLTableViewPlaceHolder.h"
#import "XTNetReloader.h"
#import "WeChatStylePlaceHolder.h"
#import "BugItem.h"
#import "PlusViewController.h"
#import "SearchViewController.h"
#import "SearchBar.h"

@interface HomeViewController ()<WeChatStylePlaceHolderDelegate,UISearchBarDelegate,SearchControllerDelegate>

@property (nonatomic, strong) UINavigationController *searchController;
@property (nonatomic, strong) SearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *bugItems;

@end

@implementation HomeViewController

#pragma mark - 💤 LazyLoad Method

/**
 *  懒加载_searchBar
 *
 *  @return UISearchBar
 */
- (SearchBar *)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[SearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

#pragma mark - ♻️ LifeCycle Method

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
    
}

#pragma mark - 🔌 SearchHeaderViewDelegate Method

- (void)searchHeaderViewClicked:(id)sender {
    SearchViewController *controller = [[SearchViewController alloc] init];
    controller.delegate = self;
    self.searchController = [[UINavigationController alloc] initWithRootViewController:controller];
    [controller showInViewController:self];
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - 🔌 SearchControllerDelegate Method

- (void)questionSearchCancelButtonClicked:(SearchViewController *)controller
{
    [controller hide:^{
        self.tabBarController.tabBar.hidden = NO;
    }];
}

#pragma mark - 🔌 UISearchBarDelegate Method

/**
 *  开始编辑
 */
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self searchHeaderViewClicked:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"记录";
    // Do any additional setup after loading the view.
    
    self.bugItems = [NSMutableArray arrayWithCapacity:0];
    self.tableView.fd_debugLogEnabled = YES;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"BugItemCell"];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        self.bugItems = [[[BugUtil shareInstance] getAllItems] mutableCopy];
        [self.tableView.mj_header endRefreshing];
        [self.tableView cyl_reloadData];
    }];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.tableFooterView = [UIView new];
    RACSignal *refreshSingal = [[NSNotificationCenter defaultCenter] rac_addObserverForName:@"DoRefreshHomeSignal" object:nil];
    [refreshSingal subscribeNext:^(id x) {
        [self.tableView.mj_header beginRefreshing];
    }];
}

- (void)dealloc {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bugItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BugItemCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"BugItemCell"];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
//    NSError *error;
    AJKeyValueItem *vlaueItem = self.bugItems[indexPath.row];
//    BugItem *item = [MTLJSONAdapter modelOfClass:BugItem.class fromJSONDictionary:vlaueItem.itemObject error:&error];
    cell.textLabel.text = [NSString stringWithFormat:@"编号:%@",[BugUtil displayBuglyObjectId:vlaueItem.itemId]];
}

//- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return @[@"A",@"B",@"C",@"D"];
//}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.searchBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"BugItemCell" configuration:^(UITableViewCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WeakSelf
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确认删除该条记录?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            AJKeyValueItem *vlaueItem = weakSelf.bugItems[indexPath.row];
            [[BugUtil shareInstance] deleteBugItemById:vlaueItem.itemId];
            [weakSelf.bugItems removeObjectAtIndex:indexPath.row];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [weakSelf.tableView cyl_reloadData];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:cancelAction];
        [alertController addAction:comfirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlusViewController *vc = [PlusViewController new];
    vc.valueItem = self.bugItems[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TableViewPlaceHolderDelegate Method

- (UIView *)makePlaceHolderView {
//    UIView *taobaoStyle = [self taoBaoStylePlaceHolder];
    UIView *weChatStyle = [self weChatStylePlaceHolder];
    return (arc4random_uniform(2)==0)?weChatStyle:weChatStyle;
}

- (UIView *)taoBaoStylePlaceHolder {
    __block XTNetReloader *netReloader = [[XTNetReloader alloc] initWithFrame:CGRectMake(0, 0, 0, 0)
                                                                  reloadBlock:^{
                                                                      
                                                                  }] ;
    return netReloader;
}

- (UIView *)weChatStylePlaceHolder {
    WeChatStylePlaceHolder *weChatStylePlaceHolder = [[WeChatStylePlaceHolder alloc] initWithFrame:self.tableView.frame];
    weChatStylePlaceHolder.delegate = self;
    return weChatStylePlaceHolder;
}

#pragma mark - WeChatStylePlaceHolderDelegate Method

- (void)emptyOverlayClicked:(id)sender {
    [self.tableView.mj_header beginRefreshing];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
