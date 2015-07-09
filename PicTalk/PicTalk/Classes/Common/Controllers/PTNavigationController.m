//
//  PTNavigationController.m
//  PicTalk
//
//  Created by wangzhong on 15/7/8.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTNavigationController.h"

@interface PTNavigationController ()

@end

@implementation PTNavigationController

// 设置导航栏的主题
+(void)setupNavTheme
{
    // 设置导航样式
    
    UINavigationBar *navBar = [UINavigationBar appearance
                               ];
    // 1.设置导航条的背景
    
    // 高度不会拉伸，但是宽度会拉伸
    [navBar setBackgroundImage:[UIImage imageNamed:@"topbarbg_ios7"] forBarMetrics:UIBarMetricsDefault];
    
    // 2.设置栏的字体

    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    
    // 设置状态栏的样式
    // xcode5以上，创建的项目，默认的话，这个状态栏的样式由控制器决定
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}

//如果控制器是由导航控制器管理，设置状态栏样式时，要在导航控制器里设置
//或者在Info.plist里设置
//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}


@end