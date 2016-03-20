//
//  AppDelegate.m
//  XLIFF Manager
//
//  Created by Joe Sexton on 2016-03-19.
//  Copyright © 2016 Joe Sexton.
//

#import "AppDelegate.h"

#import "DocumentController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (instancetype)init {
    if ((self = [super init])) {
        (void)[[DocumentController alloc] init];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    
    [[NSDocumentController sharedDocumentController] openDocument:sender];
    
    return NO;
}

@end
