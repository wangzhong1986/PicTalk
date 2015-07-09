//
//  PTRegisterViewController.m
//  PicTalk
//
//  Created by wangzhong on 15/7/8.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTRegisterViewController.h"
#import "AppDelegate.h"

@interface PTRegisterViewController ()
@property (weak, nonatomic) IBOutlet UIButton *ResignBtn;
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
- (IBAction)registerBtnAction:(id)sender;
- (IBAction)backAction:(id)sender;

@end

@implementation PTRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"注册";
    
    self.userField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
    [self.ResignBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
}

- (IBAction)registerBtnAction:(id)sender {
    
    //-1.隐藏键盘
    [self.view endEditing:YES];
    
    //0.判断用户输入是否为手机号码
    if (![self.userField isTelphoneNum]) {
        [MBProgressHUD showError:@"请输入正确的手机号码" toView:self.view];
        return;
    }
    
    //1.把用户数据储存单例
    [PTUserInfo sharedPTUserInfo].registerUser = self.userField.text;
    [PTUserInfo sharedPTUserInfo].registerPwd = self.pwdField.text;

    //2.调用工具类的xmppUserRegister方法
    [PTXMPPTool sharedPTXMPPTool].registerOperation = YES;
    
    //3.提示
    [MBProgressHUD showMessage:@"正在注册中..." toView:self.view];
    
    __weak typeof (self) weakSelf = self;
    [[PTXMPPTool sharedPTXMPPTool] xmppResgister:^(XMPPResultType type) {
        [weakSelf handleResultType:type];
    }];
}

- (void) handleResultType:(XMPPResultType)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //隐藏Loading
        [MBProgressHUD hideHUDForView:self.view];
        
        if (type == XMPPResultTypeRegisterSuccess) {
            
            //1.回到上个控制器
            [self dismissViewControllerAnimated:NO completion:nil];
            
            //2.通知登录控制器修改用户名
            if (self.delegate && [self.delegate respondsToSelector:@selector(registerViewControllerDidFinishRegister)]) {
                [self.delegate registerViewControllerDidFinishRegister];
            }
            
        }
        else if (type == XMPPResultTypeRegisterFailure)
        {
            
            [MBProgressHUD showError:@"注册失败，用户名重复" toView:self.view];
        }
        
        else
        {
            [MBProgressHUD showError:@"网络不给力" toView:self.view];
        }
        
    });
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textChange:(id)sender {
    
    //设置注册按钮可用状态
    BOOL enabled = (self.userField.text.length != 0 && self.pwdField.text.length != 0);
    
    self.ResignBtn.enabled = enabled;
}

- (IBAction)pwdChange:(id)sender {
    //设置注册按钮可用状态
    BOOL enabled = (self.userField.text.length != 0 && self.pwdField.text.length != 0);
    
    self.ResignBtn.enabled = enabled;
}
@end
