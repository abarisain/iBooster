//
//  UIWebView+injectJS.h
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 23/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (injectJS)

- (void)injectJavascript:(NSString *)resource;

- (void)injectJQuery;

- (void)injectToolkit;

@end
