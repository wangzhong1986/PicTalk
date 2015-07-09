//
//  PTXMPPTool.m
//  PicTalk
//
//  Created by wangzhong on 15/7/9.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTXMPPTool.h"

#import "XMPPFramework.h"

@interface PTXMPPTool()<XMPPStreamDelegate>
{
    XMPPStream *_xmppStream;
    XMPPResultBlock _resultBlock;
}

// 1. 初始化XMPPStream
-(void)setupXMPPStream;


// 2.连接到服务器
-(void)connectToHost;

// 3.连接到服务成功后，再发送密码授权
-(void)sendPwdToHost;


// 4.授权成功后，发送"在线" 消息
-(void)sendOnlineToHost;

@end

@implementation PTXMPPTool

singleton_implementation(PTXMPPTool)




#pragma mark  -私有方法
#pragma mark 初始化XMPPStream
-(void)setupXMPPStream{
    
    _xmppStream = [[XMPPStream alloc] init];
    
    // 设置代理
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

#pragma mark 连接到服务器
-(void)connectToHost{
    PTLog(@"开始连接到服务器");
    if (!_xmppStream) {
        [self setupXMPPStream];
    }
    
    
    // 设置登录用户JID
    //resource 标识用户登录的客户端 iphone android
    
    //从PTUserInfo中获取用户名 注意区分注册用户与登录用户
    NSString *user = self.isRegisterOperation?[PTUserInfo sharedPTUserInfo].registerUser:[PTUserInfo sharedPTUserInfo].user;
    
    XMPPJID *myJID = [XMPPJID jidWithUser:user domain:@"wangzhong1986.local" resource:@"iphone" ];
    _xmppStream.myJID = myJID;
    
    // 设置服务器域名
    _xmppStream.hostName = @"wangzhong1986.local";//不仅可以是域名，还可是IP地址
    
    // 设置端口 如果服务器端口是5222，可以省略
    _xmppStream.hostPort = 5222;
    
    // 连接
    NSError *err = nil;
    if(![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err]){
        PTLog(@"%@",err);
    }
    
}


#pragma mark 连接到服务成功后，再发送密码授权
-(void)sendPwdToHost{
    PTLog(@"再发送密码授权");
    NSError *err = nil;
    
    //从PTUserInfo获取密码
    NSString *pwd = [PTUserInfo sharedPTUserInfo].pwd;
    
    [_xmppStream authenticateWithPassword:pwd error:&err];
    if (err) {
        PTLog(@"%@",err);
    }
}

#pragma mark  授权成功后，发送"在线" 消息
-(void)sendOnlineToHost{
    
    PTLog(@"发送 在线 消息");
    XMPPPresence *presence = [XMPPPresence presence];
    PTLog(@"%@",presence);
    
    [_xmppStream sendElement:presence];
    
    
}
#pragma mark -XMPPStream的代理
#pragma mark 与主机连接成功
-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    PTLog(@"与主机连接成功");
    
    // 注册操作链接成功，发送注册密码
    if (self.isRegisterOperation) {
        NSString *pwd = [PTUserInfo sharedPTUserInfo].registerPwd;
        
        [_xmppStream registerWithPassword:pwd error:nil];
    }
    //登录操作 主机连接成功后，发送密码进行授权
    else
    {
        [self sendPwdToHost];
    }
    
}
#pragma mark  与主机断开连接
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    
    // 认为调用disconnet也会调用此方法，error为nil
    if (error) {
        
        // 如果有错误，代表连接失败
        PTLog(@"与主机断开连接 %@",error);
        
        if (_resultBlock) {
            _resultBlock(XMPPResultTypeLoginNetError);
        }
        
    }
}


#pragma mark 授权成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    PTLog(@"授权成功");
    
    [self sendOnlineToHost];
    
    //成功block
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginSuccess);
    }
    
}


#pragma mark 授权失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    PTLog(@"授权失败 %@",error);
    
    //失败block
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginFailure);
    }
    
}

#pragma mark 注册成功
-(void)xmppStreamDidRegister:(XMPPStream *)sender
{
    PTLog(@"注册成功");
    
    //成功block
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterSuccess);
    }
}

#pragma mark 注册失败
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    PTLog(@"注册失败");
    
    //失败block
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterFailure);
    }
}


#pragma mark -公共方法
-(void)logout{
    // 1." 发送 "离线" 消息"
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
    
    // 2. 与服务器断开连接
    [_xmppStream disconnect];
}

- (void) xmppUserLogin:(XMPPResultBlock)rsBlock
{
    //block 存储
    _resultBlock = rsBlock;
    
    //如果以前链接过服务器，要先断开
    [_xmppStream disconnect];
    
    //链接主机，成功后发送登录授权密码
    [self connectToHost];
}

- (void) xmppUserLogout
{
    //1.发送离线消息
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
    
    //2.与服务器断开链接
    [_xmppStream disconnect];
    
    //3.回到登录页面
    [UIStoryboard showInitialVCWithName:@"Login"];
    
    //更改用户登录状态
    [PTUserInfo sharedPTUserInfo].loginStatus = NO;
    [[PTUserInfo sharedPTUserInfo] saveUserInfoToSandBox];
}

- (void) xmppResgister:(XMPPResultBlock)rsBlock
{
    //block 存储
    _resultBlock = rsBlock;
    
    //如果以前链接过服务器，要先断开
    [_xmppStream disconnect];
    
    //链接主机，成功后发送注册密码
    [self connectToHost];
}


@end
