//
//  PTChatViewCell.h
//  PicTalk
//
//  Created by wangzhong on 15/7/10.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^imageTapBlock)();
@interface PTChatViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UIImageView *meImageView;
@property (nonatomic, copy) imageTapBlock tapblock;

@end
