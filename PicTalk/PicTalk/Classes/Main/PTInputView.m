//
//  PTInputView.m
//  PicTalk
//
//  Created by wangzhong on 15/7/9.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTInputView.h"

@implementation PTInputView

+ (instancetype) inputView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"PTInputView" owner:nil options:nil] lastObject];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
