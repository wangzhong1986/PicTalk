//
//  PTBaseLoginViewController.m
//  PicTalk
//
//  Created by wangzhong on 15/7/8.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTBaseLoginViewController.h"
#import "AppDelegate.h"

@interface PTBaseLoginViewController ()

@end

@implementation PTBaseLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)login{
    
    /**
     *
     *    官方登录实现
     *
     *    1.把用户名和密码放入PTUserInfo的单例中
     *    2.调用AppDelegate的一个login链接服务器
     *
     *
     **/

    //隐藏键盘
    [self.view endEditing:YES];
    
    
    //loading 正在登录
    [MBProgressHUD showMessage:@"正在登录中..."];

    [PTXMPPTool sharedPTXMPPTool].registerOperation = NO;
    
    //使用强引用会导致该VC不会被释放
    __weak typeof (self) weakSelf = self;
    [[PTXMPPTool sharedPTXMPPTool] xmppUserLogin:^(XMPPResultType type) {
        [weakSelf handleResultType:type];
    }];
}



- (void) handleResultType:(XMPPResultType)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //隐藏Loading
        [MBProgressHUD hideHUD];
        
        if (type == XMPPResultTypeLoginSuccess) {
            PTLog(@"登录成功");
            
            //更改用户登录状态
            [PTUserInfo sharedPTUserInfo].loginStatus = YES;
            
            //数据保存到沙盒
            [[PTUserInfo sharedPTUserInfo] saveUserInfoToSandBox];
            
            [self dismissViewControllerAnimated:NO completion:nil];
            
            //登录成功来到主页面
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.view.window.rootViewController = storyboard.instantiateInitialViewController;
            
        }
        else if (type == XMPPResultTypeLoginFailure)
        {
            PTLog(@"登录失败");
            
            [MBProgressHUD showError:@"用户名密码不正确"];
        }
        
        else
        {
            [MBProgressHUD showError:@"网络不给力"];
        }
        
    });
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
