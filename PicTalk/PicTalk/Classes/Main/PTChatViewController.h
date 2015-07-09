//
//  PTChatViewController.h
//  PicTalk
//
//  Created by wangzhong on 15/7/9.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPJID.h"

@interface PTChatViewController : UIViewController

@property (nonatomic, strong) XMPPJID *friendJid;

@end
