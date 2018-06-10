//
//  SearchViewController.h
//  Bugly-iOS
//
//  Created by 陈晋 on 2018/6/9.
//  Copyright © 2018年 ajhin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchViewController;

@protocol SearchControllerDelegate <NSObject>

/**
 *  按下取消按钮
 *
 *  @param controller SearchController
 */
- (void)questionSearchCancelButtonClicked:(SearchViewController *)controller;

@end

@interface SearchViewController : UIViewController

@property (nonatomic, assign) id<SearchControllerDelegate> delegate;

- (void)showInViewController:(UIViewController *)controller;
- (void)hide:(void(^)(void))completion;

@end

@implementation UIView (General)

- (CALayer *)addSubLayerWithFrame:(CGRect)frame color:(CGColorRef)colorRef
{
    CALayer *layer = [CALayer layer];
    layer.frame = frame;
    layer.backgroundColor = colorRef;
    [self.layer addSublayer:layer];
    return layer;
}

- (CALayer *)addBottomFillLineWithColor:(CGColorRef)color
{
    return [self addSubLayerWithFrame:CGRectMake(0,
                                                 self.frame.size.height - 0.5f,
                                                 [UIScreen mainScreen].bounds.size.width,
                                                 0.5f)
                                color:color];
}

@end

@implementation UIImage (General)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [UIImage imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
