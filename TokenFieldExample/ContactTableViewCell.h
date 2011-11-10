//
//  ContactTableViewCell.h
//  AddressToy
//
//  Created by Jacob Jennings on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ContactTableViewCell : UITableViewCell {
  IBOutlet UILabel *contactName;
  IBOutlet UILabel *addressType;
  IBOutlet UILabel *address;
}

@property (nonatomic, retain) IBOutlet UILabel *contactName;
@property (nonatomic, retain) IBOutlet UILabel *addressType;
@property (nonatomic, retain) IBOutlet UILabel *address;

@end
