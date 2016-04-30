//
//  Document.m
//  XLIFF Manager
//
//  Created by Joe Sexton on 2016-03-19.
//  Copyright © 2016 Joe Sexton.
//

#import "Document.h"


@interface Document ()

@property (nonatomic, strong) NSXMLDocument *document;
@property (nonatomic, strong) NSXMLElement *root;

@end


@implementation Document

#pragma mark - NSDocument

/**
 * Disables auto-saving
 */
+ (BOOL)autosavesInPlace {
    
    return NO;
}

/**
 * Cleans up unused fields from the XLIFF doc and validates that no duplicate source IDs are in the file
 *
 * @param file URL
 * @param file type
 * @param saving operation
 * @param oritinal URL
 * @param error
 */
- (BOOL)writeToURL:(NSURL *)absoluteURL
            ofType:(NSString *)typeName
  forSaveOperation:(NSSaveOperationType)saveOperation
originalContentsURL:(NSURL *)absoluteOriginalContentsURL
             error:(NSError * _Nullable *)outError {
    
    // validates and cleans up xliff document
    NSArray *transUnitElem = [[self bodyElement] elementsForName:@"trans-unit"];
    
    NSMutableDictionary *sourceIds = [[NSMutableDictionary alloc] init];
    NSInteger index = 0;
    for (NSXMLElement *elem in transUnitElem) {
        for (NSXMLNode *child in elem.children) {
            
            // validates duplicate entries in the source node
            if ([child.name isEqualToString:[TranslationUnit sourceElementName]]) {
                
                // empty source ids can be removed
                if (![child.stringValue length]) {
                    [elem detach];
                    continue;
                }
                
                // duplicate source ids should trigger an error
                if ([sourceIds objectForKey:child.stringValue]) {
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert addButtonWithTitle:@"OK"];
                    [alert setMessageText:[NSString stringWithFormat:@"Duplicate source id found for \"%@\"", child.stringValue]];
                    [alert setInformativeText:@"Source ids must be unique, the file is invalid"];
                    [alert setAlertStyle:NSWarningAlertStyle];
                    
                    [alert runModal];
                    
                    return NO;
                }
                
                [sourceIds setObject:child.stringValue forKey:child.stringValue];
            }
            
            // empty notes can be removed
            if ([child.name isEqualToString:@"note"] && ![child.stringValue length]) {
                [child detach];
            }
        }
        
        index ++;
    }
    
    [self.translationUnitChangeTracker markChangesSaved];
    [self.translationUnitChangeTracker clearChanges];
    [self.documentEventDelegate onDocumentSave:self];
    
    return [super writeToURL:absoluteURL
                      ofType:typeName
            forSaveOperation:saveOperation
         originalContentsURL:absoluteOriginalContentsURL
                       error:outError];
}

/**
 * Adds the window controller
 */
- (void)makeWindowControllers {
    
    [self addWindowController:[[NSStoryboard storyboardWithName:@"Main" bundle:nil]
                               instantiateControllerWithIdentifier:@"Document Window Controller"]];
}

/**
 * Gets the doc
 *
 * @param doc type
 * @param error
 */
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    
    return [self.document XMLDataWithOptions:NSXMLNodePrettyPrint];
}

/**
 * Reads the data
 *
 * @param data
 * @param doc type
 * @param error
 */
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    
    self.translationUnitChangeTracker = [[TranslationUnitChangeTracker alloc] init];
    
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:data options:0 error:outError];
    if (!document) {
        return NO;
    }
    self.root = [document rootElement];
    if (![self.root.name isEqualToString:@"xliff"]) {
        return NO;
    }
    self.document = document;
    
    [self loadTranslationUnits];
    
    return YES;
}


#pragma mark - XLIFF manipulation

/**
 * Loads translation units into an array
 */
- (void)loadTranslationUnits {
    
    self.filterMatches = [[NSMutableArray alloc] init];

    NSArray *transUnitElement = [[self bodyElement] elementsForName:@"trans-unit"];
    
    NSMutableArray *array = [NSMutableArray array];
    NSUInteger index = 0;
    for (NSXMLElement *element in transUnitElement) {
        [self checkIfElementMatchesFilter:element index:index];
        [array addObject:[[TranslationUnit alloc] initWithXMLElement:element]];
        
        index++;
    }
    
    self.translationUnits = [NSArray arrayWithArray:array];
}

/**
 * Checks if the element matches search filters and adds the index to filterMatches if it does
 *
 * @param XML element
 * @param index
 */
- (void)checkIfElementMatchesFilter: (NSXMLElement *)element index: (NSUInteger)index {
    
    if (![self.translationUnitFilter length]) {
        return;
    }
    
    for (NSXMLNode *child in element.children) {

        if ([[child.stringValue lowercaseString] rangeOfString:self.translationUnitFilter].location != NSNotFound) {
            if (!self.filterMatches) {
                self.filterMatches = [[NSMutableArray alloc] init];
            }
            
            [self.filterMatches addObject:[NSNumber numberWithInteger:index]];
            
            return;
        }
    }
}

/**
 * Adds a new translation unit to the document
 */
- (void)addTranslationUnit {
    
    NSXMLElement *translationUnitElement = [self createXmlElementWithSource:@"new.translation.unit" withTarget:@"" withNote:@""];
    
    [[self bodyElement] addChild:translationUnitElement];
}

/**
 * Adds a new translation unit to the document at the specified index
 *
 * @param index
 */
- (void)addTranslationUnitAtIndex:(NSUInteger)index {
   
    NSXMLElement *translationUnitElement = [self createXmlElementWithSource:@"new.translation.unit" withTarget:@"" withNote:@""];

    [[self bodyElement] insertChild:translationUnitElement atIndex:index];
    
    TranslationUnit *translationUnit = [[TranslationUnit alloc] initWithXMLElement:translationUnitElement];
    [self.translationUnitChangeTracker trackChange:translationUnit];
}

/**
 * Create an XML element
 *
 * @param source
 * @param target
 * @param note
 */
- (NSXMLElement *)createXmlElementWithSource:(NSString *)source withTarget: (NSString *)target withNote: (NSString *)note {

    NSXMLElement *translationUnitElement = [[NSXMLElement alloc] initWithName:@"trans-unit"];
    [translationUnitElement addAttribute:[NSXMLNode attributeWithName:@"id" stringValue:source]];

    NSXMLElement *sourceElement = [[NSXMLElement alloc] initWithName:[TranslationUnit sourceElementName] stringValue:source];
    [translationUnitElement addChild:sourceElement];

    NSXMLElement *targetElement = [[NSXMLElement alloc] initWithName:[TranslationUnit targetElementName] stringValue:target];
    [translationUnitElement addChild:targetElement];

    if ([note length] > 0) {
        NSXMLElement *notesElement = [[NSXMLElement alloc] initWithName:[TranslationUnit noteElementName] stringValue:note];
        [translationUnitElement addChild:notesElement];
    }

    return translationUnitElement;
}

/**
 * Remove a translation unit
 *
 * @param index
 */
- (void)removeTranslationUnitAtIndex:(NSUInteger)index {

    [[self bodyElement] removeChildAtIndex:index];
}

/**
 * Move a translation unit
 *
 * @param from index
 * @param to index
 */
- (void)moveTranslationUnitAtIndex:(NSUInteger)fromIndex toIndex: (NSUInteger)toIndex {
    
    NSXMLElement *bodyElem = [self bodyElement];
    
    if (fromIndex < toIndex) {
        NSXMLNode *element = [bodyElem childAtIndex:fromIndex];
        [bodyElem removeChildAtIndex:fromIndex];
        [bodyElem insertChild:element atIndex:toIndex - 1];
        
    } else {
        NSXMLNode *element = [bodyElem childAtIndex:fromIndex];
        [bodyElem removeChildAtIndex:fromIndex];
        [bodyElem insertChild:element atIndex:toIndex];
    }
}

/**
 * Get the XLIFF body element
 */
- (NSXMLElement *)bodyElement {
    
    NSXMLElement *fileElem = [[self.root elementsForName:@"file"] firstObject];
    
    return [[fileElem elementsForName:@"body"] firstObject];
}

@end
