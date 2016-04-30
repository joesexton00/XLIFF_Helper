//
//  TranslationUnitChangeTracker.h
//  XLIFF Helper
//
//  Created by Joe Sexton on 4/29/16.
//  Copyright © 2016 Joe Sexton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TranslationUnit.h"

@interface TranslationUnitChangeTracker : NSObject

@property (nonatomic, strong) NSMutableArray *changedSources;
@property (nonatomic, strong) NSMutableArray *savedChangedSources;

/**
 * default initializer
 */
- (instancetype)init;

/**
 * track a change to a translation unit
 *
 * @param the translation unit
 */
- (void)trackChange:(TranslationUnit *)translationUnit;

/**
 * has the translation unit changed from the original value
 *
 * @param the translation unit
 */
- (BOOL)isChanged:(TranslationUnit *)translationUnit;

/**
 * has the translation unit changed from the original value and been saved
 *
 * @param the translation unit
 */
- (BOOL)isSavedChanged:(TranslationUnit *)translationUnit;

/**
 * clears the changes that are being tracked
 */
- (void)clearChanges;

/**
 * clears the changes that are being tracked
 */
- (void)markChangesSaved;

@end
