//
//  XLPhotoView.h
//  XLPicBrowser
//
//  Created by hebe on 15/2/5.
//  Copyright (c) 2015年 ___HebeTien___. All rights reserved.
//

#define isFirstShow @"isFirstShow"

#import <UIKit/UIKit.h>

@class XLPhotoView;
@protocol XLPhotoViewDelegate <NSObject>
-(void)photoViewDidSingleTap:(XLPhotoView *)photoView index:(int)index imageView:(UIImageView *)imageView;//单击图片
-(void)photoViewDidLongPress:(XLPhotoView *)photoView image:(UIImage *)image;
@end

@interface XLPhotoView : UIScrollView

@property (nonatomic, weak) id<XLPhotoViewDelegate> myDelegate;
@property(nonatomic,strong)UIImage *image;
@property(nonatomic,assign)BOOL firstShow;

-(void)downloadLargeImage:(NSURL *)url;

@end
