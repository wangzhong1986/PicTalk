//
//  PTAddContactTableViewController.m
//  PicTalk
//
//  Created by wangzhong on 15/7/9.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTAddContactTableViewController.h"

@interface PTAddContactTableViewController ()<UITextFieldDelegate>

@end

@implementation PTAddContactTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // 1.获取好友帐号
    NSString *user = textField.text;
    PTLog(@"%@",user);
    
    // 判读是否手机号
    if (![textField isTelphoneNum]) {
        //提示
        [self showAlert:@"请输入正确的手机号码"];
        return YES;
    }
    
    // 判断是不是添加自己
    if ([user isEqualToString:[PTUserInfo sharedPTUserInfo].user]) {
        [self showAlert:@"不能添加自己为好友"];
        
        return YES;
    }
    
    // 2.添加请求
    // 添加好友 XMPP订阅
    XMPPJID *friendJid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",user,domain]];
    
    // 好友是否已经存在
    if ([[PTXMPPTool sharedPTXMPPTool].rosterStorage userExistsWithJID:friendJid xmppStream:[PTXMPPTool sharedPTXMPPTool].xmppStream]) {
        
        [self showAlert:@"当前好友已经存在"];
        return YES;
    }

    [[PTXMPPTool sharedPTXMPPTool].roster subscribePresenceToUser:friendJid];
    
    return YES;
}

-(void)showAlert:(NSString *)msg{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:msg delegate:nil cancelButtonTitle:@"谢谢" otherButtonTitles:nil, nil];
    [alert show];
}

@end
