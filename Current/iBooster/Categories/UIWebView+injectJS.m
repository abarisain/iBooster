//
//  UIWebView+injectJS.m
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 23/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import "UIWebView+injectJS.h"

@implementation UIWebView (injectJS)

- (void)injectJavascript:(NSString *)resource {
    NSString *jsPath = [[NSBundle mainBundle] pathForResource:resource ofType:@"js"];
    NSString *js = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:NULL];
    
    [self stringByEvaluatingJavaScriptFromString:js];
}

- (void)injectJQuery {
    [self injectJavascript:@"jquery"];
}

- (void)injectToolkit {
    [self injectJavascript:@"jquery"];
    [self injectJavascript:@"toolkit"];
}

@end
