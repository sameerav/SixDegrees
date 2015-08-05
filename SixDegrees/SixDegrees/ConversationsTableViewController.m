//  ConversationsTableViewController.m
//  
//
//  Created by Daniel Moreno on 7/15/15.
//
//

#import "ConversationsTableViewController.h"
#import "ConversationsViewController.h"
#import "ConversationCell.h"
#import "UserConnection.h"
#import "ParseAPI.h"
#import "User.h"
#import "MessengerButton.h"
#import "OtherUserViewController.h"
#import "ConversationsViewController.h"
#import "Suggestion.h"
#import "SixDegreesLoginViewController.h"

@interface ConversationsTableViewController ()
@property (strong, nonatomic) User *me;
@property (strong, nonatomic) User *selected;
@property (strong, nonatomic) NSMutableArray *allObjects;
@property (strong, nonatomic) NSMutableArray *allObjectsCopy;
@end

@implementation ConversationsTableViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    [self.tableView reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // copy the references to original objects
    self.allObjectsCopy = [NSMutableArray array];
    [self.allObjectsCopy addObjectsFromArray:self.allObjects];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.allObjects = [NSMutableArray array];
    for (UserConnection *connection in self.allObjectsCopy) {
        NSString *name;
        BOOL validConnection = NO;
        if ([self.me.objectId isEqualToString:connection.addedUserID]) {
            name = connection.initialUserName;
        } else {
            name = connection.addedUserName;
        }
        
        searchText = searchText.lowercaseString;
        name = name.lowercaseString;
        
        NSArray *nameComponents = [name componentsSeparatedByString:@" "];
        
        for (NSString *component in nameComponents) {
            NSString *namePart = component;
            if ([namePart length] > [searchText length]) {
                namePart = [namePart substringToIndex:[searchText length]];
            }
            
            if ([searchText isEqualToString:namePart]) {
                validConnection = YES;
            }
        }
        
        if (validConnection) {
            [self.allObjects addObject:connection];
        }
        
    }
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.allObjects = self.allObjectsCopy;
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
}

- (instancetype)initWithUser:(User *)me andCVC:(ConversationsViewController *)cvc{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        UINib *convoCellNib = [UINib nibWithNibName:@"ConversationCell" bundle:nil];
        [self.tableView registerNib:convoCellNib forCellReuseIdentifier:@"ConversationCell"];
        
        self.me = me;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.cvc = cvc;
        
        if (self.me != nil) {
            self.cvc.spinner.hidden = NO;
            [self.cvc.spinner startAnimating];
            [self.cvc.view setNeedsDisplay];
            __block NSNumber *count = [NSNumber numberWithInt:0];
            
            PFQuery *firstQuery = [[UserConnection query] whereKey:@"initialUserID" equalTo:self.me.objectId];
            PFQuery *secondQuery = [[UserConnection query] whereKey:@"addedUserID" equalTo:self.me.objectId];
            PFQuery *query = [PFQuery orQueryWithSubqueries:@[firstQuery, secondQuery]];
            [query orderByDescending:@"createdAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                self.allObjects = [objects mutableCopy];
                for (UserConnection *connection in self.allObjects) {
                    for (Suggestion *suggestion in connection.suggestions) {
                        [suggestion fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            count = [NSNumber numberWithInt:[count intValue]+1];
                            
                            if ([count intValue] == (int)[me.connections count]) {
                                [self.cvc.spinner stopAnimating];
                                self.cvc.spinner.hidden = YES;
                                [self.cvc.view setNeedsDisplay];
                            }
                        }];
                    }
                }
                [self.tableView reloadData];
            }];
        }
    }
    self.refreshControl = [[UIRefreshControl alloc] init];
    UIColor *salmon =[UIColor colorWithRed:241.0/255.0 green:98.0/255.0 blue:109.0/255.0 alpha:1.0];
    self.refreshControl.backgroundColor = salmon;
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
    return self;
}

-(void) reloadData{
    [self.tableView reloadData];
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        PFQuery *firstQuery = [[UserConnection query] whereKey:@"initialUserID" equalTo:self.me.objectId];
        PFQuery *secondQuery = [[UserConnection query] whereKey:@"addedUserID" equalTo:self.me.objectId];
        PFQuery *query = [PFQuery orQueryWithSubqueries:@[firstQuery, secondQuery]];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.allObjects = [objects mutableCopy];
            for (UserConnection *connection in self.allObjects) {
                for (Suggestion *suggestion in connection.suggestions) {
                    [suggestion fetchIfNeededInBackground];
                }
            }
        [self.tableView reloadData];
        }];
        [self.refreshControl endRefreshing];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.allObjects) {
        UserConnection *connection = (UserConnection *)(self.allObjects[indexPath.row]);
        ConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[ConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ConversationCell"];
        }
        
        MessengerButton *button = [[MessengerButton alloc] initWithFrame:CGRectMake(0, 0,  35, 35)];
        
        if ([self.me.objectId isEqualToString:connection.addedUserID]) {
            [ParseAPI getUser:connection.initialUserID withBlock:^(User *friend) {
                cell.profilePicture.profileID = friend.FBID;
                button.fbid = friend.FBID;
                cell.nameLabel.text = friend.name;
                [self.view setNeedsDisplay];
            }];
        } else {
            [ParseAPI getUser:connection.addedUserID withBlock:^(User *friend) {
                cell.profilePicture.profileID = friend.FBID;
                cell.nameLabel.text = friend.name;
                button.fbid = friend.FBID;
                cell.user = button.fbid;
                [self.view setNeedsDisplay];
            }];
        }
        cell.friendsLabel.text = [NSString stringWithFormat:@"%@ Mutual Friends", connection.mutualFriends];
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.size.width / 2;
        cell.profilePicture.layer.borderWidth = 1.0;
        cell.profilePicture.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.profilePicture.clipsToBounds = YES;
        
        [button setBackgroundImage:[UIImage imageNamed:@"messenger"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"messengerBlue"] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageNamed:@"messengerBlue"] forState:UIControlStateHighlighted];
        
        //Here is where we will input the FBID of the other user in the thread.
        //Make sure that the app_scoped_user_id is the one being used
        //Maybe we can do this somewhere else and simply store the conversion on Parse?
        [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        return nil;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
     [self openProfileAtPathIndex:indexPath];
}

-(void) openProfileAtPathIndex :(NSIndexPath *)indexPath{
    self.cvc.spinner.hidden = NO;
    [self.cvc.spinner startAnimating];
    ConversationCell *cell = (ConversationCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [ParseAPI getUserFromFBID:cell.user withBlock:^(User *other) {
        OtherUserViewController *ouvc = [[OtherUserViewController alloc] initWithFBID: cell.user andConnection:self.allObjects[indexPath.row] andURL:other.url andSuggestions:nil];
        UIViewController* activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        [self.cvc.spinner stopAnimating];
        self.cvc.spinner.hidden = YES;
        [activeVC presentViewController:ouvc animated:YES completion:nil];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.allObjects) {
        return 1;
    }else{
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Avenir Next" size:20];
        [messageLabel sizeToFit];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section != 0) {
        return 0;
    } else {
        if (self.allObjects) {
            return self.allObjects.count;
        } else {
            return 0;
        }
    }
}

- (void)checkButtonTapped: (id) sender event: (id) event {
    //kicks off messenger flow, subclass of button carries info and begins conversion
    MessengerButton *buttonClicked = (MessengerButton *)sender;
    [ParseAPI getUserFromFBID:buttonClicked.fbid withBlock:^(User *friend) {
        NSURL *url = [NSURL URLWithString:friend.url];
        [[UIApplication sharedApplication] openURL:url];
    }];
}

@end
