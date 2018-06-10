//
//  SearchBar.m
//  Bugly-iOS
//
//  Created by 陈晋 on 2018/6/9.
//  Copyright © 2018年 ajhin. All rights reserved.
//

#import "SearchBar.h"

@implementation SearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (id)initWithCoder: (NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (id)sharedInit {
    self.backgroundColor = TEXTFIELD_BACKGROUNDC0LOR;
    self.placeholder = @"搜索";
    self.keyboardType = UIKeyboardTypeDefault;
    self.showsCancelButton = NO;
    // 删除UISearchBar中的UISearchBarBackground
    [self setBackgroundImage:[[UIImage alloc] init]];
    self.tintColor = APP_TINT_COLOR;
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:@"取消"];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
