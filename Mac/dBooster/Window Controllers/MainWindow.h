//
//  MainWindow.h
//  dBooster
//
//  Created by Arnaud Barisain Monrose on 27/11/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindow : NSWindow {
    
    __weak NSToolbarItem *_userNameToolbarItem;
}
- (IBAction)userNamePressed:(id)sender;

@property (weak) IBOutlet NSToolbarItem *userNameToolbarItem;
@end
