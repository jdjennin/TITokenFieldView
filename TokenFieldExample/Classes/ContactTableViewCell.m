//
//  ContactTableViewCell.m
//  AddressToy
//
//  Created by Jacob Jennings on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactTableViewCell.h"


@implementation ContactTableViewCell

@synthesize contactName;
@synthesize address;
@synthesize addressType;

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
  self.contactName = nil;
  self.addressType = nil;
  self.address = nil;
  [super dealloc];
}

@end
