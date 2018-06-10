//
//  ViewController.m
//  Bugly-Ionic
//
//  Created by 陈晋 on 2018/6/10.
//  Copyright © 2018年 ajhin. All rights reserved.
//

#import "ViewController.h"
#import "CDVView.h"

@interface ViewController ()

@property (nonatomic, strong) CDVView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.webView = [[CDVView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
