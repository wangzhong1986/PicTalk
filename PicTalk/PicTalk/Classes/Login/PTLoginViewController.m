//
//  PTLoginViewController.m
//  PicTalk
//
//  Created by wangzhong on 15/7/8.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTLoginViewController.h"
#import "PTRegisterViewController.h"
#import "PTNavigationController.h"

@interface PTLoginViewController ()<PTRegisterViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
- (IBAction)loginBtnAction:(id)sender;

@end

@implementation PTLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置textFiled和Btn
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
    [self.pwdField addLeftViewWithImage:@"Card_Lock"];
    [self.loginBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
    // 设置用户名为上次登录的用户名
    
    //从单例获取
    NSString *user = [PTUserInfo sharedPTUserInfo].user;
    self.userLabel.text = user;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // 获取目标控制器
    id destVc = segue.destinationViewController;
    
    // 判断是否为注册控制器
    if ([destVc isKindOfClass:[PTNavigationController class]]) {
        PTNavigationController *vc = destVc;
        
        //获取根控制器
        id destRegisterVc = (PTRegisterViewController *)vc.topViewController;
        if ([destRegisterVc isKindOfClass:[PTRegisterViewController class]]) {
            PTRegisterViewController *registerVc = (PTRegisterViewController *)vc.topViewController;
            
            //设置代理
            registerVc.delegate = self;
        }
  
    }

}


- (IBAction)loginBtnAction:(id)sender {
    
    /**
     *   把用户名和密码放入PTUserInfo的单例中
     **/
    
    PTUserInfo *userInfo = [PTUserInfo sharedPTUserInfo];
    userInfo.user = self.userLabel.text;
    userInfo.pwd = self.pwdField.text;
    
    [super login];
    
}

#pragma mark - 注册页面代理
- (void)registerViewControllerDidFinishRegister
{
    PTLog(@"完成注册");
    
    //完成注册
    self.userLabel.text = [PTUserInfo sharedPTUserInfo].registerUser;
    
    //提示用户登录
    [MBProgressHUD showSuccess:@"注册成功，请重新输入密码登录" toView:self.view];
    
}

@end
