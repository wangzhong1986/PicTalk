//
//  PTEditProfileTableViewController.h
//  PicTalk
//
//  Created by wangzhong on 15/7/9.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PTEditProfileTableViewControllerDelegate <NSObject>

- (void) editProfileTableViewControllerdidClickSaveBtn;

@end

@interface PTEditProfileTableViewController : UITableViewController

@property (nonatomic, strong) UITableViewCell *cell;

@property (nonatomic, weak) id<PTEditProfileTableViewControllerDelegate> delegate;

@end
