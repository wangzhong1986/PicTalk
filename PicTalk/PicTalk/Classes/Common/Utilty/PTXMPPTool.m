//
//  PTXMPPTool.m
//  PicTalk
//
//  Created by wangzhong on 15/7/9.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTXMPPTool.h"




/*
 * PTXMPPTool实现登录
 
 1. 初始化XMPPStream
 2. 连接到服务器[传一个JID]
 3. 连接到服务成功后，再发送密码授权
 4. 授权成功后，发送"在线" 消息
 */

NSString *const PTLoginStatusChangeNotification = @"WCLoginStatusNotification";

@interface PTXMPPTool()<XMPPStreamDelegate>
{

    XMPPResultBlock _resultBlock;
    
    XMPPReconnect *_reconnect;//自动连接模块
    
    XMPPvCardCoreDataStorage *_vCardStorage;//电子名片存储
    
    XMPPvCardAvatarModule *_avatar;//头像
    
    XMPPMessageArchiving *_msgArchiving;//聊天模块
    
    
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
    
    //每添加一个模块都要激活，激活就会请求服务器获取相关数据，请求结束后将结果放在数据库中
    
    //添加自动连接模块
    _reconnect = [[XMPPReconnect alloc] init];
    [_reconnect activate:_xmppStream];
    
    //添加电子名片模块
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
    [_vCard activate:_xmppStream];//激活
    
    //头像模块
    _avatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    [_avatar activate:_xmppStream];//激活
    
    
    //花名册模块
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    [_roster activate:_xmppStream];
    
    //消息模块
    _msgStorage = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    _msgArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_msgStorage];
    [_msgArchiving activate:_xmppStream];
    
    //IOS 7 要在info.plist中添加Required background modes ＝ App provides Voice over IP services，并且只有真机上可见效果
    _xmppStream.enableBackgroundingOnSocket = YES;
    
    // 设置代理
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

#pragma mark 释放xmppStream相关的资源
-(void)teardownXmpp{
    
    // 移除代理
    [_xmppStream removeDelegate:self];
    
    // 停止模块
    [_reconnect deactivate];
    [_vCard deactivate];
    [_avatar deactivate];
    [_roster deactivate];
    [_msgArchiving deactivate];
    
    // 断开连接
    [_xmppStream disconnect];
    
    // 清空资源
    _reconnect = nil;
    _vCard = nil;
    _vCardStorage = nil;
    _avatar = nil;
    _roster = nil;
    _rosterStorage = nil;
    _msgArchiving = nil;
    _msgStorage = nil;
    _xmppStream = nil;
    
}

/**
 * 通知 WCHistoryViewControllers 登录状态
 *
 */
-(void)postNotification:(XMPPResultType)resultType{
    
    // 将登录状态放入字典，然后通过通知传递
    NSDictionary *userInfo = @{@"loginStatus":@(resultType)};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PTLoginStatusChangeNotification object:nil userInfo:userInfo];
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
    
    XMPPJID *myJID = [XMPPJID jidWithUser:user domain:domain resource:@"iphone" ];
    _xmppStream.myJID = myJID;
    
    // 设置服务器域名
    _xmppStream.hostName = @"192.168.31.112";//不仅可以是域名，还可是IP地址
    
    // 设置端口 如果服务器端口是5222，可以省略
    _xmppStream.hostPort = 5222;
    
    // 连接
    NSError *err = nil;
    if(![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err]){
        PTLog(@"%@",err);
    }
    
    // 通知正在连接中
    [self postNotification:XMPPResultTypeConnecting];
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
        
        // 通知网络不稳定
        [self postNotification:XMPPResultTypeLoginNetError];
        
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
    
    // 通知授权成功
    [self postNotification:XMPPResultTypeLoginSuccess];
}


#pragma mark 授权失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    PTLog(@"授权失败 %@",error);
    
    //失败block
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginFailure);
    }
    
    // 通知授权失败
    [self postNotification:XMPPResultTypeLoginFailure];
    
}

#pragma mark 接收到好友消息
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    PTLog(@"%@",message);
    
    //判断客户端不在前台，发出一个本地通知
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        PTLog(@"当前程序在后台");
        
        UILocalNotification *noti = [[UILocalNotification alloc] init];
        
        //设置内容
        noti.alertBody = [NSString stringWithFormat:@"%@\n%@",message.fromStr,message.body];
        
        //设置通知执行时间
        noti.fireDate = [NSDate date];
        
        //声音
        noti.soundName = @"default";
        
        //执行通知
        [[UIApplication sharedApplication] scheduleLocalNotification:noti];
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

-(void)dealloc{
    [self teardownXmpp];
}
@end
