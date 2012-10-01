//
//  PlanningController.h
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 27/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import "LoadingTableViewController.h"
#import "CGICalendar.h"
#import "PlanningEvent.h"
#import "MAWeekView.h"
#import "MADayView.h"
#import "CMPopTipView.h"

@interface PlanningController : LoadingTableViewController <NSURLConnectionDelegate,MAWeekViewDataSource,MAWeekViewDelegate,CMPopTipViewDelegate> {
    NSMutableData *receivedData;
    NSArray *events;
    CMPopTipView *popTip;
}

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedViewSelector;
@property (weak, nonatomic) IBOutlet MADayView *dayView;
@property (weak, nonatomic) IBOutlet MAWeekView *weekView;

- (IBAction)segmentValueChanged:(id)sender;

@end
