//
//  InviteFriendGroupsViewController.h
//  TokenFieldExample
//
//  Created by Jacob Jennings on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InviteFriendsViewController.h"

@protocol InviteFriendsDelegate;
@interface InviteFriendGroupsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FriendSelectionDelegate> {
  IBOutlet UITableView *groupsTable;
  NSMutableArray *savedContacts;
  id <InviteFriendsDelegate> delegate;
}

@property (nonatomic, assign) id <InviteFriendsDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *groupsTable;
@property (nonatomic, retain) NSMutableArray *savedContacts;

- (void)cancelGroups;
- (void)doneWithGroups;

@end

@protocol InviteFriendsDelegate <NSObject>

@required
- (void)inviteFriendGroupsController:(InviteFriendGroupsViewController *)controller didFinishWithFriends:(NSMutableArray *)friends;

@optional
- (void)inviteFriendGroupsControllerDidCancel:(InviteFriendGroupsViewController *)controller;

@end