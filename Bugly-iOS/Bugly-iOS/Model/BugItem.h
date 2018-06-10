//
//  BugItem.h
//  Bugly
//
//  Created by 陈晋 on 2018/6/7.
//  Copyright © 2018年 ajhin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BugItem : MTLModel<MTLJSONSerializing>
//Bug编号
@property (nonatomic, copy) id bugId;
//开始时间
@property (nonatomic, copy) NSString *startDate;
//结束时间
@property (nonatomic, copy) NSString *endDate;
//所属分类
@property (nonatomic, copy) NSString *category;
//所属项目
@property (nonatomic, copy) NSString *product;
//当前状态
@property (nonatomic, copy) NSString *state;
//问题描述
@property (nonatomic, copy) NSString *question;
//产生原因
@property (nonatomic, copy) NSString *reason;
//解决方案
@property (nonatomic, copy) NSString *answer;
//引用资料
@property (nonatomic, copy) NSString *data;
//备注
@property (nonatomic, copy) NSString *note;

@end


@interface Categorie : MTLModel<MTLJSONSerializing>

@end


@interface Products : MTLModel<MTLJSONSerializing>

@end


@interface States : MTLModel<MTLJSONSerializing>

@end
