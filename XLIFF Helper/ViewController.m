//
//  ViewController.m
//  XLIFF Manager
//
//  Created by Joe Sexton on 2016-03-19.
//  Copyright © 2016 Joe Sexton.
//

#import "ViewController.h"

@interface ViewController () <NSTableViewDataSource, NSTableViewDelegate, DocumentEventDelegate>

@property (nonatomic, weak) Document *document;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic) NSUInteger currentSearchResultIndex;

@end

@implementation ViewController

#define BasicTableViewDragAndDropDataType @"TranslationUnit"
#define RowHeightPerLine 17

#pragma mark - Controller Lifecycle

- (void)viewWillAppear {
    
    [super viewWillAppear];

    self.document = self.view.window.windowController.document;
    self.document.documentEventDelegate = self;
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
    [self.tableView setAllowsMultipleSelection: YES];
    [self.tableView setAllowsColumnSelection:NO];
    [self.tableView setIntercellSpacing:NSMakeSize(0, 0)];
    self.removeTranslationButtonOutlet.enabled = NO;
    
    self.currentSearchResultIndex     = 0;
    self.nextButtonOutlet.enabled     = NO;
    self.previousButtonOutlet.enabled = NO;
    
    self.searchMatchesLabelOutlet.stringValue  = @"";
    [self updateDocumentStatusLabel:@"No Changes Yet" withColor:[NSColor blackColor]];
}

- (void)awakeFromNib {
    
    [self.tableView registerForDraggedTypes:[NSArray arrayWithObjects:BasicTableViewDragAndDropDataType, nil]];
}

#pragma mark - Actions

/**
 * Add translation button action.
 * Adds a new translation row.
 *
 * @param sender
 */
- (IBAction)addTranslationButtonAction:(NSButton *)sender {
    
    NSUInteger index = [[self.tableView selectedRowIndexes] firstIndex] + 1;
    if (index > [self.document.translationUnits count]) {
        index = 0;
    }

    [self.document addTranslationUnitAtIndex: index];
    [self.document loadTranslationUnits];
    [self.tableView reloadData];

    [self selectTableViewRowAtIndex:index];
    [self.tableView scrollRowToVisible:index];
    [self updateDocumentStatusLabel:@"Unsaved Changes" withColor:[NSColor colorWithRed:0.91 green:0.329 blue:0.329 alpha:1]];
}

/**
 * Remove translation button action.
 * Removes translation row(s).
 *
 * @param sender
 */
- (IBAction)removeTranslationButtonAction:(NSButton *)sender {
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Are you sure?"];
    [alert setInformativeText:@"Deleted translations cannot be restored."];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    if ([alert runModal] != NSAlertFirstButtonReturn) {
        return;
    }
    
    // Iterate the list backwards as the indexes of the elements will change after they are removed
    // working backwards keeps the lower indexes at the same positions
    NSUInteger index = [[self.tableView selectedRowIndexes] lastIndex];
    
    while(index != NSNotFound) {
        [self.document removeTranslationUnitAtIndex:index];
        index = [[self.tableView selectedRowIndexes] indexLessThanIndex: index];
    }

    [self.document loadTranslationUnits];
    [self.tableView reloadData];
    [self selectTableViewRowAtIndex:[[self.tableView selectedRowIndexes] firstIndex]];
    [self updateDocumentStatusLabel:@"Unsaved Changes" withColor:[NSColor colorWithRed:0.91 green:0.329 blue:0.329 alpha:1]];
}

/**
 * Table View interaction action.
 * Sets the enabled/disabled state of buttons based on the state of the table view.
 *
 * @param sender
 */
- (IBAction)tableViewClickedAction:(NSTableView *)sender {
    
    if ([[self.tableView selectedRowIndexes] firstIndex] != NSNotFound) {
        self.removeTranslationButtonOutlet.enabled = YES;
    } else {
        self.removeTranslationButtonOutlet.enabled = NO;
    }
}

/**
 * Search field action.
 * Searches for fields matching the query.
 *
 * @param sender
 */
- (IBAction)searchFieldAction:(NSSearchField *)sender {

    self.document.translationUnitFilter = [sender.stringValue lowercaseString];
    [self.document loadTranslationUnits];
    [self.tableView reloadData];
    
    if ([self.document.filterMatches firstObject]) {
        [self.tableView scrollRowToVisible:[[self.document.filterMatches firstObject] integerValue]];
        self.currentSearchResultIndex = [[self.document.filterMatches firstObject] integerValue];
    } else {
        [self.tableView scrollRowToVisible:0];
        self.currentSearchResultIndex = 0;
    }
    
    if ([self.document.filterMatches count] > 1) {
        
        self.nextButtonOutlet.enabled     = YES;
        self.previousButtonOutlet.enabled = YES;
    } else {
        
        self.nextButtonOutlet.enabled     = NO;
        self.previousButtonOutlet.enabled = NO;
    }
    
    if ([sender.stringValue length]) {
        self.searchMatchesLabelOutlet.stringValue = [NSString stringWithFormat:@"%lu Matches", [self.document.filterMatches count]];
    } else {
        self.searchMatchesLabelOutlet.stringValue = @"";
    }
}

/**
 * Next button action.
 * Advances to the next search result.
 *
 * @param sender
 */
- (IBAction)nextButtonAction:(NSButton *)sender {
    
    NSInteger index = -1;
    for(NSNumber *number in self.document.filterMatches) {
        
        if ([number integerValue] > self.currentSearchResultIndex) {
            index = [number integerValue];
            
            break;
        }
    }
    
    if (index == -1) {
        index = [[self.document.filterMatches firstObject] integerValue];
    }
    
    [self.tableView scrollRowToVisible:index];
    self.currentSearchResultIndex = index;
    
    [self.tableView reloadData];
}

/**
 * Add translation button action.
 * Moves to the previous search result.
 *
 * @param sender
 */
- (IBAction)previousButtonAction:(NSButton *)sender {
    
    NSInteger index = -1;
    
    for(NSNumber *number in self.document.filterMatches) {
        
        if ([number integerValue] < self.currentSearchResultIndex) {
            index = [number integerValue];
        }
    }
    
    if (index == -1) {
        index = [[self.document.filterMatches lastObject] integerValue];
    }
    
    [self.tableView scrollRowToVisible:index];
    self.currentSearchResultIndex = index;
    
    [self.tableView reloadData];
}


#pragma mark - NSTableViewDataSource

/**
 * NSTableViewDataSource numberOfRowsInTableView method
 *
 * @param table view
 */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    return self.document.translationUnits.count;
}

/**
 * NSTableViewDataSource tableView:setObjectValue:forTableColumn: method
 *
 * @param table view
 * @param object
 * @param table column
 */
- (void)tableView:(NSTableView *)tableView setObjectValue:(nullable id)object forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    
    TranslationUnit *translationUnit = self.document.translationUnits[row];
    BOOL changed = NO;
    
    if ([tableColumn.identifier isEqualToString:[TranslationUnit targetElementName]]) {
        NSParameterAssert([object isKindOfClass:[NSString class]]);
        
        if (![translationUnit.targetNode.stringValue isEqualToString:object]) {
            changed = YES;
            translationUnit.targetNode.stringValue = object;
            [self.document.translationUnitChangeTracker trackChange:translationUnit];
            [self.document updateChangeCount:NSChangeDone];
        }
        
    }
    if ([tableColumn.identifier isEqualToString:[TranslationUnit sourceElementName]]) {
        NSParameterAssert([object isKindOfClass:[NSString class]]);
        
        if (![translationUnit.sourceNode.stringValue isEqualToString:object]) {
            changed = YES;
            translationUnit.sourceNode.stringValue = object;
            [self.document.translationUnitChangeTracker trackChange:translationUnit];
            
            NSArray *arr = [translationUnit.element nodesForXPath: @"@id" error:NULL];
            for (NSXMLNode *attribute in arr) {
                attribute.stringValue = object;
            }
            
            [self.document updateChangeCount:NSChangeDone];
        }
        
    }
    if ([tableColumn.identifier isEqualToString:[TranslationUnit noteElementName]]) {
        NSParameterAssert([object isKindOfClass:[NSString class]]);
        if (!translationUnit.noteNode) {
            translationUnit.noteNode = [[NSXMLNode alloc] initWithKind: NSXMLElementKind];
            translationUnit.noteNode.name = [TranslationUnit noteElementName];
            [translationUnit.element addChild:translationUnit.noteNode];
        }
        
        if (![translationUnit.noteNode.stringValue isEqualToString:object]) {
            changed = YES;
            translationUnit.noteNode.stringValue = object;
            [self.document.translationUnitChangeTracker trackChange:translationUnit];
        }
        
        [self.document updateChangeCount:NSChangeDone];
    }
    
    if (changed) {
        [self updateDocumentStatusLabel:@"Unsaved Changes" withColor:[NSColor colorWithRed:0.91 green:0.329 blue:0.329 alpha:1]];
    }
    
    [self.tableView reloadData];
}

/**
 * NSTableViewDataSource tableView:objectValueForTableColumn:row: method
 *
 * @param table view
 * @param object
 * @param row index
 */
- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    
    TranslationUnit *translationUnit = [self.document.translationUnits objectAtIndex:row];
    
    if ([tableColumn.identifier isEqualToString:[TranslationUnit sourceElementName]]) {

        return [self createTableCellTextFromString:translationUnit.sourceNode.stringValue atIndex:row];
    }

    if ([tableColumn.identifier isEqualToString:[TranslationUnit targetElementName]]) {
        
        return [self createTableCellTextFromString:translationUnit.targetNode.stringValue atIndex:row];
    }

    if ([tableColumn.identifier isEqualToString:[TranslationUnit noteElementName]]) {
        
        return [self createTableCellTextFromString:translationUnit.noteNode.stringValue atIndex:row];
       
    }

    return nil;
}

- (void)tableView:(NSTableView *)tableView
  willDisplayCell:(id)cell
   forTableColumn:(NSTableColumn *)tableColumn
              row:(NSInteger)row {
    
    TranslationUnit *translationUnit = [self.document.translationUnits objectAtIndex:row];
    
    if ([self.document.translationUnitChangeTracker isChanged:translationUnit]) {
        NSColor *color = [NSColor colorWithRed:0.651 green:0.8 blue:1 alpha:1];
        [cell setBackgroundColor:color];
        [cell setDrawsBackground:YES];
    } else if ([self.document.translationUnitChangeTracker isSavedChanged:translationUnit]) {
        NSColor *color = [NSColor colorWithRed:0.651 green:0.8 blue:1 alpha:0.3f];
        [cell setBackgroundColor:color];
        [cell setDrawsBackground:YES];
    } else {
        [cell setDrawsBackground:NO];
    }
}

/**
 * NSTableViewDataSource tableView:heightOfRow: method
 *
 * @param table view
 * @param table row index
 */
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    NSString *content = [self.document.translationUnits objectAtIndex:row].targetNode.stringValue;
    
    
    NSTableColumn *targetColumn = [tableView tableColumnWithIdentifier:@"target"];
    CGSize constraint = CGSizeMake([targetColumn width], 20000.0f);

    CGRect textRect = [content boundingRectWithSize:constraint
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:13]}
                                         context:nil];

    CGRect emptyRect = [@"DUMMY TEXT" boundingRectWithSize:constraint
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:13]}
                                            context:nil];
    
    return textRect.size.height ? textRect.size.height : emptyRect.size.height;
}


#pragma mark - NSTableViewDelegate

/**
 * NSTableViewDelegate tableView:rowIndexes:pboard: method
 *
 * @param table view
 * @param table row index
 * @param pasteboard
 */
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:BasicTableViewDragAndDropDataType] owner:self];
    [pboard setData:data forType:BasicTableViewDragAndDropDataType];
    
    return YES;
}

/**
 * NSTableViewDelegate tableView:validateDrop:proposedRow:proposedDropOperation: method
 *
 * @param table view
 * @param drop info
 * @param row index
 * @param drop operation
 */
- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(id )info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op {
    
    return NSDragOperationEvery;
}

/**
 * NSTableViewDelegate tableView:acceptDrop:row:dropOperation: method
 *
 * @param table view
 * @param drop info
 * @param row index
 * @param drop operation
 */
- (BOOL)tableView:(NSTableView*)tableView acceptDrop:(id)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)op {

    NSPasteboard* pboard       = [info draggingPasteboard];
    NSData* rowData            = [pboard dataForType:BasicTableViewDragAndDropDataType];
    NSIndexSet* fromRowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    
    NSMutableArray *toRowIndexes = [[NSMutableArray alloc] init];
 
    NSUInteger from = [fromRowIndexes firstIndex];
    NSUInteger index = 0;
 
    while(from != NSNotFound) {
        
        if (from > row) {
            [self.document moveTranslationUnitAtIndex:from toIndex:row];
            [toRowIndexes addObject:[NSNumber numberWithInteger:row]];
            row++;
        } else {
            [self.document moveTranslationUnitAtIndex:(from - index) toIndex:row];
            [toRowIndexes addObject:[NSNumber numberWithInteger:(row - index - 1)]];
        }
        
        from = [fromRowIndexes indexGreaterThanIndex: from];
        index ++;
    }
    
    [self.document loadTranslationUnits];
    [self.tableView reloadData];
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSNumber *number in toRowIndexes) {
        [indexSet addIndex:[number integerValue]];
    }
    [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    
    return YES;
}

#pragma mark - DocumentEventDelegate methods

/**
 * Called when a document is saved\
 *
 * @param the document that is being saved
 */
- (void)onDocumentSave:(Document *)document {
    
    [self updateDocumentStatusLabel:@"All Changes Saved" withColor:[NSColor colorWithRed:0.31 green:0.651 blue:0.196 alpha:1]];

    [self.tableView reloadData];
}

#pragma mark - Utility methods

- (void)updateDocumentStatusLabel:(NSString *)string withColor:(NSColor *)color {
    NSMutableAttributedString *statusLabel = [[NSMutableAttributedString alloc] initWithString:string];
    
    [statusLabel addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [string length])];
    
    self.documentStatusLabelOutlet.attributedStringValue = statusLabel;
}

/**
 * Creates table cell text given a string.
 * Returns an NSString* or NSAttributedString*
 *
 * @param string value
 * @param row index
 */
- (id)createTableCellTextFromString:(NSString *)string atIndex:(NSInteger)index {
    
    if ([self.searchFieldOutlet.stringValue lowercaseString] && [string length]) {
        
        NSRange range = [[string lowercaseString] rangeOfString:[self.searchFieldOutlet.stringValue lowercaseString]];
        
        return [self createSearchMatchString:string atRange:range atIndex:index];
    }
    
    
    return string;
}

/**
 * Creates an attributed string that highlights matching search text
 *
 * @param string value
 * @param range
 * @param row index
 */
- (NSAttributedString *)createSearchMatchString:(NSString *)string atRange: (NSRange)range atIndex:(NSInteger)index {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    if (range.location == NSNotFound) {
        return attributedString;
    }
    
    NSColor *color;
    
    if (index == self.currentSearchResultIndex) {
        color = [NSColor colorWithCalibratedRed:0.890625 green:0.81640625 blue:0.0078125 alpha:1.0f];
    } else {
        color = [NSColor colorWithCalibratedRed:0.953125 green:0.875 blue:0.0 alpha:1.0f];
    }
    
    [attributedString addAttribute:NSBackgroundColorAttributeName value:color range:range];
    
    return attributedString;
}

/**
 * Scrolls to the bottom of the table view
 */
- (void)scrollToBottomOfTableView {

    NSInteger numberOfRows = [self.tableView numberOfRows];
    
    if (numberOfRows > 0) {
        [self.tableView scrollRowToVisible:numberOfRows - 1];
    }
}

/**
 * Selects a table row at an index
 *
 * @param index
 */
- (void)selectTableViewRowAtIndex: (NSUInteger)index {

    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
    [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
}

@end
