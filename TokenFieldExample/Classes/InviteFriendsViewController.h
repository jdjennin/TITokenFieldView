//
//  InviteFriendsViewController.h
//  TokenFieldExample
//
//  Created by Jacob Jennings on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendSelectionDelegate;

@interface InviteFriendsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
  BOOL searching;
  
  id <FriendSelectionDelegate> delegate;
  NSString *friendSource;
  NSMutableArray *tableData;
  NSMutableArray *contactData;
  NSMutableArray *savedContacts;
  NSMutableArray *searchData;
  
  NSMutableArray *indexHeaders;
  NSMutableArray *actualHeaders;
  
  IBOutlet UISearchBar *searcher;
  IBOutlet UITableView *contactsList;
}

@property (nonatomic, assign) id <FriendSelectionDelegate> delegate;
@property (nonatomic, retain) NSString *friendSource;
@property (nonatomic, retain) NSMutableArray *tableData;
@property (nonatomic, retain) NSMutableArray *contactData;
@property (nonatomic, retain) NSMutableArray *savedContacts;

@property (nonatomic, retain) IBOutlet UISearchBar *searcher;
@property (nonatomic, retain) IBOutlet UITableView *contactsList;

- (id)initWithFriendSource:(NSString *)source;
- (void)goBack;
- (void)doneSelecting;

@end

@protocol FriendSelectionDelegate <NSObject>

@required
- (void)inviteFriendsController:(InviteFriendsViewController *)controller didFinishWithFriends:(NSMutableArray *)friends;

@optional
- (void)inviteFriendsControllerDidCancel:(InviteFriendsViewController *)controller;

@end
