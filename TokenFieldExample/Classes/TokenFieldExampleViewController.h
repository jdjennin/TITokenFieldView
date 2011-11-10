//
//  TokenFieldExampleViewController.h
//  TokenFieldExample
//
//  Created by Tom Irving on 29/01/2011.
//  Copyright 2011 Tom Irving. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TITokenFieldView.h"
#import "InviteFriendGroupsViewController.h"

@interface TokenFieldExampleViewController : UIViewController <TITokenFieldViewDelegate, UITextViewDelegate, InviteFriendsDelegate> {

	TITokenFieldView * tokenFieldView;
	UITextView * messageView;
	
	CGFloat keyboardHeight;
}

- (void)cancelContactSelection;
- (void)saveContacts;

@end

