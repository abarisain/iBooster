//
//  MarksScrollingHeaderView.h
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 27/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Marks.h"

@interface MarksScrollingHeaderView : UIView

@property (weak, nonatomic) IBOutlet UILabel *code;
@property (weak, nonatomic) IBOutlet UILabel *creditValue;

-(void) displaySubject:(Subject*)subject;

@end
