//
//  TranslationUnitChangeTracker.m
//  XLIFF Helper
//
//  Created by Joe Sexton on 4/29/16.
//  Copyright © 2016 Joe Sexton. All rights reserved.
//

#import "TranslationUnitChangeTracker.h"

@implementation TranslationUnitChangeTracker

/**
 * default initializer
 */
- (instancetype)init {
    
    self = [super init];
    
    self.changedSources      = [[NSMutableArray alloc] init];
    self.savedChangedSources = [[NSMutableArray alloc] init];
    
    return self;
}

/**
 * track a change to a translation unit
 *
 * @param the translation unit
 */
- (void)trackChange:(TranslationUnit *)translationUnit {
    
    [self.changedSources addObject:translationUnit.sourceNode.stringValue];
}

/**
 * has the translation unit changed from the original value
 *
 * @param the translation unit
 */
- (BOOL)isChanged:(TranslationUnit *)translationUnit {
   
    for (NSString *source in self.changedSources) {

        if ([source isEqualToString: translationUnit.sourceNode.stringValue]) {
            return true;
        }
    }
    
    return false;
}

/**
 * has the translation unit changed from the original value and been saved
 *
 * @param the translation unit
 */
- (BOOL)isSavedChanged:(TranslationUnit *)translationUnit {
    
    for (NSString *source in self.savedChangedSources) {
        
        if ([source isEqualToString: translationUnit.sourceNode.stringValue]) {
            return true;
        }
    }
    
    return false;
}

/**
 * clears the changes that are being tracked
 */
- (void)clearChanges {
    self.changedSources = [[NSMutableArray alloc] init];
}

/**
 * clears the changes that are being tracked
 */
- (void)markChangesSaved {
    self.savedChangedSources = [NSMutableArray arrayWithArray:[self.savedChangedSources arrayByAddingObjectsFromArray:self.changedSources]];
}

@end
