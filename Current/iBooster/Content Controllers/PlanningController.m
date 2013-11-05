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

#import "PlanningController.h"

@interface PlanningController ()

@end

@implementation PlanningController

@synthesize segmentedViewSelector, dayView, weekView;

- (id)init
{
    self = [self initWithNibName:@"PlanningViewController" bundle:nil];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        events = [[NSArray alloc] init];
        popTip = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self getNavigationItem].titleView = segmentedViewSelector;
    [self getNavigationBar].shadowImage = [[UIImage alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateViewsForOrientation:(UIInterfaceOrientation)orientation
{
    CGRect weekFrame = weekView.frame;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(orientation))
    {
        [weekView setFrame:CGRectMake(weekFrame.origin.x, weekFrame.origin.y, segmentedViewSelector.frame.size.width, 30)];
        [segmentedViewSelector setFrame:CGRectMake(segmentedViewSelector.frame.origin.x, segmentedViewSelector.frame.origin.y, segmentedViewSelector.frame.size.width, 30)];
    }
    else
    {
        [segmentedViewSelector setFrame:CGRectMake(segmentedViewSelector.frame.origin.x, segmentedViewSelector.frame.origin.y, segmentedViewSelector.frame.size.width, 25)];
        
    }
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateViewsForOrientation:toInterfaceOrientation];
}

#pragma mark Abstract Methods implementation

- (NSString*)getTitle {
    return @"Planning";
}

- (NSString*)getBoosterPageUrl {
    return @"Planning";
}

- (NSString*)getBoosterKitFunctionToExecute {
    return @"getPlanningFormBody";
}

- (void)dataParsed:(NSDictionary*) parsedData {
    NSString *postData = [parsedData objectForKey:@"body"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.campus-booster.net/Booster/students/Planning.aspx"]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[self loadingView] setHidden:NO];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if (connection) {
        receivedData = [NSMutableData data];
    }
    return;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    receivedData = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self loadingView] setHidden:YES];
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erreur lors du chargement des données", nil)
                                                    message:error.localizedDescription
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self loadingView] setHidden:YES];
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/planning.ics",
                          documentsDirectory];
    //save content to the documents directory
    [receivedData writeToFile:fileName
              atomically:NO];
    
    CGICalendar *ical = [[CGICalendar alloc] init];
    if ([ical parseWithPath:fileName error:nil]) {
        if([[ical objects] count] == 0) {
            //TODO : Error
        }
        NSMutableArray *tmpEvents = [[NSMutableArray alloc] init];
        for(CGICalendarComponent *icalComp in [[ical objectAtIndex:0] components]) {
            [tmpEvents addObject:[PlanningEvent eventFromICalendarComponent:icalComp]];
        }
        events = [NSArray arrayWithArray:tmpEvents];
        [dayView reloadData];
        [weekView reloadData];
    } else {
        //TODO : Error
    }
}

- (void)viewDidUnload {
    [self setSegmentedViewSelector:nil];
    [self setDayView:nil];
    [self setWeekView:nil];
    [super viewDidUnload];
}

- (IBAction)segmentValueChanged:(id)sender {
    dayView.hidden = (segmentedViewSelector.selectedSegmentIndex == 0);
    weekView.hidden = (segmentedViewSelector.selectedSegmentIndex != 0);
}

#pragma mark MAWeek/DayView dataSource

- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)startDate {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(PlanningEvent *event in events) {
        if([event doesEventStartAtDate:startDate]) {
            [result addObject:[event getMAEvent]];
        }
    }
    return [NSArray arrayWithArray:result];
}

- (NSArray *)weekView:(MAWeekView *)weekView eventsForDate:(NSDate *)startDate {
    return [self dayView:dayView eventsForDate:startDate];
}

#pragma mark MAWeek/DayView delegate

- (BOOL)weekView:(MAWeekView *)weekView eventDraggingEnabled:(MAEvent *)event {
    return NO;
}

- (BOOL)dayView:(MADayView *)weekView eventDraggingEnabled:(MAEvent *)event {
    return NO;
}

- (void)weekView:(MAWeekView *)weekView eventTapped:(MAEvent *)event view:(UIView*)tagetView {
    if(popTip != nil) {
        [popTip dismissAnimated:YES];
        popTip = nil;
    }
    popTip = [[CMPopTipView alloc] initWithMessage:event.title];
    popTip.delegate = self;
    popTip.textColor = [UIColor whiteColor];
    popTip.backgroundColor = [event backgroundColor];
    popTip.dismissTapAnywhere = YES;
    [popTip presentPointingAtView:tagetView inView:self.view animated:YES];
}

- (void)dayView:(MADayView *)dayView eventTapped:(MAEvent *)event view:(UIView*)tagetView {
    [self weekView:self.weekView eventTapped:event view:tagetView];
}

#pragma mark CMPopTipViewDelegate methods
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    popTip = nil;
}

@end
