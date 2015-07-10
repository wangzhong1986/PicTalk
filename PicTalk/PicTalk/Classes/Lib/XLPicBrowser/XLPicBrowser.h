//
//  XLPicBrowser.h
//  XLPicBrowser
//
//  Created by hebe on 15/2/5.
//  Copyright (c) 2015年 ___HebeTien___. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class XLPicBrowser;
//@protocol XLPicBrowserDelegate <NSObject>
//
//@optional
//-(void)picBrowserDidSaveImage:(XLPicBrowser *)picBrowser image:(UIImage *)image;//通过长按，取到image（可以自行保存）
//@end


@interface XLPicBrowser : UIView

//@property(nonatomic ,weak)id<XLPicBrowserDelegate> delegate;

+(instancetype)browserWithPhotos:(NSArray *)photos withIndex:(int)index;//图片数组和当前页

-(void)show;//展示

@property (nonatomic, assign) BOOL fromCircle;//如果来自原图（例如头像），打开此属性

@end
