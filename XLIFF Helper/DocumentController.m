//
//  DocumentController.m
//  XLIFF Manager
//
//  Created by Joe Sexton on 2016-03-19.
//  Copyright © 2016 Joe Sexton.
//

#import "DocumentController.h"

@implementation DocumentController

/**
 * Disables creating a new document
 *
 * @param menu item
 */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    
    if (menuItem.action == @selector(newDocument:)) {
        return NO;
    }
    
    return [super validateMenuItem:menuItem];
}

@end
