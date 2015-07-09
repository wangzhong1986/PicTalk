//
//  PTMeViewController.m
//  PicTalk
//
//  Created by wangzhong on 15/7/8.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTMeViewController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"

@interface PTMeViewController ()
/**
 *
 *    账号
 *
 *    author:wz
 **/
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

/**
 *
 *    昵称
 *
 *    author:wz
 **/
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;

/**
 *
 *    头像
 *
 *    author:wz
 **/
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
- (IBAction)LogOutAction:(id)sender;

@end

@implementation PTMeViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取个人信息
    XMPPvCardTemp *myVCard = [PTXMPPTool sharedPTXMPPTool].vCard.myvCardTemp;
    
    //设置头像
    if (myVCard.photo) {
        self.headImageView.image = [UIImage imageWithData:myVCard.photo];
    }
    
    //设置昵称
    self.nickLabel.text = myVCard.nickname;
    
    //设置帐号
    NSString *userAccount = [PTUserInfo sharedPTUserInfo].user;
    self.accountLabel.text = [NSString stringWithFormat:@"帐号:%@",userAccount];
}


- (IBAction)LogOutAction:(id)sender {

    [[PTXMPPTool sharedPTXMPPTool] xmppUserLogout];
    
}
@end
