//
//  BugUtil.m
//  Bugly
//
//  Created by 陈晋 on 2018/6/7.
//  Copyright © 2018年 ajhin. All rights reserved.
//

#import "BugUtil.h"

//数据库名称
NSString *const BuglyDBName = @"bugly.db";

//记录表
NSString *const BuglyItemsTableName = @"bugly_items_table";
//存储ObjectId的标签，用于获取需要更新的ObjectId
NSString *const BuglyObjectTag = @"bugId";

//计数表
NSString *const BuglyCountTableName = @"bugly_count_table";
//存储items数量的标签，用于获取需要更新的itemCount数量
NSString *const BuglyItemCountTag = @"itemCountTag";

//分类表
NSString *const BuglyCategoriesTableName = @"bugly_categories_table";
//存储categories数量的标签，用于获取需要更新的categoriesCount数量
NSString *const BuglyCategoriesCountTag = @"categoriesCountTag";

//项目表
NSString *const BuglyProductsTableName = @"bugly_products_table";
//存储products数量的标签，用于获取需要更新的productsCount数量
NSString *const BuglyProductsCountTag = @"productsCountTag";

//状态表
NSString *const BuglyStateTableName = @"bugly_state_table";
//存储state数量的标签，用于获取需要更新的stateCount数量
NSString *const BuglyStateCountTag = @"stateCountTag";

static NSString *const QUERY_ITEMS_SQL = @"SELECT * from %@ where json like %@ or id like %@";

static NSString *const SELECT_COUNT_SQL = @"SELECT COUNT(*) FROM %@";


@interface BugUtil()

@end

@implementation BugUtil

+ (instancetype)shareInstance {
    static BugUtil *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BugUtil alloc] init];
    });
    return instance;
}

+ (NSString *)buglyObjectId {
    NSString *uuid = [[UIDevice currentDevice] uuid];
    
    NSString *device = [SystemServices sharedServices].systemDeviceTypeFormatted;
    
    NSNumber *count = [[BugUtil shareInstance] getNumberById:BuglyItemCountTag fromTable:BuglyCountTableName];
    
    //buglyObjectId = uuid + device + count
    NSString *buglyObjectId = [NSString stringWithFormat:@"%@-%@-%d",uuid,device,count.intValue + 1];
    return buglyObjectId;
}

+ (NSString *)categoriesCountId {
    NSNumber *count = [[BugUtil shareInstance] getNumberById:BuglyCategoriesCountTag fromTable:BuglyCountTableName];
    NSString *categoriesCountId = [NSString stringWithFormat:@"%d",count.intValue + 1];
    return categoriesCountId;
}

+ (NSString *)productsCountId {
    NSNumber *count = [[BugUtil shareInstance] getNumberById:BuglyProductsCountTag fromTable:BuglyCountTableName];
    NSString *categoriesCountId = [NSString stringWithFormat:@"%d",count.intValue + 1];
    return categoriesCountId;
}

+ (NSString *)stateCountId {
    NSNumber *count = [[BugUtil shareInstance] getNumberById:BuglyStateCountTag fromTable:BuglyCountTableName];
    NSString *categoriesCountId = [NSString stringWithFormat:@"%d",count.intValue + 1];
    return categoriesCountId;
}

+ (NSString *)displayBuglyObjectId:(NSString *)objId {
    NSArray *strArr = [objId componentsSeparatedByString:@"-"];
    return [NSString stringWithFormat:@"%@-%@-%@",[strArr[0] substringToIndex:4],strArr[1],strArr[2]];
}

+ (NSString *)dateTimeToString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+ (NSDate *)timgStringtoDate:(NSString *)time {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
    NSDate *dateTime = [dateFormatter dateFromString:time];
    return dateTime;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        BugUtil *bugUtil = [[BugUtil alloc] initDBWithName:BuglyDBName];
        // 创建表，如果已存在，则忽略该操作
        [bugUtil createTableWithName:BuglyItemsTableName];
        [bugUtil createTableWithName:BuglyCountTableName];
        [bugUtil createTableWithName:BuglyCategoriesTableName];
        [bugUtil createTableWithName:BuglyProductsTableName];
        [bugUtil createTableWithName:BuglyStateTableName];
        self = bugUtil;
    }
    return self;
}

#pragma mark - 记录表操作

- (NSArray *)getAllItems {
    return [self getAllItemsFromTable:BuglyItemsTableName];
}

- (void)updateBugItem:(NSDictionary *)item {
    [self putObject:item withId:item[BuglyObjectTag] intoTable:BuglyItemsTableName];
}

- (void)insertBugItem:(NSDictionary *)item {
    NSString *buglyObjectId = [BugUtil buglyObjectId];
    NSNumber *count = [self getNumberById:BuglyItemCountTag fromTable:BuglyCountTableName];
    count = [NSNumber numberWithInt:count.intValue + 1];
    [self putNumber:count withId:BuglyItemCountTag intoTable:BuglyCountTableName];
    NSLog(@"SQL--putNumber:%@-withId:%@-intoTable:%@",count,BuglyItemCountTag,BuglyCountTableName);
    [self putObject:item withId:buglyObjectId intoTable:BuglyItemsTableName];
    NSLog(@"SQL--putObject:%@-withId:%@-intoTable:%@",item,buglyObjectId,BuglyItemsTableName);
}

- (void)deleteBugItemById:(NSString *)objId {
    [self deleteObjectById:objId fromTable:BuglyItemsTableName];
    NSLog(@"SQL--deleteObjectById:%@-fromTable:%@",objId,BuglyItemsTableName);
}

#pragma mark - 分类表操作

- (NSArray *)getAllCategories{
    return [self getAllItemsFromTable:BuglyCategoriesTableName];
}

- (void)insertCategory:(NSDictionary *)category {
    NSString *categoriesCountId = [BugUtil categoriesCountId];
    NSNumber *count = [self getNumberById:BuglyCategoriesCountTag fromTable:BuglyCountTableName];
    count = [NSNumber numberWithInt:count.intValue + 1];
    [self putNumber:count withId:BuglyCategoriesCountTag intoTable:BuglyCountTableName];
    NSLog(@"SQL--putNumber:%@-withId:%@-intoTable:%@",count,BuglyCategoriesCountTag,BuglyCountTableName);
    [self putObject:category withId:categoriesCountId intoTable:BuglyCategoriesTableName];
    NSLog(@"SQL--putObject:%@-withId:%@-intoTable:%@",category,categoriesCountId,BuglyCategoriesTableName);
}

- (void)deleteCategoryById:(NSString *)objId {
    [self deleteObjectById:objId fromTable:BuglyCategoriesTableName];
    NSLog(@"SQL--deleteCategoryById:%@-fromTable:%@",objId,BuglyCategoriesTableName);
}

#pragma mark - 项目表操作

- (NSArray *)getAllProducts{
    return [self getAllItemsFromTable:BuglyProductsTableName];
}

- (void)insertProduct:(NSDictionary *)product {
    NSString *productsCountId = [BugUtil productsCountId];
    NSNumber *count = [self getNumberById:BuglyProductsCountTag fromTable:BuglyCountTableName];
    count = [NSNumber numberWithInt:count.intValue + 1];
    [self putNumber:count withId:BuglyProductsCountTag intoTable:BuglyCountTableName];
    NSLog(@"SQL--putNumber:%@-withId:%@-intoTable:%@",count,BuglyProductsCountTag,BuglyCountTableName);
    [self putObject:product withId:productsCountId intoTable:BuglyProductsTableName];
    NSLog(@"SQL--putObject:%@-withId:%@-intoTable:%@",product,productsCountId,BuglyProductsTableName);
}

- (void)deleteProductById:(NSString *)objId {
    [self deleteObjectById:objId fromTable:BuglyProductsTableName];
    NSLog(@"SQL--deleteCategoryById:%@-fromTable:%@",objId,BuglyProductsTableName);
}

#pragma mark - 状态表操作

- (NSArray *)getAllState{
    return [self getAllItemsFromTable:BuglyStateTableName];
}

- (void)insertState:(NSDictionary *)state {
    NSString *stateCountId = [BugUtil stateCountId];
    NSNumber *count = [self getNumberById:BuglyStateCountTag fromTable:BuglyCountTableName];
    count = [NSNumber numberWithInt:count.intValue + 1];
    [self putNumber:count withId:BuglyStateCountTag intoTable:BuglyCountTableName];
    NSLog(@"SQL--putNumber:%@-withId:%@-intoTable:%@",count,BuglyStateCountTag,BuglyCountTableName);
    [self putObject:state withId:stateCountId intoTable:BuglyStateTableName];
    NSLog(@"SQL--putObject:%@-withId:%@-intoTable:%@",state,stateCountId,BuglyStateTableName);
}

- (void)deleteStateById:(NSString *)objId {
    [self deleteObjectById:objId fromTable:BuglyStateTableName];
    NSLog(@"SQL--deleteStateById:%@-fromTable:%@",objId,BuglyStateTableName);
}


/*
 *扩展查询
 */
#pragma mark - 模糊查询

- (NSArray *)getAllItemsContainsString:(NSString *)string {
    if ([BugUtil checkTableName:BuglyItemsTableName] == NO) {
        return nil;
    }
    NSString *containsString = [NSString stringWithFormat:@"'%%%@%%'",string];
    NSString * sql = [NSString stringWithFormat:QUERY_ITEMS_SQL, BuglyItemsTableName, containsString, containsString];
    NSLog(@"SQL--:%@",sql);
    __block NSMutableArray * result = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            AJKeyValueItem * item = [[AJKeyValueItem alloc] init];
            item.itemId = [rs stringForColumn:@"id"];
            item.itemObject = [rs stringForColumn:@"json"];
            item.createdTime = [rs dateForColumn:@"createdTime"];
            [result addObject:item];
        }
        [rs close];
    }];
    // parse json string to object
    NSError * error;
    for (AJKeyValueItem * item in result) {
        error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:[item.itemObject dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:(NSJSONReadingAllowFragments) error:&error];
        if (error) {
            NSLog(@"ERROR, faild to prase to json.");
        } else {
            item.itemObject = object;
        }
    }
    return result;
}

- (NSNumber *)getCountByTableName:(NSString *)tableName {
    if ([BugUtil checkTableName:tableName] == NO) {
        return nil;
    }
    NSString * sql = [NSString stringWithFormat:SELECT_COUNT_SQL, tableName];
    __block NSNumber *result;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet * rs = [db executeQuery:sql];
        result = [NSNumber numberWithInt:[[rs stringForColumn:@"json"] intValue]];
    }];
    if (!result) {
        NSLog(@"ERROR, failed to execute count from table: %@", tableName);
    }
    return result;
}

@end
