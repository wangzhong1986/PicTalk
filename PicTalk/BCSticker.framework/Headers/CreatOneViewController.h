//
//  CreatOneViewController.h
//  BearClub2015
//
//  Created by huaixiong on 15/2/4.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface CreatOneViewController :UIViewController

/**
 *     parameters
 *     appid:  必填   NSString
 *     appkey: 必填   NSString
 *     userid:       NSString
 *     username:     NSString
 */

+(void) createInVC:(UIViewController *)vc withParameters:(NSDictionary *)parameters callBack:(void (^)(NSString *url , UIImage *img, NSString *topicId))callBack;

@end
