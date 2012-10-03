/*
 * Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "PlanningEvent.h"

@implementation PlanningEvent

@synthesize start;
@synthesize end;
@synthesize code;
@synthesize kind;
@synthesize summary;

+(PlanningEvent*) eventFromICalendarComponent:(CGICalendarComponent*)calendarComponent {
    PlanningEvent *event = [[PlanningEvent alloc] init];
    event.start = [calendarComponent dateTimeStart];
    event.end = [calendarComponent dateTimeEnd];
    event.kind = [calendarComponent propertyValueForName:@"CATEGORIES"];
    event.code = [calendarComponent propertyValueForName:@"LOCATION"];
    event.summary = [calendarComponent propertyValueForName:@"SUMMARY"];
    return event;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Start: %@\nEnd: %@\nKind: %@\nCode: %@\nSummary: %@",
                [start description],
                [end description],
                kind,
                code,
                summary];
}

-(MAEvent*) getMAEvent {
    static NSString *kindQcm = @"QCM";
    static NSString *kindTP = @"GRADED_EXERCISE";
    //static NSString *kindClass = @"CLASS"; //To be confirmed
    
    MAEvent *event = [[MAEvent alloc] init];
    event.textColor = [UIColor whiteColor];
    event.allDay = NO;
    event.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self, @"planningEvent", nil];
    event.title = [NSString stringWithFormat:@"%@\n%@", code, summary];
    event.start = start;
    event.end = end;
    
    if([kind isEqualToString:kindQcm]) {
        //event.backgroundColor = [UIColor blueColor];
        event.backgroundColor = [UIColor colorWithRed:0.314 green:0.561 blue:0.82 alpha:1];
    } else if([kind isEqualToString:kindTP]) {
        //event.backgroundColor = [UIColor redColor];
        event.backgroundColor = [UIColor colorWithRed:0.765 green:0.29 blue:0.353 alpha:1];
    } else {
        //if([kind isEqualToString:kindClass]) // On est pas sur que un cours s'appelle comme ca
        //event.backgroundColor = [UIColor purpleColor];
        event.backgroundColor = [UIColor colorWithRed:0.608 green:0.325 blue:0.627 alpha:1];
    }
    
    return event;
}

-(NSDate*)normalizedDate:(NSDate*)date {
    NSDateComponents* components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                               fromDate: date];
    return [[NSCalendar currentCalendar] dateFromComponents:components]; // NB calendar_ must be initialized
}

-(bool) doesEventStartAtDate:(NSDate*) date {
    return [[self normalizedDate:start] isEqualToDate:[self normalizedDate:date]];
}

@end
