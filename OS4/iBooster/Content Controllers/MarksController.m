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

#import "MarksController.h"
#import "CGICalendar.h"

@interface MarksController ()

@end

@implementation MarksController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = [[[tableData objectAtIndex:section] marks] count];
    return (count == 0 ? 1 : count) + 2;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *HeaderCellIdentifier = @"Header";
    static NSString *FooterCellIdentifier = @"Footer";
    NSArray *nib;
    /* On prépare la condition du if suivent (qui ignore le header, d'ou le +1)
     * On simule une ligne si jamais il n'y en a pas du tout
     * pour pouvoir ecrire "Aucune note"
     */
    Subject* subject = [tableData objectAtIndex:indexPath.section];
    int footerCount = [[subject marks] count];
    footerCount = (footerCount == 0 ? 2 : (footerCount+1));
    if(indexPath.row == 0) {
        MarksHeaderTableCell *headerCell = [tableView dequeueReusableCellWithIdentifier:HeaderCellIdentifier];
        if (headerCell == nil) {
            nib = [[NSBundle mainBundle] loadNibNamed:@"MarksHeaderTableCell" owner:self options:nil];
            headerCell = [nib objectAtIndex:0];
        }
        [headerCell displaySubject:subject];
        return headerCell;
    } else if (indexPath.row == footerCount) {
        MarksFooterTableCell *footerCell = [tableView dequeueReusableCellWithIdentifier:FooterCellIdentifier];
        if (footerCell == nil) {
            nib = [[NSBundle mainBundle] loadNibNamed:@"MarksFooterTableCell" owner:self options:nil];
            footerCell = [nib objectAtIndex:0];
        }
        return footerCell;
    } else {
        MarksTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            nib = [[NSBundle mainBundle] loadNibNamed:@"MarksTableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        if([[subject marks] count] == 0) {
            [cell displayMark:nil];
        } else {
            [cell displayMark:[[subject marks] objectAtIndex:(indexPath.row - 1)]];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int footerCount = [[[tableData objectAtIndex:indexPath.section] marks] count];
    footerCount = (footerCount == 0 ? 2 : (footerCount+1));
    if(indexPath.row == 0) {
        return 42.0;
    } else if(indexPath.row == footerCount) {
        return 1.0;
    } else {
        return 28.0;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MarksScrollingHeaderView" owner:self options:nil];
    MarksScrollingHeaderView *headerView = [nib objectAtIndex:0];
    [headerView displaySubject:[tableData objectAtIndex:section]];
    return headerView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 23.0;
}

- (void) tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tv deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	return nil;
}

#pragma mark Abstract Methods implementation

- (NSString*)getTitle {
    return @"Notes";
}

- (NSString*)getBoosterPageUrl {
    return @"marks";
}

- (NSString*)getBoosterKitFunctionToExecute {
    return @"parseMarks";
}

- (void)dataParsed:(NSDictionary*) parsedData {
    NSArray *subjectsToParse = [parsedData objectForKey:@"subjects"];
    if(subjectsToParse == nil) {
        NSLog(@"Error while parsing marks JSON : subjects key not found");
        return;
    }
    NSMutableArray *parsedSubjects = [[NSMutableArray alloc] initWithCapacity:[subjectsToParse count]];
    NSDictionary *currentSubject;
    NSMutableArray *parsedMarks;
    NSArray *marksToParse;
    NSDictionary *currentMark;
    Subject *tmpSubject;
    Mark *tmpMark;
    int validatedCount = 0;
    for(int i = 0; i < [subjectsToParse count]; i++) {
        currentSubject = [subjectsToParse objectAtIndex:i];
        tmpSubject = [[Subject alloc] init];
        tmpSubject.code = [currentSubject objectForKey:@"code"];
        tmpSubject.title = [currentSubject objectForKey:@"title"];
        tmpSubject.credits = [[currentSubject objectForKey:@"credits"] integerValue];
        tmpSubject.validated = [[currentSubject objectForKey:@"validated"] boolValue];
        if(tmpSubject.validated)
            validatedCount += tmpSubject.credits;
        
        marksToParse = [currentSubject objectForKey:@"marks"];
        unsigned int marksCount = 0;
        if(marksToParse != nil) {
            marksCount = [marksToParse count];
        }
        parsedMarks = [[NSMutableArray alloc] initWithCapacity:[marksToParse count]];
        for(int j = 0; j < marksCount; j++) {
            currentMark = [marksToParse objectAtIndex:j];
            tmpMark = [[Mark alloc] init];
            tmpMark.name = [currentMark objectForKey:@"name"];
            tmpMark.mark = [[currentMark objectForKey:@"mark"] floatValue];
            [parsedMarks addObject:tmpMark];
        }
        
        tmpSubject.marks = [NSArray arrayWithArray:parsedMarks];
        parsedMarks = nil;
        marksToParse = nil;
        currentMark = nil;
        
        [parsedSubjects addObject:tmpSubject];
    }
    
    
    UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"MarksWindowHeader" owner:self options:nil] objectAtIndex:0];
    ((UIProgressView*)[headerView viewWithTag:1]).progress = ((float)validatedCount)/((float)MAX_CREDITS);
    ((UITextView*)[headerView viewWithTag:2]).text = [NSString stringWithFormat:@"%d / %d", validatedCount, MAX_CREDITS];
    [self getNavigationItem].titleView = headerView;
    
    tableData = [NSArray arrayWithArray:parsedSubjects];
    [[self tableView] reloadData];
    return;
}

@end
