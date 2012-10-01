//
//  MarksScrollingHeaderView.m
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 27/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import "MarksScrollingHeaderView.h"

@implementation MarksScrollingHeaderView
@synthesize code, creditValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+(Class) layerClass {
    return [CAGradientLayer class];
}

-(void) displaySubject:(Subject*)subject {
    code.text = subject.code;
    creditValue.text = [NSString stringWithFormat:@"%d Crédit%@",
                        subject.credits,
                        (subject.credits > 1 ? @"s" : @"")];
    self.backgroundColor = [UIColor clearColor];
    UIColor *color = (subject.validated ?
                      [UIColor colorWithRed:0.718 green:0.867 blue:0.694 alpha:1] :
                      [UIColor colorWithRed:0.859 green:0.71 blue:0.718 alpha:1]);
    ((CAGradientLayer*)self.layer).colors = [NSArray arrayWithObjects:(id)[color CGColor], (id)[[UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:0.1] CGColor], nil];
}

@end
