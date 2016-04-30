//
//  Document.h
//  XLIFF Manager
//
//  Created by Joe Sexton on 2016-03-19.
//  Copyright © 2016 Joe Sexton.
//

#import <Cocoa/Cocoa.h>

#import "TranslationUnit.h"
#import "TranslationUnitChangeTracker.h"

@class Document;

@protocol DocumentEventDelegate <NSObject>

/**
 * Called when a document is saved
 *
 * @param the document that is being saved
 */
- (void)onDocumentSave:(Document *)document;

@end

@interface Document : NSDocument

@property (nonatomic, strong) NSString *translationUnitFilter;
@property (nonatomic, strong) NSArray<TranslationUnit *> *translationUnits;
@property (nonatomic, strong) NSMutableArray *filterMatches;
@property (nonatomic, strong) TranslationUnitChangeTracker *translationUnitChangeTracker;
@property (nonatomic) id<DocumentEventDelegate> documentEventDelegate;

/**
 * Loads translation units into an array
 */
- (void)loadTranslationUnits;

/**
 * Adds a new translation unit to the document
 */
- (void)addTranslationUnit;

/**
 * Adds a new translation unit to the document at the specified index
 *
 * @param index
 */
- (void)addTranslationUnitAtIndex:(NSUInteger)index;

/**
 * Remove a translation unit
 *
 * @param index
 */
- (void)removeTranslationUnitAtIndex:(NSUInteger)index;

/**
 * Move a translation unit
 *
 * @param from index
 * @param to index
 */
- (void)moveTranslationUnitAtIndex:(NSUInteger)fromIndex toIndex: (NSUInteger)toIndex;

@end

