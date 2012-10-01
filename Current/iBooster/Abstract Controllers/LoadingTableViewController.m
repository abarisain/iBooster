//
//  LoadingTableViewController.m
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 22/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

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
    [internalWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.campus-booster.net/Booster/students/%@.aspx", [self getBoosterPageUrl]]]]];
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

#pragma mark Abstract Methods to override

- (void)applyUITableViewTheme {
    self.tableView.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (NSString*)getTitle {
    return @"iBooster";
}

- (NSString*)getBoosterPageUrl {
    //Example : return @"marks";
    //La page ouverte sera http://www.campus-booster.net/Booster/students/ + getBoosterPageUrl + .aspx
    [self doesNotRecognizeSelector:_cmd];
    return nil;
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
