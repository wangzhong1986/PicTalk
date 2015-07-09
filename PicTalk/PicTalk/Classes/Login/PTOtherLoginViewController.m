//
//  PTOtherLoginViewController.m
//  PicTalk
//
//  Created by wangzhong on 15/7/8.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTOtherLoginViewController.h"

#import "AppDelegate.h"

@interface PTOtherLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
- (IBAction)loginBtnClick:(id)sender;
- (IBAction)backAction:(id)sender;

@end

@implementation PTOtherLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
    [self.loginBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
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

- (IBAction)loginBtnClick:(id)sender {
    
    /**
     *   把用户名和密码放入PTUserInfo的单例中
     **/

    PTUserInfo *userInfo = [PTUserInfo sharedPTUserInfo];
    userInfo.user = self.userField.text;
    userInfo.pwd = self.pwdField.text;
    
    
    [super login];
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)dealloc
{
    PTLog(@"%s",__func__);
}


@end
