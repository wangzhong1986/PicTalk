//
//  PTEditProfileTableViewController.m
//  PicTalk
//
//  Created by wangzhong on 15/7/9.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTEditProfileTableViewController.h"

@interface PTEditProfileTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation PTEditProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题和textField的默认值
    self.title = self.cell.textLabel.text;
    
    self.textField.text = self.cell.detailTextLabel.text;
    
    //右边 添加保存按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveBtnClick)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveBtnClick
{
    //1.更改cell的detailTextLabel的文本信息
    self.cell.detailTextLabel.text = self.textField.text;
    
    //如果没有detailTextLabel，第一次不会显示，需要强制刷新
    [self.cell layoutSubviews];
    
    //2.当前控制器消失
    [self.navigationController popViewControllerAnimated:YES];
    
    //3.保存数据到服务器
    if (self.delegate && [self.delegate respondsToSelector:@selector(editProfileTableViewControllerdidClickSaveBtn)]) {
        [self.delegate editProfileTableViewControllerdidClickSaveBtn];
    }

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
