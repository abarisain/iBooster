//
//  MenuViewController.h
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 22/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "MarksController.h"
#import "TSMiniWebBrowser.h"
#import "DetailViewManager.h"
#import "PlanningController.h"

@class DetailViewController;

#define TAG_URL 1
#define TAG_LOGOUT 2
#define TAG_PLANING 3
#define TAG_MARKS 4
#define TAG_SUMMARY 5
#define TAG_FINANCE 6
#define TAG_INTERNSHIPS 7
#define TAG_DOCUMENTS 8

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UIWebViewDelegate> {
    NSArray *data;
    UIWebView *internalWebView;
}

- (void) userDidLogin;
- (void) logout;
- (void) openInAppBrowser:(NSString*) url;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

@end
