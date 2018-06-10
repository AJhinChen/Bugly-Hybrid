//
//  SelectionViewController.m
//  Bugly-iOS
//
//  Created by 陈晋 on 2018/6/9.
//  Copyright © 2018年 ajhin. All rights reserved.
//

#import "SelectionViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "AddViewController.h"

@interface SelectionViewController ()

@property (nonatomic, strong) NSMutableArray *dataSources;

@property (nonatomic, strong) NSMutableArray *selectedArray;

@end

@implementation SelectionViewController
@synthesize rowDescriptor;

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.rowDescriptor.tag isEqualToString:@"category"]) {
        self.title = @"所属分类";
    }else if ([self.rowDescriptor.tag isEqualToString:@"product"]) {
        self.title = @"所属项目";
    }else if ([self.rowDescriptor.tag isEqualToString:@"state"]) {
        self.title = @"当前状态";
    }
    // Do any additional setup after loading the view.
    self.dataSources = [NSMutableArray arrayWithCapacity:0];
    self.selectedArray = [NSMutableArray arrayWithCapacity:0];
    self.tableView.fd_debugLogEnabled = YES;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CategoriesCell"];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        if ([self.rowDescriptor.tag isEqualToString:@"category"]) {
            self.dataSources = [[[BugUtil shareInstance] getAllCategories] mutableCopy];
        }else if ([self.rowDescriptor.tag isEqualToString:@"product"]) {
            self.dataSources = [[[BugUtil shareInstance] getAllProducts] mutableCopy];
        }else if ([self.rowDescriptor.tag isEqualToString:@"state"]) {
            self.dataSources = [[[BugUtil shareInstance] getAllState] mutableCopy];
        }
        XLFormOptionsObject *object = self.rowDescriptor.value;
        self.selectedArray = [[object formValue] mutableCopy];
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    }];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.tableFooterView = [UIView new];
    UIBarButtonItem *comfirmBarItem = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStylePlain target:self action:@selector(comfirmAction)];
    UIBarButtonItem *addBarItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addAction)];

    self.navigationItem.rightBarButtonItems = @[comfirmBarItem,addBarItem];
    RACSignal *refreshSingal = [[NSNotificationCenter defaultCenter] rac_addObserverForName:@"DoRefreshSelectionSignal" object:nil];
    [refreshSingal subscribeNext:^(id x) {
        [self.tableView.mj_header beginRefreshing];
    }];

}

- (BOOL)willDealloc {
    return NO;
}

- (void)comfirmAction {
    NSString *displayText;
    for (NSDictionary *dict in self.selectedArray) {
        displayText = [NSString stringWithFormat:@"%@%@",displayText?[NSString stringWithFormat:@"%@,",displayText]:@"",dict[@"name"]];
    }
    XLFormOptionsObject *object = [XLFormOptionsObject formOptionsObjectWithValue:self.selectedArray displayText:displayText];
    self.rowDescriptor.value = object;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addAction {
    AddViewController *addVC = [[AddViewController alloc] init];
    addVC.rowDescriptor = self.rowDescriptor;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addVC];
    [self presentViewController:nav animated:YES completion:nil];
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
    return [self.dataSources count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoriesCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CategoriesCell"];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    AJKeyValueItem *valueItem = self.dataSources[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [NSString stringWithFormat:@"%@",valueItem.itemObject[@"name"]];
    if ([self.selectedArray containsObject:valueItem.itemObject]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

//- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return @[@"A",@"B",@"C",@"D"];
//}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"CategoriesCell" configuration:^(UITableViewCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AJKeyValueItem *valueItem = self.dataSources[indexPath.row];
        if ([self.rowDescriptor.tag isEqualToString:@"category"]) {
            [[BugUtil shareInstance] deleteCategoryById:valueItem.itemId];
        }else if ([self.rowDescriptor.tag isEqualToString:@"product"]) {
            [[BugUtil shareInstance] deleteProductById:valueItem.itemId];
        }else if ([self.rowDescriptor.tag isEqualToString:@"state"]) {
            [[BugUtil shareInstance] deleteStateById:valueItem.itemId];
        }
        [self.dataSources removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AJKeyValueItem *valueItem = self.dataSources[indexPath.row];
    if ([self.selectedArray containsObject:valueItem.itemObject]) {
        [self.selectedArray removeObject:valueItem.itemObject];
    }else {
        [self.selectedArray addObject:valueItem.itemObject];
    }
    [self.tableView reloadData];
}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    AJKeyValueItem *valueItem = self.dataSources[indexPath.row];
//    [self.selectedArray removeObject:valueItem.itemObject];
//    [self.tableView reloadData];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
