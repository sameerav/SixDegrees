//
//  ConversationsTableViewController.h
//  
//
//  Created by Daniel Moreno on 7/15/15.
//
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
@class User;
@class ConversationsViewController;

@interface ConversationsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
- (instancetype)initWithUser:(User *)me andCVC:(ConversationsViewController *)cvc;
@property (weak, nonatomic) ConversationsViewController *cvc;
- (void) reloadData;
@end
