//
//  GroupsTableViewCell.m
//  TokenFieldExample
//
//  Created by Jacob Jennings on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GroupsTableViewCell.h"


@implementation GroupsTableViewCell

@synthesize numFriends;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

- (void)dealloc
{
  self.numFriends = nil;
  [super dealloc];
}

@end
