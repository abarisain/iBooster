//
//  LoginViewController.m
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 22/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

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
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"iBooster"
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
