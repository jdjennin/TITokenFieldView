//
//  InviteFriendsViewController.m
//  TokenFieldExample
//
//  Created by Jacob Jennings on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import "InviteFriendsTableViewCell.h"
#import <AddressBook/AddressBook.h>

#define WORK @"_$!<Work>!$_"
#define HOME @"_$!<Home>!$_"
#define MOBILE @"_$!<Mobile>!$_"
#define MAIN @"_$!<Main>!$_"

#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]

@implementation InviteFriendsViewController

@synthesize delegate;
@synthesize friendSource;
@synthesize tableData;
@synthesize contactData;
@synthesize savedContacts;
@synthesize searcher;
@synthesize contactsList;

- (void)setTitle:(NSString *)title {
  [super setTitle:title];
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
  [titleLabel setTextAlignment:UITextAlignmentCenter];
  [titleLabel setTextColor:[UIColor whiteColor]];
  [titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
  [titleLabel setBackgroundColor:[UIColor clearColor]];
  titleLabel.text = title;
  if (self.navigationItem.prompt) {
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(-70, -36, 320, 30)];
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
    self.tableData = [NSMutableArray array];
    self.contactData = [NSMutableArray array];
    self.savedContacts = [NSMutableArray array];
  }
  return self;
}

- (id)initWithFriendSource:(NSString *)source {
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    self.friendSource = source;
    self.tableData = [NSMutableArray array];
    self.contactData = [NSMutableArray array];
    self.savedContacts = [NSMutableArray array];
  }
  return self;
}

- (void)dealloc
{
  [indexHeaders release];
  [actualHeaders release];
  self.delegate = nil;
  self.friendSource = nil;
  self.tableData = nil;
  self.contactData = nil;
  self.savedContacts = nil;
  self.searcher.delegate = nil;
  self.searcher = nil;
  self.contactsList.delegate = nil;
  self.contactsList.dataSource = nil;
  self.contactsList = nil;
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
  
  // Depending on the source of our friends, we must populate our tableData
  searching = NO;
  
  indexHeaders = [[NSMutableArray alloc] initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
	actualHeaders = [[NSMutableArray alloc] init];
  
  self.navigationItem.prompt = @"Choose contacts to invite";
  self.title = friendSource;
  // NEED IMAGE FOR GROUPS BACK BUTTON
  UIButton *theView = [UIButton buttonWithType:UIButtonTypeCustom];
  [theView addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
  [theView setBackgroundImage:[UIImage imageNamed:@"Groups-Back-Btn.png"] forState:UIControlStateNormal];
  [theView setFrame:CGRectMake(0, 0, 65, 30)];
  UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:theView];
  self.navigationItem.leftBarButtonItem = left;
  [left release];
  //  self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Groups" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
  
  UIButton *theOtherView = [UIButton buttonWithType:UIButtonTypeCustom];
  [theOtherView addTarget:self action:@selector(doneSelecting) forControlEvents:UIControlEventTouchUpInside];
  [theOtherView setBackgroundImage:[UIImage imageNamed:@"done-btn.png"] forState:UIControlStateNormal];
  [theOtherView setFrame:CGRectMake(0, 0, 55, 30)];
  UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:theOtherView];
  self.navigationItem.rightBarButtonItem = right;
  [right release];
  
  // ***********************
  // Question: on the invite people from AddressBook screen, which communication route will the invited people be contacted through?
  // Question: does this need to hit the FB, Socialize.it, and Twitter APIs for Friday?
  // Fact: my public key cannot access their repo
  // ***********************
  if ([self.friendSource isEqualToString:@"Address Book"]) {
    ABAddressBookRef _ab = ABAddressBookCreate();
    CFArrayRef _peopleTemp = ABAddressBookCopyArrayOfAllPeople(_ab);
    CFMutableArrayRef _peopleMute = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(_peopleTemp), _peopleTemp);
    CFArraySortValues(_peopleMute, CFRangeMake(0, CFArrayGetCount(_peopleMute)), (CFComparatorFunction)ABPersonComparePeopleByName, (void*)ABPersonGetSortOrdering());
    
    CFRelease(_peopleTemp);
    
    NSString *lastHeader = @"A";
    
    for (int i = 0; i < CFArrayGetCount(_peopleMute); i++) {
      ABRecordRef _person = CFArrayGetValueAtIndex(_peopleMute, i);
      NSString *firstName = (NSString *)ABRecordCopyValue(_person, kABPersonFirstNameProperty);
      NSString *lastName = (NSString *)ABRecordCopyValue(_person, kABPersonLastNameProperty);
      ABMultiValueRef _emails = ABRecordCopyValue(_person, kABPersonEmailProperty);
      NSArray *emails = (NSArray *)ABMultiValueCopyArrayOfAllValues(_emails);
      if (emails == nil || [emails isKindOfClass:[NSNull class]] || [emails count] == 0) {
        [firstName release];
        [lastName release];
        [emails release];
        CFRelease(_emails);
        continue;
      }
      
      NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
      
      for (int j = 0; j < [emails count]; j++) {
        NSString *s = [emails objectAtIndex:j];
        
        NSString *type = (NSString *)ABMultiValueCopyLabelAtIndex(_emails, j);
        
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        [d setValue:name forKey:@"name"];
        
        if (type != nil && ![type isKindOfClass:[NSNull class]]) {
          if ([type isEqualToString:WORK]) {
            [d setValue:@"Work" forKey:@"type"];
          } else if ([type isEqualToString:HOME]) {
            [d setValue:@"Home" forKey:@"type"];
          } else if ([type isEqualToString:MOBILE]) {
            [d setValue:@"Mobile" forKey:@"type"];
          } else if ([type isEqualToString:MAIN]) {
            [d setValue:@"" forKey:@"type"];
          }
        } else {
          [d setValue:@"" forKey:@"type"];
        }
        
        [d setValue:s forKey:@"email"];
        [d setValue:friendSource forKey:@"source"];
        
        NSString *currentHeader = [name substringToIndex:1];
        
        NSMutableArray *namesWithFirstLetter = nil;
        
        if ([indexHeaders count] > 0 && [contactData count] > 0 && [[name substringToIndex:1] isEqualToString:lastHeader]) {
          namesWithFirstLetter = [contactData lastObject];
          lastHeader = [NSString stringWithFormat:@"%@", currentHeader];
          [namesWithFirstLetter addObject:d];
        } else {
          namesWithFirstLetter = [[NSMutableArray alloc] init];
          [namesWithFirstLetter addObject:d];
          [contactData addObject:namesWithFirstLetter];
          lastHeader = [NSString stringWithFormat:@"%@", [name substringToIndex:1]];
          [namesWithFirstLetter release];
        }
        if (![[actualHeaders lastObject] isEqualToString:lastHeader]) {
          [actualHeaders addObject:[NSString stringWithFormat:@"%@", lastHeader]];
        }
        
      }
      
      [firstName release];
      [lastName release];
      [emails release];
      CFRelease(_emails);
    }
    CFRelease(_peopleMute);
    CFRelease(_ab);
    
    [tableData addObjectsFromArray:contactData];
    [self.contactsList reloadData];
    
  } else if ([self.friendSource isEqualToString:@"Socialize.it Friends"]) {
    // Pull down the friends! Yay!
    
  } else if ([self.friendSource isEqualToString:@"Facebook Friends"]) {
    // Friends galore!
    
  } else if ([self.friendSource isEqualToString:@"Twitter Followers"]) {
    // Stalkers...boo...
    
  }
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  self.tableData = nil;
  self.contactData = nil;
  self.savedContacts = nil;
  self.navigationItem.leftBarButtonItem = nil;
  self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView methods

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  if (searching) {
    return nil;
  }
	return indexHeaders;
} 

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (searching) {
    return nil;
  }
	return [actualHeaders objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
  if (searching) {
    return 0;
  }
	for (NSString *headers in indexHeaders) {
		if ([headers isEqualToString:title]) {
			return [indexHeaders indexOfObject:headers];
		}
	}
	return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (searching) {
    return 1;
  }
  return [tableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (searching) {
    return [tableData count];
  }
  return [[tableData objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdent = @"friendCell";
  InviteFriendsTableViewCell *cell = (InviteFriendsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdent];
  if (cell == nil) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InviteFriendsTableViewCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
  }
  
  NSDictionary *contact = nil;
  if (searching) {
    contact = [tableData objectAtIndex:[indexPath row]];
  } else {
    contact = [[tableData objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
  }
  
  BOOL checked = [self.savedContacts containsObject:contact];
  
  if (checked) {
    cell.checkBox.hidden = NO;
  } else {
    cell.checkBox.hidden = YES;
  }
  
  cell.textLabel.text = [contact objectForKey:@"name"];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  NSDictionary *d = nil;
  if (searching) {
    d = [tableData objectAtIndex:[indexPath row]];
  } else {
    d = [[tableData objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
  }
  
  BOOL currentlyChecked = [self.savedContacts containsObject:d];
  
  if (currentlyChecked) {
    [self.savedContacts removeObject:d];
  } else {
    [self.savedContacts addObject:d];
  }
  [self.contactsList reloadData];
}

#pragma mark - UISearchBar methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
  searching = YES;
  [tableData removeAllObjects];
  [self.contactsList reloadData];
  searchData = [[NSMutableArray alloc] init];
  for (NSArray *a in contactData) {
    [searchData addObjectsFromArray:a];
  }
  [searchBar setShowsCancelButton:YES animated:YES];
  [UIView animateWithDuration:0.3 animations:^(void) {
    [self.contactsList setFrame:CGRectMake(0, 0, 320, 200)];
  }];
  return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
  searching = NO;
  [tableData removeAllObjects];
  [tableData addObjectsFromArray:contactData];
  [self.contactsList reloadData];
  [searchBar setShowsCancelButton:NO animated:YES];
  [searchData release], searchData = nil;
  [UIView animateWithDuration:0.3 animations:^(void) {
    [self.contactsList setFrame:CGRectMake(0, 0, 320, 416)];
  }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  if ([allTrim(searchText) isEqualToString:@""]) {
    return;
  }
  NSPredicate *p = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", searchText];
  [tableData removeAllObjects];
  [tableData addObjectsFromArray:[searchData filteredArrayUsingPredicate:p]];
  [self.contactsList reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [tableData removeAllObjects];
  [tableData addObjectsFromArray:contactData];
  [searchBar resignFirstResponder];
  [UIView animateWithDuration:0.3 animations:^(void) {
    [self.contactsList setFrame:CGRectMake(0, 0, 320, 416)];
  }];
  [searchBar setShowsCancelButton:NO animated:YES];
  [self.contactsList reloadData];
  [searchData release], searchData = nil;
}

#pragma mark - Actions

- (void)goBack {
  if ([delegate respondsToSelector:@selector(inviteFriendsControllerDidCancel:)]) {
    [delegate inviteFriendsControllerDidCancel:self];
  }
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneSelecting {
  [delegate inviteFriendsController:self didFinishWithFriends:savedContacts];  
  [self.navigationController popViewControllerAnimated:YES];
}

@end
