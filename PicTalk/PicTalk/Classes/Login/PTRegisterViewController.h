//
//  PTRegisterViewController.h
//  PicTalk
//
//  Created by wangzhong on 15/7/8.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PTRegisterViewControllerDelegate <NSObject>

- (void)registerViewControllerDidFinishRegister;

@end

@interface PTRegisterViewController : UIViewController

@property (nonatomic,weak) id<PTRegisterViewControllerDelegate> delegate;

@end
