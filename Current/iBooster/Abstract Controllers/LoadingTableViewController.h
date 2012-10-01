//
//  MenuViewController.h
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 22/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewManager.h"

@interface LoadingTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UIWebViewDelegate, SubstitutableDetailViewController> {
    NSArray *tableData;
    UIWebView *internalWebView;
}

- (UINavigationBar*) getNavigationBar;
- (UINavigationItem*) getNavigationItem;
- (void)applyUITableViewTheme;
- (NSString*)getTitle;
- (NSString*)getBoosterPageUrl;
- (NSString*)getBoosterKitFunctionToExecute;
- (void)dataParsed:(NSDictionary*) data;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

@property (weak, nonatomic) IBOutlet UINavigationBar *iPadNavigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *iPadNavigationItem;

/// SubstitutableDetailViewController
@property (nonatomic, retain) UIBarButtonItem *navigationPaneBarButtonItem;

@end
