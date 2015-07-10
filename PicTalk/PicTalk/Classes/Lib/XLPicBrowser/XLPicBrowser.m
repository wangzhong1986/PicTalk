//
//  XLPicBrowser.m
//  XLPicBrowser
//
//  Created by hebe on 15/2/5.
//  Copyright (c) 2015年 ___HebeTien___. All rights reserved.
//

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height

#import "XLPicBrowser.h"
#import "XLPhotoView.h"
//#import "DownLoadImageView.h"
//#import "XLHubView.h"
#import "ALAssetsLibrary+SaveImage.h"

@interface XLPicBrowser ()<UIScrollViewDelegate,XLPhotoViewDelegate>

@property(nonatomic,strong)UIScrollView *scrollView;//滚动的背景view
@property(nonatomic,strong)XLPhotoView *photoView;

@property(nonatomic,strong)NSMutableArray *photoViews;

@property(nonatomic,strong)NSArray *photos;//所有的图片对象
@property(nonatomic,assign)int currentPage;//当前展示的图片索引

@property(nonatomic,strong)UIPageControl *pageControl;
@property(nonatomic,strong)UIView *downloadView;

@end


@implementation XLPicBrowser

-(instancetype)initWithPhotos:(NSArray *)photos withIndex:(int)index{
    self =[super initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
    if (self) {
        
        self.backgroundColor =[UIColor blackColor];
        
        self.photos =photos;
        self.currentPage =index;
        
        for (int i = 0; i<_photos.count; i++) {
            UIImageView *imgView =_photos[i];
            UIImage *image = imgView.image;
            
            self.scrollView.contentOffset = CGPointMake(self.currentPage *(screen_width+20), 0);
            self.scrollView.contentSize =CGSizeMake((screen_width+20) * _photos.count, 0);
            
            
            self.photoView =[[XLPhotoView alloc]init];
            self.photoView.myDelegate =self;
            if (i ==self.currentPage) {
                
                self.photoView.firstShow =YES;
                
                UIImageView *tempImageView =self.photos[i];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:isFirstShow object:tempImageView];
            }
            
            self.photoView.frame =CGRectMake(i*(screen_width+20)+10, 0, screen_width, screen_height);
            self.photoView.image =image;
            
            [self.scrollView addSubview:self.photoView];
            
            [self.photoViews addObject:self.photoView];
            

        }
        
        
        //创建页面控制器
        self.pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, screen_height-30, screen_width, 30)];
        self.pageControl.numberOfPages=self.photos.count;
        self.pageControl.currentPageIndicatorTintColor=[UIColor colorWithRed:255/255.0 green:203/255.0 blue:2/255.0 alpha:0.7];
        self.pageControl.currentPage=self.currentPage;
        //给页码控制器绑定方法
        [self.pageControl addTarget:self action:@selector(paging:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.pageControl];
        if (photos.count <=1)
        {
            self.pageControl.hidden = YES;
        }
        
        self.downloadView =[[UIView alloc]initWithFrame:CGRectMake(320-50, 10, 40, 40)];
        self.downloadView.backgroundColor =[[UIColor blackColor] colorWithAlphaComponent:0.8];
        self.downloadView.layer.cornerRadius = self.downloadView.frame.size.width/2;
        self.downloadView.layer.masksToBounds = YES;
        [self addSubview:self.downloadView];
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"downloadyellow2_26"]];
        imgView.frame = CGRectMake(10, 10, 20, 20);
        imgView.userInteractionEnabled = YES;
        [self.downloadView addSubview:imgView];
        
        UITapGestureRecognizer  *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(downloadImage)];
        [self.downloadView addGestureRecognizer:tap];
    }
    return self;
}

-(void)downloadImage
{
    XLPhotoView *temp = self.photoViews[self.currentPage];
    
    [self didSave:temp.image];
}

+(instancetype)browserWithPhotos:(NSArray *)photos withIndex:(int)index {
    return [[self alloc]initWithPhotos:photos withIndex:index];
}

-(void)paging:(UIPageControl *)sender {
    
    NSInteger pageNO = sender.currentPage;
    [self.scrollView setContentOffset:CGPointMake((screen_width+20)*pageNO, 0) animated:YES];
}

-(void)show {
    
    UIWindow *window =[UIApplication sharedApplication].keyWindow;
    window.windowLevel =UIWindowLevelStatusBar;
    [window addSubview:self];
    
    self.downloadView.alpha = self.pageControl.alpha = 0.0;
    self.backgroundColor =[UIColor clearColor];
    
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor =[UIColor blackColor];
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.downloadView.alpha = self.pageControl.alpha = 1.0;
    }];
}


-(UIScrollView *)scrollView {
    if (!_scrollView) {
        
        _scrollView =[[UIScrollView alloc]initWithFrame:CGRectMake(-10, 0, screen_width+20, screen_height)];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.pagingEnabled =YES;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor =[UIColor clearColor];
        
        [self addSubview:_scrollView];
        
    }
    return _scrollView;
}

-(NSMutableArray *)photoViews {
    if (!_photoViews) {
        _photoViews =[NSMutableArray array];
    }
    return _photoViews;
}

-(void)photoViewDidSingleTap:(XLPhotoView *)photoView index:(int)index imageView:(UIImageView *)imageView{
    
    UIImageView *tempView = self.photos[index];
    XLPhotoView *tempPhoto =(XLPhotoView *)imageView.superview;
    
    UIWindow *window =[UIApplication sharedApplication].keyWindow;
    window.windowLevel =UIWindowLevelNormal;
    CGRect frame = [tempView convertRect:tempView.bounds toView:nil];//获取相对于屏幕的坐标
    
    
    if (_fromCircle)
    {
        tempPhoto.zoomScale =1.0;
        
        CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
        move.toValue = [NSValue valueWithCGPoint:CGPointMake(frame.origin.x+frame.size.width/2, frame.origin.y+frame.size.height/2)];
        
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale.fromValue = @(1.0);
        scale.toValue = @(frame.size.width/imageView.frame.size.width);
        
        CABasicAnimation *cornerRadius = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        cornerRadius.fromValue = @(0.0);
        cornerRadius.toValue = @(imageView.frame.size.width/2);
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[move,scale,cornerRadius];
        group.duration = 0.3;
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = NO;
        
        [imageView.layer addAnimation:group forKey:nil];

        
        [UIView animateWithDuration:0.3 animations:^{
            self.downloadView.alpha = self.pageControl.alpha = 0.0;
            self.backgroundColor =[UIColor clearColor];
            
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
        
    }else
    {
        if (imageView.frame.size.height >screen_height-[UIApplication sharedApplication].statusBarFrame.size.height-44-44 || frame.origin.y >screen_height-44-44 || frame.origin.y+frame.size.height < [UIApplication sharedApplication].statusBarFrame.size.height+44+44)
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.downloadView.alpha = self.pageControl.alpha = tempPhoto.alpha = 0.0;
                self.backgroundColor = [UIColor clearColor];
                tempPhoto.transform = CGAffineTransformMakeScale(0.85, 0.85);
                
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        }else
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.downloadView.alpha = self.pageControl.alpha = 0.0;
                tempPhoto.zoomScale =1.0;
                self.backgroundColor =[UIColor clearColor];
                imageView.frame =[tempView convertRect:tempView.bounds toView:nil];
                
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        }
    }
}

//下载
-(void)photoViewDidLongPress:(XLPhotoView *)photoView image:(UIImage *)image {
    
//    // 通知代理
//    if ([self.delegate respondsToSelector:@selector(picBrowserDidSaveImage:image:)]) {
//        [self.delegate picBrowserDidSaveImage:self image:image];
//    }
    
    [self didSave:image];
}

-(void)didSave:(UIImage *)image
{
    if (image) {
        ALAssetsLibrary *library = [ALAssetsLibrary new];
        [library saveImage:image toAlbum:@"PicTalk" withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                [MBProgressHUD showError:@"保存失败"];
            }else{
                [MBProgressHUD showError:@"保存成功"];
            }
            
        }];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentPage=scrollView.contentOffset.x/(screen_width+20);
    
    //设置pageControl页码
    self.pageControl.currentPage=self.currentPage;
    
    for (XLPhotoView *temp in self.photoViews) {
        if (temp !=self.photoViews[self.currentPage]) {
            temp.zoomScale =1.0;
        }
    }
}

@end
