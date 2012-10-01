//
//  AppDelegate.m
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 22/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import "AppDelegate.h"

#import "MenuViewController.h"


@implementation AppDelegate

@synthesize internalWebView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.067 green:0.067 blue:0.067 alpha:1]];
    NSString *userAgent;
    // Override point for customization after application launch.
    MenuViewController *menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:menuViewController];
        self.window.rootViewController = self.navigationController;
        userAgent = IPHONE_USER_AGENT;
    } else {
        // The new popover look for split views was added in iOS 5.1.
        // This checks if the setting to enable it is available and
        // sets it to YES if so.
        if ([self.splitViewController respondsToSelector:@selector(setPresentsWithGesture:)])
            [self.splitViewController setPresentsWithGesture:YES];
        
        self.window.rootViewController = self.splitViewController;
        userAgent = IPAD_USER_AGENT;
    }
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:userAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
