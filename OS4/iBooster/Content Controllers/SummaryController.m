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

#import "SummaryController.h"

@interface SummaryController ()

@end

@implementation SummaryController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    SummaryTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SummaryTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell displaySummary:[tableData objectAtIndex:indexPath.row]];
    return cell;
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

- (void)applyUITableViewTheme {
    [super applyUITableViewTheme];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (NSString*)getTitle {
    return @"Résumé";
}

- (NSString*)getBoosterPageUrl {
    return @"marks";
}

- (NSString*)getBoosterPageUrlParameter {
    return @"?kind=Summary";
}

- (NSString*)getBoosterKitFunctionToExecute {
    return @"parseSummary";
}

- (void)dataParsed:(NSDictionary*) parsedData {
    NSArray *summariesToParse = [parsedData objectForKey:@"summaries"];
    if(summariesToParse == nil) {
        NSLog(@"Error while parsing summary JSON : summaries key not found");
        return;
    }
    NSMutableArray *parsedSummaries = [[NSMutableArray alloc] initWithCapacity:[summariesToParse count]];
    NSDictionary *currentSummary;
    Summary *tmpSummary;
    for(int i = 0; i < [summariesToParse count]; i++) {
        currentSummary = [summariesToParse objectAtIndex:i];
        tmpSummary = [[Summary alloc] init];
        tmpSummary.title = [currentSummary objectForKey:@"title"];
        tmpSummary.percentage = [currentSummary objectForKey:@"percentage"];
        tmpSummary.mark = [[currentSummary objectForKey:@"mark"] integerValue];
        tmpSummary.markTheory = [[currentSummary objectForKey:@"markTheory"] integerValue];
        [parsedSummaries addObject:tmpSummary];
    }
    
    tableData = [NSArray arrayWithArray:parsedSummaries];
    [[self tableView] reloadData];
    return;
}

@end
