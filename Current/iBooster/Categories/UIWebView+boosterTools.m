//
//  UIWebView+boosterTools.m
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 23/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import "UIWebView+boosterTools.h"

@implementation UIWebView (boosterTools)

- (BOOL) isLoggedIn {
    return [[self stringByEvaluatingJavaScriptFromString:@"iBoosterToolkit.checkIfLoggedIn()"] boolValue];
}

- (NSString*) getBoosterName {
    return [self stringByEvaluatingJavaScriptFromString:@"iBoosterToolkit.getUsername()"];
}

@end
