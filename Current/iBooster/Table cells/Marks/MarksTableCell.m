//
//  MarksTableCell.m
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 26/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import "MarksTableCell.h"

@implementation MarksTableCell
@synthesize name, markValue;

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

-(void) displayMark:(Mark*)mark {
    if(mark != nil) {
        name.text = mark.name;
        if(mark.mark == -1) {
            markValue.text = @"Absence";
        } else {
            if(floorf(mark.mark) == mark.mark) {
                markValue.text = [NSString stringWithFormat:@"%.0f", mark.mark];
            } else {
                markValue.text = [NSString stringWithFormat:@"%.1f", mark.mark];
            }
        }
    } else {
        name.text = @"Pas de note";
        markValue.text = @"";
    }
}

@end
