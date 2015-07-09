//
//  PTUserInfo.h
//  PicTalk
//
//  Created by wangzhong on 15/7/8.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

static NSString *domain = @"wangzhong1986.local";

@interface PTUserInfo : NSObject

singleton_interface(PTUserInfo)

@property (nonatomic, copy) NSString * jid;

/**
 *
 *    用户名
 *
 *    author:wz
 **/
@property (nonatomic, copy) NSString* user;

/**
 *
 *    密码
 *
 *    author:wz
 **/
@property (nonatomic, copy) NSString* pwd;

/**
 *
 *    登录状态  YES表示登录过
 *
 *    author:wz
 **/
@property (nonatomic, assign) BOOL loginStatus;

/**
 *
 *    注册用户名
 *
 *    author:wz
 **/
@property (nonatomic, copy) NSString* registerUser;

/**
 *
 *    注册密码
 *
 *    author:wz
 **/
@property (nonatomic, copy) NSString* registerPwd;

/**
 *
 *    保存用户数据到沙盒
 *
 *    author:wz
 **/
-(void) saveUserInfoToSandBox;

/**
 *
 *    从沙盒里获取用户数据
 *
 *    author:wz
 **/
-(void) loadUserInfoFromSandBox;


@end
