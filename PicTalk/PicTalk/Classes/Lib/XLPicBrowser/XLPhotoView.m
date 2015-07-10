//
//  XLPhotoView.m
//  XLPicBrowser
//
//  Created by hebe on 15/2/5.
//  Copyright (c) 2015年 ___HebeTien___. All rights reserved.
//

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height
#define screen_scale  [UIScreen mainScreen].scale

#import "XLPhotoView.h"

#import "MBProgressHUD.h"
#import "SDWebImageManager.h"

@interface XLPhotoView()<UIScrollViewDelegate,UIActionSheetDelegate>

@property(nonatomic,strong)UIImageView *imageView;

@property(nonatomic,assign)CGRect firstRect;

@end

@implementation XLPhotoView

-(instancetype)initWithFrame:(CGRect)frame {
    self =[super initWithFrame:frame];
    if (self) {
        
        self.imageView =[UIImageView new];
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.backgroundColor =[UIColor clearColor];
        self.delegate = self;
        self.decelerationRate = UIScrollViewDecelerationRateFast;//快点停下来
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(first:) name:isFirstShow object:nil];
        
        // 监听点击
        UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired =1;
        UITapGestureRecognizer *doubleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        singleTap.numberOfTouchesRequired =1;
        [singleTap requireGestureRecognizerToFail:doubleTap];//单击等待双击失效后触发
        [self addGestureRecognizer:singleTap];
        [self addGestureRecognizer:doubleTap];
        
        //长按手势识别器
        UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        //设置手势识别器属性（长按几秒触发事件）
        longPress.minimumPressDuration=1.0f;
        //注册手势识别器
        [self addGestureRecognizer:longPress];
    }
    return self;
}

-(void)first:(NSNotification *)sender {
    UIImageView *tempView =[sender object];
    self.firstRect =[tempView convertRect:tempView.bounds toView:nil];
}

-(void)singleTap {
    int index =self.frame.origin.x/(screen_width+20);
    // 通知代理
    if ([self.myDelegate respondsToSelector:@selector(photoViewDidSingleTap:index:imageView:)]) {
        [self.myDelegate photoViewDidSingleTap:self index:index imageView:self.imageView];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    
    CGPoint touchPoint = [tap locationInView:self];
    
    if (self.zoomScale < 1.0 || self.zoomScale == self.maximumZoomScale) {
        [self setZoomScale:1.0 animated:YES];
    } else {
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
}

-(void)longPress:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {//避免重复执行
        UIActionSheet *sheet =[[UIActionSheet alloc]initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                           destructiveButtonTitle:@"保存图片"
                                                otherButtonTitles:nil];
        [sheet showInView:self];
        return;
    }else  if (sender.state == UIGestureRecognizerStateEnded) {
        return;
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (buttonIndex ==0) {
        // 通知代理
        if ([self.myDelegate respondsToSelector:@selector(photoViewDidLongPress:image:)]) {
            [self.myDelegate photoViewDidLongPress:self image:self.imageView.image];
        }
    }
}


-(void)setImage:(UIImage *)image {
    _image =image;
    
//    BOOL longImage =image.size.height/image.size.width > screen_height/screen_width;//判断长图
//    CGFloat width =longImage?(image.size.height>screen_height*screen_scale*1.2?screen_width:image.size.width/image.size.height*screen_height):screen_width;
    
    CGFloat width =screen_width;
    CGFloat height =image.size.height/image.size.width*width;
    CGFloat x =width<screen_width?(screen_width/2-width/2):0;
    CGFloat y =height<screen_height?(screen_height/2-height/2):0;
    CGRect rect =CGRectMake(x, y, width, height);
    
    if (self.firstShow) {
        self.firstShow =NO;
        
        self.imageView.frame =self.firstRect;
        [UIView animateWithDuration:0.3 animations:^{
            self.imageView.frame =rect;
        }];
    }else {
        self.imageView.frame =rect;
    }
    
    self.imageView.image =image;
    
    // 设置伸缩比例
    self.maximumZoomScale = 2.0;
    self.minimumZoomScale = 0.5;
    self.zoomScale = 1.0;
}

-(void)downloadLargeImage:(NSURL *)url{
    
    MBProgressHUD *hhub =[[MBProgressHUD alloc]initWithView:self];
    hhub.labelText =@"加载中...";
    hhub.mode = MBProgressHUDModeDeterminate;
    [hhub showAnimated:YES whileExecutingBlock:^{
        usleep(MAXFLOAT);
    }];
    [self addSubview:hhub];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager downloadImageWithURL:url options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (receivedSize > 0) {
            hhub.progress = (float)receivedSize/expectedSize;
        }
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image && finished) {
            [self setImage:image];
            
            [hhub removeFromSuperview];
        }
    }];
}

#pragma mark -scrollView代理方法
//拉大捏合进行时
-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //大于表示正在捏合，小于表示正在拉大
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width)/2 :0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height)/2 :0;
    
    self.imageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX, scrollView.contentSize.height/2 + offsetY);
}

//返回一个放大或者缩小的视图
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
