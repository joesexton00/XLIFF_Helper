//
//  TranslationUnit.h
//  XLIFF Manager
//
//  Created by Joe Sexton on 2016-03-19.
//  Copyright © 2016 Joe Sexton.
//

#import <Foundation/Foundation.h>

@interface TranslationUnit : NSObject

@property (nonatomic, readonly) NSXMLElement *element;
@property (nonatomic, readonly) NSXMLNode *sourceNode;
@property (nonatomic, readonly) NSXMLNode *targetNode;
@property (nonatomic) NSXMLNode *noteNode;
@property (nonatomic) BOOL sourceNodeChanged;
@property (nonatomic) BOOL targetNodeChanged;
@property (nonatomic) BOOL noteNodeChanged;

/**
 * initialize using a trans-unit xml node
 *
 * @param XML node
 */
- (instancetype)initWithXMLElement:(NSXMLElement *)node;

/**
 * Returns the name of the source element
 */
+ (NSString *) sourceElementName;

/**
 * Returns the name of the target element
 */
+ (NSString *) targetElementName;

/**
 * Returns the name of the note element
 */
+ (NSString *) noteElementName;

@end
