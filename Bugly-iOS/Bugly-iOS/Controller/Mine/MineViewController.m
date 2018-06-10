//
//  MineViewController.m
//  Bugly-iOS
//
//  Created by 陈晋 on 2018/6/8.
//  Copyright © 2018年 ajhin. All rights reserved.
//

#import "MineViewController.h"
#import "TableViewController.h"
#import "CollectionViewController.h"
#import "UIImage+ImageEffects.h"
#import "CustomHeader.h"

void *CustomHeaderInsetObserver = &CustomHeaderInsetObserver;

@interface MineViewController ()

@property (nonatomic, strong) CustomHeader *header;

@end

@implementation MineViewController

-(instancetype)init
{
    TableViewController *table = [[TableViewController alloc] initWithNibName:@"TableViewController" bundle:nil];
    CollectionViewController *collectionView = [[CollectionViewController alloc] initWithNibName:@"CollectionViewController" bundle:nil];
    
    
    self = [super initWithControllers:table,collectionView, nil];
    if (self) {
        // your code
        self.segmentMiniTopInset = 64;
        if (@available(iOS 11.0, *)) {
            self.segmentMiniTopInset = 84;
        }
        self.headerHeight = 200;
    }
    
    return self;
}

#pragma mark - override

-(UIView<ARSegmentPageControllerHeaderProtocol> *)customHeaderView
{
    if (_header == nil) {
        _header = [[[NSBundle mainBundle] loadNibNamed:@"CustomHeader" owner:nil options:nil] lastObject];
        _header.backgroundColor = [UIColor redColor];
    }
    return _header;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addObserver:self forKeyPath:@"segmentTopInset" options:NSKeyValueObservingOptionNew context:CustomHeaderInsetObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if (context == CustomHeaderInsetObserver) {
        CGFloat inset = [change[NSKeyValueChangeNewKey] floatValue];
        [self.header updateHeadPhotoWithTopInset:inset];
    }
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"segmentTopInset"];
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
