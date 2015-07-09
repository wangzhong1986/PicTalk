//
//  PTProfileTableViewController.m
//  PicTalk
//
//  Created by wangzhong on 15/7/9.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTProfileTableViewController.h"
#import "XMPPvCardTemp.h"
#import "PTEditProfileTableViewController.h"

@interface PTProfileTableViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PTEditProfileTableViewControllerDelegate>

/**
 *
 *    头像
 *
 *    author:wz
 **/
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

/**
 *
 *    昵称
 *
 *    author:wz
 **/
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;

/**
 *
 *    帐号
 *
 *    author:wz
 **/
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

/**
 *
 *    公司
 *
 *    author:wz
 **/
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;

/**
 *
 *    部门
 *
 *    author:wz
 **/
@property (weak, nonatomic) IBOutlet UILabel *orgunitLabel;

/**
 *
 *    职位
 *
 *    author:wz
 **/
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/**
 *
 *    电话
 *
 *    author:wz
 **/
@property (weak, nonatomic) IBOutlet UILabel *telphoneLabel;

/**
 *
 *    职位
 *
 *    author:wz
 **/
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation PTProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人信息";
    
    [self LoadVCard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) LoadVCard
{
    // 获取个人信息
    XMPPvCardTemp *myVCard = [PTXMPPTool sharedPTXMPPTool].vCard.myvCardTemp;
    
    //设置头像
    if (myVCard.photo) {
        self.headImageView.image = [UIImage imageWithData:myVCard.photo];
    }
    
    //设置昵称
    self.nickLabel.text = myVCard.nickname;
    
    //设置帐号
    self.accountLabel.text = [PTUserInfo sharedPTUserInfo].user;
    
    //设置公司
    self.companyLabel.text = myVCard.orgName;
    
    //部门
    if (myVCard.orgUnits.count > 0) {
        self.orgunitLabel.text = myVCard.orgUnits[0];
    }
    
    //职位
    self.titleLabel.text = myVCard.title;
    
    //电话
    self.telphoneLabel.text = myVCard.note;
    
    //邮件
    self.emailLabel.text = myVCard.mailer;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //选择图片
    if (cell.tag == 0) {
        PTLog(@"选择图片");
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
        
        [sheet showInView:self.view];
    }
    //跳转下个控制器
    else if (cell.tag == 1) {
        PTLog(@"跳转下个控制器");
        [self performSegueWithIdentifier:@"EditVCardSegue" sender:cell];
    }
    //tag == 2 不做任何操作
    else
    {
        PTLog(@"不做任何操作");
        return;
    }
}

#pragma mark ActionSheet 代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //取消
    if (buttonIndex == 2) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    //照相
    if (buttonIndex == 0)
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    //相册
    else
    {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark 图片选择器的代理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    PTLog(@"%@",info);

    self.headImageView.image = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //更新个人信息
    [self editProfileTableViewControllerdidClickSaveBtn];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // 获取编辑个人信息控制器
    id destVc = segue.destinationViewController;
    
    if ([destVc isKindOfClass:[PTEditProfileTableViewController class]]) {
        PTEditProfileTableViewController *vc = destVc;
        vc.cell = sender;
        vc.delegate = self;
    }
}

#pragma mark -编辑个人信息控制器代理
- (void) editProfileTableViewControllerdidClickSaveBtn
{
    
    //更新到服务器
    XMPPvCardTemp *vCard = [PTXMPPTool sharedPTXMPPTool].vCard.myvCardTemp;

    
    //所有数据都更新一遍
    //昵称
    vCard.nickname = self.nickLabel.text;
    
    //图片
    vCard.photo = UIImagePNGRepresentation(self.headImageView.image);
    
    //公司
    vCard.orgName = self.companyLabel.text;
    
    //部门
    if (self.orgunitLabel.text.length > 0) {
         vCard.orgUnits = @[self.orgunitLabel.text];
    }
    
    //职位
    vCard.title = self.titleLabel.text;
    
    //电话
    vCard.note = self.telphoneLabel.text;
    
    //邮件
    vCard.mailer = self.emailLabel.text;
    
    //XMPP 内部实现上传到服务器
    [[PTXMPPTool sharedPTXMPPTool].vCard updateMyvCardTemp:vCard];
}


@end
