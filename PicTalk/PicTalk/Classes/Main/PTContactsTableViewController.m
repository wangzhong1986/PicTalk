//
//  PTContactsTableViewController.m
//  PicTalk
//
//  Created by wangzhong on 15/7/9.
//  Copyright (c) 2015年 wangzhong. All rights reserved.
//

#import "PTContactsTableViewController.h"
#import "PTChatViewController.h"

@interface PTContactsTableViewController ()<NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *_resultController;
}

@end

@implementation PTContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 从数据库获取
    [self loadFriendsNew];
}

- (void) loadFriendsNew
{
    /**
     *    如何使用coreData获取数据
     *    1.上下文［关联到数据库XMPPRoser.sqlite］
     *    2.FetchRequest
     *    3.设置过滤条件，排序
     *    4.执行请求获取数据
     *
     *    author:wz
     **/
    
    //1.
    NSManagedObjectContext *context = [PTXMPPTool sharedPTXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    //2.XMPP Roser中找
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //3.过滤当前登录用户的好友
    
    NSString *jid = [PTUserInfo sharedPTUserInfo].jid;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@", jid];
    request.predicate = pre;
    
    //排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    //4
    _resultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    _resultController.delegate = self;
    
    NSError *err = nil;
    [_resultController performFetch:&err];
    
    if (err) {
        PTLog(@"%@",err);
    }

}

#pragma mark 当数据库内容改变，调用该方法
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    PTLog(@"数据改变了");
    
    [self.tableView reloadData];
}


//- (void) loadFriends
//{
//    /**
//     *    如何使用coreData获取数据
//     *    1.上下文［关联到数据库XMPPRoser.sqlite］
//     *    2.FetchRequest
//     *    3.设置过滤条件，排序
//     *    4.执行请求获取数据
//     *
//     *    author:wz
//     **/
//    
//    //1.
//    NSManagedObjectContext *context = [PTXMPPTool sharedPTXMPPTool].rosterStorage.mainThreadManagedObjectContext;
//    
//    //2.XMPP Roser中找
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
//    
//    //3.过滤当前登录用户的好友
//    
//    NSString *jid = [PTUserInfo sharedPTUserInfo].jid;
//    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@", jid];
//    request.predicate = pre;
//    
//    //排序
//    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
//    request.sortDescriptors = @[sort];
//    
//    //4
//    self.friends = [context executeFetchRequest:request error:nil];
//    
//    PTLog(@"%@",self.friends);
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _resultController.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    static NSString *ID = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    // 获取对应好友
    XMPPUserCoreDataStorageObject *friend = _resultController.fetchedObjects[indexPath.row];

    //    sectionNum
    //    “0”- 在线
    //    “1”- 离开
    //    “2”- 离线
    switch ([friend.sectionNum intValue]) {//好友状态
        case 0:
            cell.detailTextLabel.text = @"在线";
            break;
        case 1:
            cell.detailTextLabel.text = @"离开";
            break;
        case 2:
            cell.detailTextLabel.text = @"离线";
            break;
        default:
            break;
    }

    
    cell.textLabel.text = friend.jidStr;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        PTLog(@"删除好友");
        // 获取对应好友
        XMPPUserCoreDataStorageObject *friend = _resultController.fetchedObjects[indexPath.row];
        
        XMPPJID *friendJid = friend.jid;
        [[PTXMPPTool sharedPTXMPPTool].roster removeUser:friendJid];

    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取对应好友
    XMPPUserCoreDataStorageObject *friend = _resultController.fetchedObjects[indexPath.row];
    
    XMPPJID *friendJid = friend.jid;
    
    [self performSegueWithIdentifier:@"ChatSegue" sender:friendJid];
}
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    id destVc = segue.destinationViewController;
    
    if ([destVc isKindOfClass:[PTChatViewController class]]) {
        
        PTChatViewController *vc = destVc;
        vc.friendJid = sender;
    }
}


@end
