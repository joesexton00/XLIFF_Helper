//
//  ViewController.h
//  XLIFF Manager
//
//  Created by Joe Sexton on 2016-03-19.
//  Copyright © 2016 Joe Sexton.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (weak) IBOutlet NSButton *removeTranslationButtonOutlet;
@property (weak) IBOutlet NSSearchFieldCell *searchFieldOutlet;
@property (weak) IBOutlet NSButton *nextButtonOutlet;
@property (weak) IBOutlet NSButton *previousButtonOutlet;
@property (weak) IBOutlet NSTextField *searchMatchesLabelOutlet;

- (IBAction)addTranslationButtonAction:(NSButton *)sender;
- (IBAction)removeTranslationButtonAction:(NSButton *)sender;
- (IBAction)tableViewClickedAction:(NSTableView *)sender;
- (IBAction)searchFieldAction:(NSSearchField *)sender;
- (IBAction)nextButtonAction:(NSButton *)sender;
- (IBAction)previousButtonAction:(NSButton *)sender;

@end

