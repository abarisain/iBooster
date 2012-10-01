//
//  MenuViewController.m
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 22/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MenuViewController

#pragma mark UIView Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"iBooster";
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin) name:USER_LOGIN_NOTIFICATION object:nil];
    //On charge CB pour vérifier si on est connécté. Si oui, on déclenche l'evenement "userDidLogin" pour simplifier le chemin du code
    internalWebView = [[UIWebView alloc] initWithFrame:CGRectNull];

    [internalWebView setDelegate:self];
    [internalWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.campus-booster.net/Booster/students/marks.aspx"]]];
    
}

#pragma mark Table View Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [data count];
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[data objectAtIndex:section] objectForKey:@"rows"] count];
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	cell.textLabel.text = [[[data objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];
	
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad || (indexPath.section == 3 && indexPath.row == 0)) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        //cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
    return cell;
}

- (void) tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [tv deselectRowAtIndexPath:indexPath animated:YES];
    }
	
	int section = indexPath.section, row = indexPath.row;
	
    
    NSArray *tags = [[data objectAtIndex:section] objectForKey:@"tags"];
    NSArray *urls = nil;
    UIViewController <SubstitutableDetailViewController> *vc = nil;
    if(tags != nil) {
        int tag = [[tags objectAtIndex:row] integerValue];
        switch (tag) {
            case TAG_URL:
                urls = [[data objectAtIndex:section] objectForKey:@"urls"];
                if(urls == nil) {
                     NSLog(@"No URLs associated with clicked section : %i (row %i)", section, row);
                } else {
                    [self openInAppBrowser:[urls objectAtIndex:row]];
                }
                break;
            case TAG_LOGOUT:
                [self logout];
                break;
            default:
                switch(tag) {
                    case TAG_MARKS:
                        vc = [[MarksController alloc] init];
                        break;
                    case TAG_PLANING:
                        vc = [[PlanningController alloc] init];
                        break;
                    default:
                        NSLog(@"Unrecognized tag : %i, section %i, row %i", tag, section, row);
                        break;
                }
                if(vc != nil) {
                    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                        DetailViewManager *detailViewManager = (DetailViewManager*)self.splitViewController.delegate;
                        detailViewManager.detailViewController = vc;
                    } else {
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }
                break;
        }
    } else {
        NSLog(@"No tags associated with clicked section : %i (row %i)", section, row);
    }
	
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return [[data objectAtIndex:section] objectForKey:@"title"];
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	return [[data objectAtIndex:section] objectForKey:@"footer"];
}

#pragma mark UIWebView methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [webView injectToolkit];
    if([webView isLoggedIn]) {
        [self userDidLogin];
    } else {
        [self showLoginPopup];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark Helper Methods

- (void) refreshCellData {
	NSArray *rows;
    NSArray *urls;
    NSArray *tags;
	NSDictionary *d;
	
	data = nil;
	
	NSMutableArray *tmp = [NSMutableArray array];
	
    rows = [NSArray arrayWithObjects:@"Planning",@"Notes",@"Résumé",nil];
    tags = [NSArray arrayWithObjects:[NSNumber numberWithInt:TAG_PLANING],[NSNumber numberWithInt:TAG_MARKS],[NSNumber numberWithInt:TAG_SUMMARY],nil];
	d = [NSDictionary dictionaryWithObjectsAndKeys:rows,@"rows",[internalWebView getBoosterName],@"title",tags,@"tags",nil];
	[tmp addObject:d];
	
	/*rows = [NSArray arrayWithObjects:@"Finance / Paiement",@"Stages",nil];
    tags = [NSArray arrayWithObjects:[NSNumber numberWithInt:TAG_FINANCE],[NSNumber numberWithInt:TAG_INTERNSHIPS],nil];
	d = [NSDictionary dictionaryWithObjectsAndKeys:rows,@"rows",@"",@"title",tags,@"tags",nil];
	[tmp addObject:d];*/
    
    NSNumber *tagUrl = [NSNumber numberWithInt:TAG_URL];
    rows = [NSArray arrayWithObjects:@"Campus-booster",@"Courses",@"Libraries",@"SPR",@"Support",@"Outlook",nil];
    urls = [NSArray arrayWithObjects:@"http://www.campus-booster.net",
            @"http://courses.supinfo.com/ios",
            @"http://libraries.supinfo.com",
            @"http://spr.supinfo.com",
            @"http://support.supinfo.com",
            @"http://www.outlook.com",
            nil];
    tags = [NSArray arrayWithObjects:tagUrl,tagUrl,tagUrl,tagUrl,tagUrl,tagUrl,nil];
	d = [NSDictionary dictionaryWithObjectsAndKeys:rows,@"rows",@"Portails",@"title",urls,@"urls",tags,@"tags",nil];
	[tmp addObject:d];
    
	rows = [NSArray arrayWithObjects:@"Se déconnecter",nil];
    tags = [NSArray arrayWithObjects:[NSNumber numberWithInt:TAG_LOGOUT],nil];
	d = [NSDictionary dictionaryWithObjectsAndKeys:rows,@"rows",@"Compte",@"title",@"",@"footer",tags,@"tags",nil];
	[tmp addObject:d];
	
	data = [[NSArray alloc] initWithArray:tmp];
}

- (void) openInAppBrowser:(NSString*) url {
    TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:url]];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        webBrowser.mode = TSMiniWebBrowserModeModal;
        [self presentViewController:webBrowser animated:YES completion:NULL];
    } else {
        webBrowser.mode = TSMiniWebBrowserModeNavigation;
        [self.navigationController pushViewController:webBrowser animated:YES];
    }
}

- (void) showLoginPopup {
    LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self presentViewController:loginController animated:YES completion:NULL];
}

- (void) logout {
    data = nil;
    [self.tableView reloadData];
    [[self loadingView] setHidden:NO];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    [self showLoginPopup];
}

#pragma mark Callbacks

- (void) userDidLogin {
    [self refreshCellData];
    [[self loadingView] setHidden:YES];
    [self.tableView reloadData];
}

@end
