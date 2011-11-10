//
//  GroupsTableViewCell.h
//  TokenFieldExample
//
//  Created by Jacob Jennings on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GroupsTableViewCell : UITableViewCell {
  IBOutlet UIButton *numFriends;
}

@property (nonatomic, retain) IBOutlet UIButton *numFriends;

@end
