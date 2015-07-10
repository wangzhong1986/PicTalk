//
//  PTChatViewController.m
//  PicTalk
//
//  Created by wangzhong on 15/7/9.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTChatViewController.h"
#import "PTInputView.h"
#import "UIImageView+WebCache.h"
#import <BCSticker/BCSticker.h>
#import "PTChatViewCell.h"
#import "XLPicBrowser.h"

@interface PTChatViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UITextViewDelegate>
{
    NSFetchedResultsController *_resultController;
}

@property (nonatomic, strong) NSLayoutConstraint *inputViewHeightConstraint;//inputView 高度约束

@property (nonatomic, strong) NSLayoutConstraint *inputViewBottomConstraint;//inputView 底部约束

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation PTChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"聊天";
    
    [self setupView];
    
    //加载数据
    [self loadMsgs];
    
    // 监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) keyboardWillShow:(NSNotification *)noti
{
    PTLog(@"%@",noti);
    
    //键盘高度
    CGRect kbEndFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat kbHeight = kbEndFrm.size.height;
    
    self.inputViewBottomConstraint.constant = kbHeight;
    
    //表格滚动到地步
    [self scrollToTableViewBottom];
}

- (void) keyboardWillHide:(NSNotification *)noti
{
    self.inputViewBottomConstraint.constant = 0;
}


- (void) setupView
{
    //代码方式实现自动布局 VFL
    
    //创建TableView
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;//代码实现自动布局需要去除该属性
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    //创建输入框
    PTInputView *inputView = [PTInputView inputView];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;//代码实现自动布局需要去除该属性
    inputView.textView.delegate = self;
    
    //添加按钮事件
    [inputView.addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:inputView];
    
    //自动布局
    
    //水平方向约束
    
    NSDictionary *views = @{@"tableView":tableView,@"inputView":inputView};
    
    //1.tableView水平方向的约束
    NSArray *tableViewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:tableViewHConstraints];
    
    //2.inputView水平方向的约束
    NSArray *inputViewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[inputView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:inputViewHConstraints];
    
    //垂直方向约束
    NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableView]-0-[inputView(50)]-0-|" options:0 metrics:nil views:views];
    PTLog(@"%@",vConstraints);
    
    [self.view addConstraints:vConstraints];
    
    self.inputViewBottomConstraint = [vConstraints lastObject];
    self.inputViewHeightConstraint = vConstraints[2];
}

#pragma mark - 加载数据库数据显示
- (void) loadMsgs
{
    NSManagedObjectContext *ctx = [PTXMPPTool sharedPTXMPPTool].msgStorage.mainThreadManagedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    //自己的JID信息
    //还要好友的JID的信息（1对1）
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",[PTUserInfo sharedPTUserInfo].jid,self.friendJid.bare];
    PTLog(@"%@",predicate);
    request.predicate = predicate;
    
    //时间排序 升
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    
    //查询
    _resultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
    _resultController.delegate = self;
    
    NSError *err = nil;
    [_resultController performFetch:&err];
    if (err) {
        PTLog(@"%@",err);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _resultController.fetchedObjects.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    static NSString *ID = @"ChatCell";
    PTChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell= (PTChatViewCell *)[[[NSBundle  mainBundle] loadNibNamed:@"PTChatViewCell" owner:self options:nil]  lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 获取聊天消息对象
    XMPPMessageArchiving_Message_CoreDataObject *msg = _resultController.fetchedObjects[indexPath.row];
    
    // 判断是图片还是纯文本
    NSString *chatType = [msg.message attributeStringValueForName:@"bodyType"];
    if ([chatType isEqualToString:@"image"]) {
        //下图片显示
        
        cell.meImageView.hidden = YES;
        cell.picImageView.hidden = YES;
        cell.textView.hidden = YES;
        
        __weak typeof (cell) weakCell = cell;
        //显示消息
        if ([msg.outgoing boolValue]) {//自己发
            [cell.meImageView sd_setImageWithURL:[NSURL URLWithString:msg.body] placeholderImage:[UIImage imageNamed:@"DefaultProfileHead_qq"]];
            cell.meImageView.hidden = NO;
            
            cell.tapblock = ^(){
                XLPicBrowser *browser = [XLPicBrowser browserWithPhotos:@[weakCell.meImageView] withIndex:0];
                [browser show];
            };
        }else{//别人发的
            [cell.picImageView sd_setImageWithURL:[NSURL URLWithString:msg.body] placeholderImage:[UIImage imageNamed:@"DefaultProfileHead_qq"]];
            cell.picImageView.hidden = NO;
            
            cell.tapblock = ^(){
                XLPicBrowser *browser = [XLPicBrowser browserWithPhotos:@[weakCell.picImageView] withIndex:0];
                [browser show];
            };
        }
        
        
 
        
    }else if([chatType isEqualToString:@"text"]){
        
        //显示消息
        if ([msg.outgoing boolValue]) {//自己发
            cell.textView.text = msg.body;
            cell.textView.textAlignment = NSTextAlignmentRight;
            cell.textView.textColor = [UIColor blueColor];
        }else{//别人发的
            cell.textView.text = msg.body;
            cell.textView.textAlignment = NSTextAlignmentLeft;
            cell.textView.textColor = [UIColor brownColor];
            
        }
        cell.meImageView.hidden = YES;
        cell.picImageView.hidden = YES;
        cell.textView.hidden = NO;
    }
    
    return cell;
}

#pragma mark ResultController的代理
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    // 刷新数据
    [self.tableView reloadData];
    
    //表格滚动到地步
    [self scrollToTableViewBottom];
}

#pragma mark - textView 代理
- (void)textViewDidChange:(UITextView *)textView
{
    //获取ContentSize
    CGFloat contentH = textView.contentSize.height;
    PTLog(@"textView的content的高度 %f",contentH);
    
    // 大于33，超过一行的高度/ 小于68 高度是在三行内
    if (contentH > 33 && contentH < 68 ) {
        self.inputViewHeightConstraint.constant = contentH + 18;
    }
    else if(contentH <= 33)
    {
        self.inputViewHeightConstraint.constant = 50;
    }
    
    
    
    NSString *text = textView.text;
    
    //换行即为发送
    if ([text rangeOfString:@"\n"].length !=0) {
        PTLog(@"发送数据 %@",text);
        
        // 去除换行字符
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [self sendMsgWithText:text bodyType:@"text"];
        
        //发送后清空
        textView.text = nil;
        
        // 发送完消息 把inputView的高度改回来
        self.inputViewHeightConstraint.constant = 50;
    }
    else
    {
        PTLog(@"%@",textView.text);
    }
}

#pragma mark - 发送聊天消息
-(void)sendMsgWithText:(NSString *)text bodyType:(NSString *)bodyType{
    
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    
    //text 纯文本
    //image 图片
    [msg addAttributeWithName:@"bodyType" stringValue:bodyType];
    
    // 设置内容
    [msg addBody:text];
    NSLog(@"%@",msg);
    [[PTXMPPTool sharedPTXMPPTool].xmppStream sendElement:msg];
}

#pragma mark - 滚动到底部
- (void) scrollToTableViewBottom
{
    NSInteger lastRow = _resultController.fetchedObjects.count - 1;
    if (lastRow<0) {
        return;
    }
    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark 调用花熊SDK
-(void)addBtnClick{
    
    [CreatOneViewController createInVC:self withParameters:@{@"appid":@"181222", @"appkey":@"sdk-hx-iosandroidvip1507090001"} callBack:^(NSString *url, UIImage *img, NSString *topicId) {
        
        [self sendMsgWithText:url bodyType:@"image"];
    }];
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
