//
//  CDVViewCommandQueue.h
//  Bugly
//
//  Created by 陈晋 on 2018/6/6.
//  Copyright © 2018年 ajhin. All rights reserved.
//
#import <Foundation/Foundation.h>

@class CDVInvokedUrlCommand;
@class CDVView;

@interface CDVViewCommandQueue : NSObject

@property (nonatomic, readonly) BOOL currentlyExecuting;

- (id)initWithView:(CDVView*)view;
- (void)dispose;

- (void)resetRequestId;
- (void)enqueueCommandBatch:(NSString*)batchJSON;

- (void)fetchCommandsFromJs;
- (void)executePending;
- (BOOL)execute:(CDVInvokedUrlCommand*)command;

@end
