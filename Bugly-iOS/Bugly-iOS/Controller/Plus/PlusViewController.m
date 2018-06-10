//
//  PlusViewController.m
//  Bugly-iOS
//
//  Created by 陈晋 on 2018/6/8.
//  Copyright © 2018年 ajhin. All rights reserved.
//

#import "PlusViewController.h"
#import "SelectionViewController.h"

#pragma mark - 扩展XLFormDescriptor
@interface XLFormDescriptor(Values)<XLFormOptionObject>
-(NSDictionary *)formValuesDictionary;
@end

@implementation XLFormDescriptor(Values)

- (nonnull NSString *)formDisplayText {
    return nil;
}

- (nonnull id)formValue {
    return [self formValuesDictionary];
}

- (NSDictionary *)formValuesDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (XLFormSectionDescriptor * section in self.formSections) {
        for (XLFormRowDescriptor * row in section.formRows) {
            if ([row.value isKindOfClass:[NSDate class]] && row.value){
                NSString *strDate = [BugUtil dateTimeToString:row.value];
                [result setObject:strDate forKey:row.tag];
            }else if ([row.value isKindOfClass:[XLFormOptionsObject class]] && [row.value valueData]){
                if ([row.rowType isEqualToString:XLFormRowDescriptorTypeSelectorPush]){
                    [result setObject:[row.value formValue] forKey:row.tag];
                }else {
                    [result setObject:[row.value valueData] forKey:row.tag];
                }
            }else {
                [result setObject:row.value forKey:row.tag];
            }
        }
    }
    return result;
}

@end


@interface PlusViewController ()

@end

@implementation PlusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"填写日志";
    UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBug)];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveBug)];
    self.navigationItem.leftBarButtonItem = self.valueItem?nil:cancelBarItem;
    self.navigationItem.rightBarButtonItem = rightBarItem;
    // Do any additional setup after loading the view.
    self.tableView.sectionHeaderHeight = 2.f;
    self.tableView.sectionFooterHeight = 2.f;
    [self initializeForm];
    [self loadData];
}

- (BOOL)willDealloc {
    return NO;
}

- (void)loadData {
    NSDictionary *values = self.valueItem.itemObject;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (XLFormSectionDescriptor * section in self.form.formSections) {
            for (XLFormRowDescriptor * row in section.formRows) {
                id value = values[row.tag];
                if([row.tag isEqualToString:@"bugId"]){
                    value = value?:[BugUtil buglyObjectId];
                    row.value = [XLFormOptionsObject formOptionsObjectWithValue:value displayText:[BugUtil displayBuglyObjectId:value]];
                }else if ([row.rowType isEqualToString:XLFormRowDescriptorTypeDateTime] && value){
                    row.value = [BugUtil timgStringtoDate:value];
                }else if ([row.rowType isEqualToString:XLFormRowDescriptorTypeSelectorPush]){
                    value = value?:@[];
                    NSString *displayText;
                    for (NSDictionary *dict in value) {
                        displayText = [NSString stringWithFormat:@"%@%@",displayText?[NSString stringWithFormat:@"%@,",displayText]:@"",dict[@"name"]];
                    }
                    XLFormOptionsObject *object = [XLFormOptionsObject formOptionsObjectWithValue:value displayText:displayText];
                    row.value = object;
                    row.action.viewControllerClass = [SelectionViewController class];
                }else {
                    row.value = value;
                }
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新
            [self.tableView reloadData];
        });
    });
}

- (void)initializeForm {
    XLFormDescriptor *form;
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"填写日志"];
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    //Bug编号
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"bugId" rowType:XLFormRowDescriptorTypeInfo title:@"Bug编号"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    //开始时间
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"startDate" rowType:XLFormRowDescriptorTypeDateTime title:@"开始时间"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    //结束时间
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"endDate" rowType:XLFormRowDescriptorTypeDateTime title:@"结束时间"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    //所属分类
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"category" rowType:XLFormRowDescriptorTypeSelectorPush title:@"所属分类"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    //所属项目
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"product" rowType:XLFormRowDescriptorTypeSelectorPush title:@"所属项目"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    //当前状态
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"state" rowType:XLFormRowDescriptorTypeSelectorPush title:@"当前状态"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    //问题描述
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"question" rowType:XLFormRowDescriptorTypeText title:@"问题描述"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    //产生原因
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"reason" rowType:XLFormRowDescriptorTypeTextView title:@"产生原因"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    //解决方案
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"answer" rowType:XLFormRowDescriptorTypeTextView title:@"解决方案"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    //引用资料
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"data" rowType:XLFormRowDescriptorTypeTextView title:@"引用资料"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    //备注
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"note" rowType:XLFormRowDescriptorTypeTextView title:@"备注"];
    [section addFormRow:row];
    
    self.form = form;
}

- (void)saveBug {
    NSDictionary *values = [self.form formValuesDictionary];
    if (self.valueItem) {
        [[BugUtil shareInstance] updateBugItem:values];
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [[BugUtil shareInstance] insertBugItem:values];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DoRefreshHomeSignal" object:nil];
}

- (void)cancelBug {
    [self dismissViewControllerAnimated:YES completion:nil];
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
