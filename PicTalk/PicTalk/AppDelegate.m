//
//  AppDelegate.m
//
//  Created by wangzhong on 15/7/7.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "AppDelegate.h"
#import "PTNavigationController.h"
#import "XMPPFramework.h"
#import "DDLog.h"
#import "DDTTYLogger.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 沙盒的路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"%@",path);
    
    // 打开XMPP的日志
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
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
