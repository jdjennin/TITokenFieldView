//
//  TokenFieldExampleViewController.m
//  TokenFieldExample
//
//  Created by Tom Irving on 29/01/2011.
//  Copyright 2011 Tom Irving. All rights reserved.
//

#import "TokenFieldExampleViewController.h"
#import "Names.h"
#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>

#define WORK @"_$!<Work>!$_"
#define HOME @"_$!<Home>!$_"
#define MOBILE @"_$!<Mobile>!$_"
#define MAIN @"_$!<Main>!$_"

@interface TokenFieldExampleViewController (Private)
- (void)resizeViews;
@end

@implementation TokenFieldExampleViewController

- (void)viewDidLoad {
  UIButton *theView = [UIButton buttonWithType:UIButtonTypeCustom];
  [theView addTarget:self action:@selector(cancelContactSelection) forControlEvents:UIControlEventTouchUpInside];
  [theView setBackgroundImage:[UIImage imageNamed:@"cancel-btn.png"] forState:UIControlStateNormal];
  [theView setFrame:CGRectMake(0, 0, 55, 30)];
  UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:theView];
  self.navigationItem.leftBarButtonItem = left;
  [left release];
  
  UIButton *theOtherView = [UIButton buttonWithType:UIButtonTypeCustom];
  [theOtherView addTarget:self action:@selector(saveContacts) forControlEvents:UIControlEventTouchUpInside];
  [theOtherView setBackgroundImage:[UIImage imageNamed:@"save-btn.png"] forState:UIControlStateNormal];
  [theOtherView setFrame:CGRectMake(0, 0, 55, 30)];
  UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:theOtherView];
  self.navigationItem.rightBarButtonItem = right;
  [right release];
  
	[self.view setBackgroundColor:[UIColor whiteColor]];
  
  ABAddressBookRef _ab = ABAddressBookCreate();
  CFArrayRef _peopleTemp = ABAddressBookCopyArrayOfAllPeople(_ab);
  CFMutableArrayRef _peopleMute = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(_peopleTemp), _peopleTemp);
  CFArraySortValues(_peopleMute, CFRangeMake(0, CFArrayGetCount(_peopleMute)), (CFComparatorFunction)ABPersonComparePeopleByName, (void*)ABPersonGetSortOrdering());
  
  CFRelease(_peopleTemp);
  NSMutableArray *contactData = [NSMutableArray array];
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
      [contactData addObject:d];
    }
    
    [firstName release];
    [lastName release];
    [emails release];
    CFRelease(_emails);
  }
  CFRelease(_peopleMute);
  CFRelease(_ab);
	
	tokenFieldView = [[TITokenFieldView alloc] initWithFrame:self.view.bounds];
	[tokenFieldView setDelegate:self];
	[tokenFieldView setSourceArray:contactData];
	[tokenFieldView.tokenField setAddButtonAction:@selector(showContactsPicker) target:self];
	
  UILabel *top = [[UILabel alloc] initWithFrame:CGRectMake(29, 15, 242, 19)];
  [top setText:@"- Start typing to search your Contacts"];
  [top setTextColor:[UIColor lightGrayColor]];
  [top setFont:[UIFont fontWithName:@"Helvetica" size:13]];
  [top setBackgroundColor:[UIColor clearColor]];
  [tokenFieldView.contentView addSubview:top];
  [top release];
  
  UILabel *middle = [[UILabel alloc] initWithFrame:CGRectMake(29, 32, 406, 21)];
  [middle setText:@"- \"+\" to invite via Twitter, Facebook, SocializeIt"];
  [middle setTextColor:[UIColor lightGrayColor]];
  [middle setFont:[UIFont fontWithName:@"Helvetica" size:13]];
  [middle setBackgroundColor:[UIColor clearColor]];
  [tokenFieldView.contentView addSubview:middle];
  [middle release];
  
  UILabel *bottom = [[UILabel alloc] initWithFrame:CGRectMake(29, 49, 271, 21)];
  [bottom setText:@"- Add anyone by typing an e-mail"];
  [bottom setTextColor:[UIColor lightGrayColor]];
  [bottom setFont:[UIFont fontWithName:@"Helvetica" size:13]];
  [bottom setBackgroundColor:[UIColor clearColor]];
  [tokenFieldView.contentView addSubview:bottom];
  [bottom release];
  
  UIView *greyShit = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 320, 700)];
  [greyShit setBackgroundColor:[UIColor colorWithRed:227/255.0 green:231/255.0 blue:234/255.0 alpha:1.0]];
  [tokenFieldView insertSubview:greyShit belowSubview:tokenFieldView.contentView];
  [greyShit release];  
  
  [self.view addSubview:tokenFieldView];
	[tokenFieldView release];
  
  UIView *greenShit = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 2)];
  [greenShit setBackgroundColor:[UIColor colorWithRed:70/255.0 green:125/255.0 blue:0/255.0 alpha:1.0]];
  [self.view addSubview:greenShit];
  [greenShit release];
  
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	// You can call this on either the view or the field.
	// They both do the same thing.
	[tokenFieldView becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration animations:^{[self resizeViews];}]; // Make it pretty.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self resizeViews];
}

- (void)showContactsPicker {
	InviteFriendGroupsViewController *vc = [[InviteFriendGroupsViewController alloc] initWithNibName:nil bundle:nil];
  [vc setDelegate:self];
  UINavigationController *naviControl = [[UINavigationController alloc] initWithRootViewController:vc];
  [self.navigationController presentModalViewController:naviControl animated:YES];
  [vc release];
  [naviControl release];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	// Wouldn't it be fantastic if, when in landscape mode, width was actually width and not height?
	keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
	
	[self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	keyboardHeight = 0;
	[self resizeViews];
}

- (void)resizeViews {
	
	CGRect newFrame = tokenFieldView.frame;
	newFrame.size.width = self.view.bounds.size.width;
	newFrame.size.height = self.view.bounds.size.height - keyboardHeight;
	[tokenFieldView setFrame:newFrame];
}

- (void)tokenField:(TITokenField *)tokenField didChangeToFrame:(CGRect)frame {

}

- (void)textViewDidChange:(UITextView *)textView {
	NSLog(@"TextView changed!");
	CGFloat fontHeight = (textView.font.ascender - textView.font.descender) + 1;
	CGFloat originHeight = tokenFieldView.frame.size.height - tokenFieldView.tokenField.frame.size.height;
	CGFloat newHeight = textView.contentSize.height + fontHeight;
	
	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;
	
	CGRect newFrame = tokenFieldView.contentView.frame;
	newFrame.size.height = newHeight;
	
	if (newHeight < originHeight){
		newTextFrame.size.height = originHeight;
		newFrame.size.height = originHeight;
	}
  
	[tokenFieldView.contentView setFrame:newFrame];
	[textView setFrame:newTextFrame];
	[tokenFieldView updateContentSize];
}

#pragma mark - Actions

- (void)cancelContactSelection {
  NSLog(@"Cancel!");
  [tokenFieldView removeAllTokens];
}

- (void)saveContacts {
  NSLog(@"Save those bitches!");
}

#pragma mark - InviteFriendsDelegate

- (void)inviteFriendGroupsController:(InviteFriendGroupsViewController *)controller didFinishWithFriends:(NSMutableArray *)friends {
  [tokenFieldView restoreAllTokens];
  for (NSDictionary *d in friends) {
    [tokenFieldView.tokenField addToken:d];
  }
  [tokenFieldView hideTable];
}

- (void)inviteFriendGroupsControllerDidCancel:(InviteFriendGroupsViewController *)controller {
  [tokenFieldView restoreAllTokens];
  [tokenFieldView hideTable];
}

#pragma mark - UIScrollViewDelegate

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
  NSLog(@"Should scroll?");
  return NO;
}
@end
