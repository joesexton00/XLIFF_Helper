//
//  TranslationUnit.m
//  XLIFF Manager
//
//  Created by Joe Sexton on 2016-03-19.
//  Copyright © 2016 Joe Sexton.
//

#import "TranslationUnit.h"


@implementation TranslationUnit

/**
 * initialize using a trans-unit xml node
 *
 * @param XML node
 */
- (instancetype)initWithXMLElement:(NSXMLElement *)element {

    if ((self = [super init])) {
        _element = element;
        
        for (NSXMLNode *child in element.children) {
           
            if ([child.name isEqualToString:[[self class] sourceElementName]]) {
                _sourceNode = child;
            }
            
            if ([child.name isEqualToString:[[self class] targetElementName]]) {
                _targetNode = child;
            }
            
            if ([child.name isEqualToString:[[self class] noteElementName]]) {
                _noteNode = child;
            }
        }
    }

    return self;
}

/**
 * Returns the name of the source element
 */
+ (NSString *) sourceElementName {
    
    return @"source";
}

/**
 * Returns the name of the target element
 */
+ (NSString *) targetElementName {
    
    return @"target";
}

/**
 * Returns the name of the note element
 */
+ (NSString *) noteElementName {
    
    return @"note";
}

@end
