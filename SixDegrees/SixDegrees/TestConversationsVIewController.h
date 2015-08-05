//
//  TestConversationsVIewController.h
//  SixDegrees
//
//  Created by Daniel Moreno on 7/10/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ConversationStore;

@interface TestConversationsVIewController : UITableViewController

- (instancetype) initWithConversationStore: (ConversationStore *) store;

@end
