//
//  TestConversationsVIewController.m
//  SixDegrees
//
//  Created by Daniel Moreno on 7/10/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "TestConversationsVIewController.h"
#import "ConversationStore.h"
#import "ConversationCell.h"
#import "Conversation.h"
@interface TestConversationsVIewController ()
@property (nonatomic) ConversationStore *store;
@end
@implementation TestConversationsVIewController

-(instancetype) initWithConversationStore: (ConversationStore *) store {
    self = [super initWithNibName:nil bundle:nil]  ;
    if (self) {
        self.store = store;
        self.tableView.rowHeight = 62;
        for (int i = 0; i < 20; i ++){
            [self.store createConversation];
        }
    }
    return self;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.store.allConversations.count;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    UINib *convoCellNib = [UINib nibWithNibName:@"ConversationCell" bundle:nil];
    [self.tableView registerNib:convoCellNib forCellReuseIdentifier:@"ConversationCell"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ConversationCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ConversationCell" forIndexPath:indexPath];
    Conversation *convo = self.store.allConversations[indexPath.row];
    cell.nameLabel.text = convo.otherUserName;
    cell.friendsLabel.text = [NSString stringWithFormat:@"%d", convo.mutualFriends];
    cell.profilePicture.profileID = @"me";
    cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.size.width / 2;
    cell.profilePicture.layer.borderWidth = 1.0;
    cell.profilePicture.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.profilePicture.clipsToBounds = YES;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setBackgroundImage:[UIImage imageNamed:@"messenger"] forState:UIControlStateNormal];
    cell.accessoryView = button;
    return cell;
}

@end
