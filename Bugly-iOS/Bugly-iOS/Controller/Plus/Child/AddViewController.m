//
//  AddViewController.m
//  Bugly-iOS
//
//  Created by 陈晋 on 2018/6/9.
//  Copyright © 2018年 ajhin. All rights reserved.
//

#import "AddViewController.h"

#pragma mark - 扩展XLFormDescriptor
@interface XLFormDescriptor(AddValue)<XLFormOptionObject>
-(NSDictionary *)formAddValuesDictionary;
@end

@implementation XLFormDescriptor(AddValue)

- (nonnull NSString *)formDisplayText {
    return nil;
}

- (nonnull id)formValue {
    return [self formAddValuesDictionary];
}

- (NSDictionary *)formAddValuesDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (XLFormSectionDescriptor * section in self.formSections) {
        for (XLFormRowDescriptor * row in section.formRows) {
            [result setObject:row.value forKey:row.tag];
        }
    }
    return result;
}

@end

@interface AddViewController ()

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.rowDescriptor.tag isEqualToString:@"category"]) {
        self.title = @"添加分类";
    }else if ([self.rowDescriptor.tag isEqualToString:@"product"]) {
        self.title = @"添加项目";
    }else if ([self.rowDescriptor.tag isEqualToString:@"state"]) {
        self.title = @"添加状态";
    }
    UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBug)];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    self.navigationItem.leftBarButtonItem = cancelBarItem;
    self.navigationItem.rightBarButtonItem = rightBarItem;
    // Do any additional setup after loading the view.
    self.tableView.sectionHeaderHeight = 2.f;
    self.tableView.sectionFooterHeight = 2.f;
    [self initializeForm];
}

- (BOOL)willDealloc {
    return NO;
}

- (void)saveAction {
    NSDictionary *value = [self.form formAddValuesDictionary];
    if ([self.rowDescriptor.tag isEqualToString:@"category"]) {
        [[BugUtil shareInstance] insertCategory:value];
    }else if ([self.rowDescriptor.tag isEqualToString:@"product"]) {
        [[BugUtil shareInstance] insertProduct:value];
    }else if ([self.rowDescriptor.tag isEqualToString:@"state"]) {
        [[BugUtil shareInstance] insertState:value];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DoRefreshSelectionSignal" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelBug {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initializeForm {
    XLFormDescriptor *form;
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"添加选项"];
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    //Bug编号
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"name" rowType:XLFormRowDescriptorTypeText title:@"名称"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    self.form = form;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
