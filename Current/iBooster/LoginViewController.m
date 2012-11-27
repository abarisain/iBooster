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

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *urlAddress = @"http://www.campus-booster.net/Booster/students/labs.aspx";
    
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [[self webView] loadRequest:requestObj];
    [[self webView] setDelegate:self];
    [self showLoginAlertMessage];
}

- (void)showLoginAlertMessage {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"dBooster"
                                                      message:@"N'oubliez pas de cocher \"Se souvenir de moi\" sur les deux pages de connexion !\nLe cas échéant, vous devrez vous reconnecter à chaque utilisation de l'application."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark UIWebView methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[self activityIndicator] setHidden:NO];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[self activityIndicator] setHidden:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [webView injectToolkit];
    if([webView isLoggedIn]) {
        NSHTTPCookie *cookie;
        for (cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
            NSMutableDictionary *cookiePropertiesClone = [[NSMutableDictionary alloc] initWithDictionary:cookie.properties copyItems:YES];
            [cookiePropertiesClone setObject:[[NSDate date] dateByAddingTimeInterval:2592000] forKey:NSHTTPCookieExpires];
            [cookiePropertiesClone setValue:FALSE forKey:NSHTTPCookieDiscard];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:[NSHTTPCookie cookieWithProperties:cookiePropertiesClone]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:USER_LOGIN_NOTIFICATION object:nil];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[self activityIndicator] setHidden:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
