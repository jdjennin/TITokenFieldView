//
//  InviteFriendGroupsViewController.m
//  TokenFieldExample
//
//  Created by Jacob Jennings on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InviteFriendGroupsViewController.h"
#import "GroupsTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation InviteFriendGroupsViewController

@synthesize groupsTable;
@synthesize savedContacts;
@synthesize delegate;

- (void)setTitle:(NSString *)title {
  [super setTitle:title];
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
  [titleLabel setTextAlignment:UITextAlignmentCenter];
  [titleLabel setTextColor:[UIColor whiteColor]];
  [titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
  [titleLabel setBackgroundColor:[UIColor clearColor]];
  titleLabel.text = title;
  if (self.navigationItem.prompt) {
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(-60, -36, 320, 30)];
    [promptLabel setTextAlignment:UITextAlignmentCenter];
    [promptLabel setTextColor:[UIColor whiteColor]];
    [promptLabel setBackgroundColor:[UIColor clearColor]];
    promptLabel.text = self.navigationItem.prompt;
    self.navigationItem.prompt = @"";
    [titleLabel setClipsToBounds:NO];
    [titleLabel addSubview:promptLabel];
    [promptLabel release];
  }
  self.navigationItem.titleView = titleLabel;
  [titleLabel release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
    self.savedContacts = [NSMutableArray array];
  }
  return self;
}

- (void)dealloc
{
  self.delegate = nil;
  self.groupsTable.delegate = nil;
  self.groupsTable.dataSource = nil;
  self.groupsTable = nil;
  self.savedContacts = nil;
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  self.groupsTable.layer.backgroundColor = [UIColor clearColor].CGColor;
  
  self.navigationItem.prompt = @"Invite friends from other places";
  self.title = @"Groups";
  
  UIButton *theView = [UIButton buttonWithType:UIButtonTypeCustom];
  [theView addTarget:self action:@selector(cancelGroups) forControlEvents:UIControlEventTouchUpInside];
  [theView setBackgroundImage:[UIImage imageNamed:@"cancel-btn.png"] forState:UIControlStateNormal];
  [theView setFrame:CGRectMake(0, 0, 55, 30)];
  UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:theView];
  self.navigationItem.leftBarButtonItem = left;
  [left release];
  
  UIButton *theOtherView = [UIButton buttonWithType:UIButtonTypeCustom];
  [theOtherView addTarget:self action:@selector(doneWithGroups) forControlEvents:UIControlEventTouchUpInside];
  [theOtherView setBackgroundImage:[UIImage imageNamed:@"done-btn.png"] forState:UIControlStateNormal];
  [theOtherView setFrame:CGRectMake(0, 0, 55, 30)];
  UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:theOtherView];
  self.navigationItem.rightBarButtonItem = right;
  [right release];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 38;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"groupCell";
  NSArray *rows = [[NSArray alloc] initWithObjects:@"Address Book", @"Socialize.it Friends", @"Facebook Friends", @"Twitter Followers", nil];
  
  GroupsTableViewCell *cell = (GroupsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GroupsTableViewCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
    
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell.numFriends setCenter:CGPointMake(cell.numFriends.center.x, 19)];
  }
  
  NSPredicate *p = [NSPredicate predicateWithFormat:@"source CONTAINS[c] %@", [rows objectAtIndex:[indexPath row]]];
  int friendCount = [[self.savedContacts filteredArrayUsingPredicate:p] count];
  if (friendCount > 0) {
    cell.numFriends.hidden = NO;
    [cell.numFriends setTitle:[NSString stringWithFormat:@"%i", friendCount] forState:UIControlStateNormal];
    [cell.numFriends setTitleColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0] forState:UIControlStateNormal];
  } else {
    cell.numFriends.hidden = YES;
  }
  cell.textLabel.text = [rows objectAtIndex:[indexPath row]];
  
  [rows release];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  NSArray *controllers = [[NSArray alloc] initWithObjects:@"Address Book", @"Socialize.it Friends", @"Facebook Friends", @"Twitter Followers", nil];
  InviteFriendsViewController *vc = [[InviteFriendsViewController alloc] initWithFriendSource:[controllers objectAtIndex:[indexPath row]]];
  [vc setDelegate:self];
  
  [self.navigationController pushViewController:vc animated:YES];
  
  NSPredicate *p = [NSPredicate predicateWithFormat:@"source CONTAINS[c] %@", [controllers objectAtIndex:[indexPath row]]];
  NSMutableArray *mute = [[self.savedContacts filteredArrayUsingPredicate:p] mutableCopy];
  [vc setSavedContacts:mute];
  [mute release];
  
  [vc reloadInputViews];
  
  [controllers release];
  [vc release];
}

#pragma mark - Actions

- (void)cancelGroups {
  if ([delegate respondsToSelector:@selector(inviteFriendGroupsControllerDidCancel:)]) {
    [delegate inviteFriendGroupsControllerDidCancel:self];
  }
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)doneWithGroups {
  // Save selected contacts as tokens before dismissing
  [delegate inviteFriendGroupsController:self didFinishWithFriends:savedContacts];
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - FriendSelection methods

- (void)inviteFriendsController:(InviteFriendsViewController *)controller didFinishWithFriends:(NSMutableArray *)friends {
  NSPredicate *p = [NSPredicate predicateWithFormat:@"source CONTAINS[c] %@", controller.friendSource];
  NSMutableArray *savedCopy = (NSMutableArray *)([self.savedContacts filteredArrayUsingPredicate:p]);
  
  for (NSMutableDictionary *d in savedCopy) {
    if (![friends containsObject:d]) {
      [self.savedContacts removeObject:d];
    }
  }
  
  for (NSMutableDictionary *d in friends) {
    if (![self.savedContacts containsObject:d]) {
      [self.savedContacts addObject:d];
    }
  }
  [self.groupsTable reloadData];
}

- (void)inviteFriendsControllerDidCancel:(InviteFriendsViewController *)controller {
  
}

@end
