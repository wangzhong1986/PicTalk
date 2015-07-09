//
//  PTUserInfo.m
//  PicTalk
//
//  Created by wangzhong on 15/7/8.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTUserInfo.h"

#define USERKEY @"user"
#define PASSWORDKEY @"pwd"
#define LOGINSTATUS @"loginstauts"




@implementation PTUserInfo

singleton_implementation(PTUserInfo)

-(void) saveUserInfoToSandBox
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.user forKey:USERKEY];
    [defaults setObject:self.pwd forKey:PASSWORDKEY];
    [defaults setBool:self.loginStatus forKey:LOGINSTATUS];
    [defaults synchronize];
}

-(void) loadUserInfoFromSandBox
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.user = [defaults objectForKey:USERKEY];
    self.pwd = [defaults objectForKey:PASSWORDKEY];
    self.loginStatus = [defaults boolForKey:LOGINSTATUS];
}

-(NSString *)jid
{
    return [NSString stringWithFormat:@"%@@%@",self.user,domain];
}

@end
