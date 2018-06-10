//
//  CDVViewCommandDelegateImpl.h
//  Bugly
//
//  Created by 陈晋 on 2018/6/6.
//  Copyright © 2018年 ajhin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDVCommandDelegate.h"

@class CDVView;
@class CDVViewCommandQueue;

@interface CDVViewCommandDelegateImpl : NSObject <CDVCommandDelegate>{
@private
    __weak CDVView* _view;
    NSRegularExpression* _callbackIdPattern;
@protected
    __weak CDVViewCommandQueue* _commandQueue;
    BOOL _delayResponses;
}
- (id)initWithView:(CDVView*)view;
- (void)flushCommandQueueWithDelayedJs;
@end
