//
//  PlanningEvent.h
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 28/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGICalendar.h"
#import "MAEvent.h"

@interface PlanningEvent : NSObject {
    NSDate *start;
    NSDate *end;
    NSString *code;
    NSString *kind;
    NSString *summary;
}

@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *end;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *kind;
@property (nonatomic, strong) NSString *summary;

+(PlanningEvent*) eventFromICalendarComponent:(CGICalendarComponent*)calendarComponent;
-(MAEvent*) getMAEvent;
-(NSDate*)normalizedDate:(NSDate*)date;
-(bool) doesEventStartAtDate:(NSDate*) date;

@end
