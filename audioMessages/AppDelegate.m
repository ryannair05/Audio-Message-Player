//
//  AppDelegate.m
//  audioMessages
//
//  Created by Ryan Nair on 12/8/24.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 800, 600)
                                            styleMask:NSWindowStyleMaskTitled |
                                                     NSWindowStyleMaskClosable |
                                                     NSWindowStyleMaskMiniaturizable |
                                                     NSWindowStyleMaskResizable
                                              backing:NSBackingStoreBuffered
                                                defer:NO];
    
    self.window.contentViewController = [[AudioViewController alloc] init];;
    self.window.title = @"Audio Message Player";
    [self.window center];
    [self.window makeKeyAndOrderFront:nil];
    
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenuItem *appMenuItem = [mainMenu itemAtIndex:0];
    NSMenu *appMenu = [appMenuItem submenu];
    
    [appMenu addItemWithTitle:@"About Audio Message Player" action:@selector(showAboutPanel:) keyEquivalent:@""];
    [appMenu addItemWithTitle:@"Quit Audio Message Player" action:@selector(terminate:) keyEquivalent:@"q"];
}

- (void)showAboutPanel:(id)sender {
    NSDictionary *options = @{
        @"Copyright": @"© 2024 Ryan Nair",
        NSAboutPanelOptionVersion: @"",
        NSAboutPanelOptionApplicationName: @"Audio Message Player"
    };
    [[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:options];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

@end
