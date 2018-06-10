//
//  BugUtil.h
//  Bugly
//
//  Created by 陈晋 on 2018/6/7.
//  Copyright © 2018年 ajhin. All rights reserved.
//

#import "AJKeyValueStore.h"
@interface BugUtil : AJKeyValueStore

+ (instancetype)shareInstance;

+ (NSString *)buglyObjectId;

+ (NSString *)categoriesCountId;

+ (NSString *)displayBuglyObjectId:(NSString *)objId;

+ (NSString *)dateTimeToString:(NSDate *)date;

+ (NSDate *)timgStringtoDate:(NSString *)time;

/*
 *扩展查询
 */
#pragma mark - 模糊查询

- (NSArray *)getAllItemsContainsString:(NSString *)string;

#pragma mark - 记录表操作

- (void)insertBugItem:(NSDictionary *)item;

- (void)updateBugItem:(NSDictionary *)item;

- (void)deleteBugItemById:(NSString *)objId;

- (NSArray *)getAllItems;

#pragma mark - 分类表操作

- (NSArray *)getAllCategories;

- (void)insertCategory:(NSDictionary *)category;

- (void)deleteCategoryById:(NSString *)objId;

#pragma mark - 项目表操作

- (NSArray *)getAllProducts;

- (void)insertProduct:(NSDictionary *)product;

- (void)deleteProductById:(NSString *)objId;

#pragma mark - 状态表操作

- (NSArray *)getAllState;

- (void)insertState:(NSDictionary *)state;

- (void)deleteStateById:(NSString *)objId;

@end
