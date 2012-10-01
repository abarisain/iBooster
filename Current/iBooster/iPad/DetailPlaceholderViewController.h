//
//  DetailPlaceholderViewController.h
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 27/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewManager.h"

@interface DetailPlaceholderViewController : UIViewController <SubstitutableDetailViewController>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
/// SubstitutableDetailViewController
@property (nonatomic, retain) UIBarButtonItem *navigationPaneBarButtonItem;

@end
