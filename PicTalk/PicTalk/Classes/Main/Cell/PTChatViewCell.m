//
//  PTChatViewCell.m
//  PicTalk
//
//  Created by wangzhong on 15/7/10.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTChatViewCell.h"

@implementation PTChatViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.picImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick)];
    [self.picImageView addGestureRecognizer:ges];
    
    
    self.meImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *ges1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick)];
    [self.meImageView addGestureRecognizer:ges1];
}

- (void)imageClick
{
    if (self.tapblock) {
        self.tapblock();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
