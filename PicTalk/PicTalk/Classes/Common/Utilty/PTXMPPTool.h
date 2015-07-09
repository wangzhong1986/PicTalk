//
//  PTXMPPTool.h
//  PicTalk
//
//  Created by wangzhong on 15/7/9.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

typedef enum{
    XMPPResultTypeLoginSuccess,
    XMPPResultTypeLoginFailure,
    XMPPResultTypeLoginNetError,
    XMPPResultTypeRegisterSuccess,
    XMPPResultTypeRegisterFailure
}XMPPResultType;


/**
 *
 *    XMPP 请求结果block
 *
 *    author:wz
 **/
typedef void (^XMPPResultBlock)(XMPPResultType type);

@interface PTXMPPTool : NSObject

singleton_interface(PTXMPPTool)


@property (nonatomic, strong) XMPPvCardTempModule *vCard;//电子名片 ;

/**
 *
 *    注册表示 YES代表注册／NO代表登录
 *
 *    author:wz
 **/
@property (nonatomic, assign, getter=isRegisterOperation) BOOL registerOperation;

/**
 *
 *    用户登录
 *
 *    author:wz
 **/
- (void) xmppUserLogin:(XMPPResultBlock)rsBlock;

/**
 *
 *    用户注销
 *
 *    author:wz
 **/
- (void) xmppUserLogout;

/**
 *
 *    用户注册
 *
 *    author:wz
 **/
- (void) xmppResgister:(XMPPResultBlock)rsBlock;


@end
