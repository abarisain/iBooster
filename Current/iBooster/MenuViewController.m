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
        self.title = @"dBooster";
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
    [self loadCampusBooster];
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
                    case TAG_SUMMARY:
                        vc = [[SummaryController alloc] init];
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
    if(loginRedirectionTimer != nil) {
        [loginRedirectionTimer invalidate];
        loginRedirectionTimer = nil;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if(loginRedirectionTimer != nil) {
        [loginRedirectionTimer invalidate];
        loginRedirectionTimer = nil;
    }
    loginRedirectionTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(checkLoggedIn)
                                   userInfo:nil
                                    repeats:NO];

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if(loginRedirectionTimer != nil) {
        [loginRedirectionTimer invalidate];
        loginRedirectionTimer = nil;
    }
    // To avoid getting an error alert when you click on a link
    // before a request has finished loading.
    if ([error code] == NSURLErrorCancelled) {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erreur lors du chargement des données", nil)
                                                    message:@"Merci de vérifier votre connexion réseau."
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"Réessayer", nil), nil];
	[alert show];
}

#pragma mark UIAlertView delegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self loadCampusBooster];
    } 
}

#pragma mark Helper Methods

- (void) loadCampusBooster {
    [internalWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:BOOSTER_DEFAULT_URL]]];
}

- (void) checkLoggedIn {
    [internalWebView injectToolkit];
    if([internalWebView isLoggedIn]) {
        [self userDidLogin];
    } else {
        [self showLoginPopup];
    }
}

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
