//
//  MarksHeaderTableCell.h
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 26/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Marks.h"

@interface MarksHeaderTableCell : UITableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UILabel *subjectTitle;

-(void) displaySubject:(Subject*)subject;

@end
