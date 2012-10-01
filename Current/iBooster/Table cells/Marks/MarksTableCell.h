//
//  MarksTableCell.h
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 26/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Marks.h"

@interface MarksTableCell : UITableViewCell {
    
}

@property (strong, nonatomic) IBOutlet UITableViewCell *cell;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *markValue;

-(void) displayMark:(Mark*)mark;

@end
