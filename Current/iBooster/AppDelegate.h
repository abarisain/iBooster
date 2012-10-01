//
//  AppDelegate.h
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 22/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewManager.h"

//Campus booster perds son JS si le user agent est celui d'UIWebView de base. On le force donc à la valeur de safari.
//Il s'agit du user agent iOS5. Même si on est en iOS6. On s'en fiche un peu ...
#define IPHONE_USER_AGENT @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
#define IPAD_USER_AGENT @"Mozilla/5.0 (iPad; CPU OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) IBOutlet UISplitViewController *splitViewController;

@property (strong, nonatomic) UIWebView *internalWebView;

// DetailViewManager is assigned as the Split View Controller's delegate.
// However, UISplitViewController maintains only a weak reference to its
// delegate.  Someone must hold a strong reference to DetailViewManager
// or it will be deallocated after the interface is finished unarchieving.
@property (nonatomic, retain) IBOutlet DetailViewManager *detailViewManager;

@end
