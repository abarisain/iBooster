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

#import "LoadingTableViewController.h"

@interface LoadingTableViewController () {
    NSMutableArray *_objects;
}
@end

@implementation LoadingTableViewController

#pragma mark UIView Methods

- (id)init
{
    self = [self initWithNibName:@"LoadingTableViewController" bundle:nil];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [self getTitle];
        [self tableView].delegate = self;
        [self tableView].dataSource = self;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}

- (void) viewDidLoad{
	[super viewDidLoad];
    [self applyUITableViewTheme];
    [[self getNavigationItem] setTitle:self.title];
    internalWebView = [[UIWebView alloc] initWithFrame:CGRectNull];
    [internalWebView setDelegate:self];
    [internalWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.campus-booster.net/Booster/students/%@.aspx%@", [self getBoosterPageUrl], [self getBoosterPageUrlParameter]]]]];
    if (self.navigationPaneBarButtonItem) {
        [self.iPadNavigationBar.topItem setLeftBarButtonItem:self.navigationPaneBarButtonItem
                                                animated:NO];
    }
}

#pragma mark -
#pragma mark SubstitutableDetailViewController

// -------------------------------------------------------------------------------
//	setNavigationPaneBarButtonItem:
//  Custom implementation for the navigationPaneBarButtonItem setter.
//  In addition to updating the _navigationPaneBarButtonItem ivar, it
//  reconfigures the navigationBar to either show or hide the
//  navigationPaneBarButtonItem.
// -------------------------------------------------------------------------------
- (void)setNavigationPaneBarButtonItem:(UIBarButtonItem *)navigationPaneBarButtonItem
{
    if (navigationPaneBarButtonItem != _navigationPaneBarButtonItem) {
        // Add the popover button to the left navigation item.
        [self.iPadNavigationBar.topItem setLeftBarButtonItem:navigationPaneBarButtonItem
                                                animated:NO];
        
        _navigationPaneBarButtonItem = navigationPaneBarButtonItem;
    }
}

#pragma mark Table View Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [tableData count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[tableData objectAtIndex:section] objectForKey:@"rows"] count];
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void) tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tv deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return [[tableData objectAtIndex:section] objectForKey:@"title"];
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	return [[tableData objectAtIndex:section] objectForKey:@"footer"];
}

#pragma mark UIWebView methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[self loadingView] setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self loadingView] setHidden:YES];
    [webView injectToolkit];
    NSError *error = nil;
    NSString *jsResult = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"JSON.stringify(iBoosterToolkit.%@());", [self getBoosterKitFunctionToExecute]]];
    NSDictionary *dictJSON = [NSJSONSerialization JSONObjectWithData:[jsResult dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if (error) {
        NSLog(@"JSON parse error: %@\nJSON string : %@", [error localizedDescription], jsResult);
        return;
    } else if(DEBUG_ENABLED) {
        NSLog(@"JSON string : %@", jsResult);
    }
    
    [self dataParsed:dictJSON];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self loadingView] setHidden:YES];
    
    // To avoid getting an error alert when you click on a link
    // before a request has finished loading.
    if ([error code] == NSURLErrorCancelled) {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erreur lors du chargement des données", nil)
                                                    message:error.localizedDescription
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alert show];
}

#pragma mark Helper methods

- (UINavigationBar*) getNavigationBar {
    return (self.iPadNavigationBar != nil ? self.iPadNavigationBar : self.navigationController.navigationBar);
}

- (UINavigationItem*) getNavigationItem {
    return (self.iPadNavigationItem != nil ? self.iPadNavigationItem : self.navigationItem);
}

#pragma mark UIAlertView delegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark Abstract Methods to override

- (void)applyUITableViewTheme {
    self.tableView.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (NSString*)getTitle {
    return @"dBooster";
}

- (NSString*)getBoosterPageUrl {
    //Example : return @"marks";
    //La page ouverte sera http://www.campus-booster.net/Booster/students/ + getBoosterPageUrl + getBoosterPageUrlParameter + .aspx
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString*)getBoosterPageUrlParameter {
    //Example : return @"?kind=Summary";
    //La page ouverte sera http://www.campus-booster.net/Booster/students/ + getBoosterPageUrl + .aspx
    return @"";
}

- (NSString*)getBoosterKitFunctionToExecute {
    //Example : return @"parseMarks";
    //La fonction appellée sera iBoosterToolkit.parseMarks();
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)dataParsed:(NSDictionary*) data {
    //Renvoyé quand les données ont été parsées et qu'il faut rafraichir la table
    [self doesNotRecognizeSelector:_cmd];
    return;
}

@end
