//
//  AppDelegate.m
//
//  Created by wangzhong on 15/7/7.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "AppDelegate.h"
#import "PTNavigationController.h"


/*
 * 在AppDelegate实现登录
 
 1. 初始化XMPPStream
 2. 连接到服务器[传一个JID]
 3. 连接到服务成功后，再发送密码授权
 4. 授权成功后，发送"在线" 消息
 */
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 设置导航栏背景
    [PTNavigationController setupNavTheme];
    
    // 从沙盒里加载用户数据至PTUserInfo
    [[PTUserInfo sharedPTUserInfo] loadUserInfoFromSandBox];
    
    //判断用户登录状态
    if ([PTUserInfo sharedPTUserInfo].loginStatus == YES) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = storyboard.instantiateInitialViewController;
        
        //自动登录服务器
        [[PTXMPPTool sharedPTXMPPTool] xmppUserLogin:nil];
    }
    
    return YES;
}






@end
