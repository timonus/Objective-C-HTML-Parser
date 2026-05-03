//
//  HTMLNode.m
//  StackOverflow
//
//  Created by Ben Reeves on 09/03/2010.
//  Copyright 2010 Ben Reeves. All rights reserved.
//

#import "HTMLNode.h"
#import <libxml/HTMLtree.h>

#if defined(__has_attribute) && __has_attribute(objc_direct_members)
__attribute__((objc_direct_members))
#endif
@implementation HTMLNode  {
    xmlNode * _node;
}

-(HTMLNode*)parent
{
    return [[HTMLNode alloc] initWithXMLNode:_node->parent];
}

-(NSString*)getAttributeNamed:(NSString*)name
{	
	const char * nameStr = [name UTF8String];
	
    for(xmlAttrPtr attr = _node->properties; NULL != attr; attr = attr->next)
    {
        if (strcmp((char*)attr->name, nameStr) == 0)
        {
            xmlNode * child = attr->children;
            if (child)
            {
                return [NSString stringWithCString:(void*)child->content encoding:NSUTF8StringEncoding];
            }
            else
            {
                // Needed for <html amp> to indicate the attribute is present even if empty.
                return @"";
            }
        }
    }
    
    return NULL;
}

//Returns the tag name
-(NSString*)tagName
{
	if (_node->name != NULL) {
		return [NSString stringWithCString:(void*)_node->name encoding:NSUTF8StringEncoding];
	}
	return @"br";
}

-(HTMLNode*)findChildWithTag:(NSString*)tagName
{
    HTMLNode *__block result;
    findChildrenWithTag(tagName, _node->children, ^BOOL(HTMLNode *node) {
        result = node;
        return NO;
    });
    return result;
}

-(NSArray*)findChildrenWithTag:(NSString*)tagName
{
	NSMutableArray *const array = [NSMutableArray array];
    
    findChildrenWithTag(tagName, _node->children, ^BOOL(HTMLNode *node) {
        [array addObject:node];
        return YES;
    });
	
	return array;
}

static void findChildrenWithTag(NSString *tagName, xmlNode *node, __attribute__((noescape)) BOOL (^block)(HTMLNode *node))
{
    const char *tagNameStr =  [tagName UTF8String];
    findChildren(^BOOL(xmlNodePtr node) {
        return node->name && strcmp((char*)node->name, tagNameStr) == 0;
    }, node, block);
}

static BOOL findChildren(BOOL (^matchBlock)(xmlNodePtr node), xmlNode *node, __attribute__((noescape)) BOOL (^block)(HTMLNode *node))
{
    for (;node != nil; node = node->next)
	{				
		if (matchBlock(node))
		{
            if (!block([[HTMLNode alloc] initWithXMLNode:node])) {
                return NO;
            }
		}
        if (!findChildren(matchBlock, node->children, block)) {
            return NO;
        }
	}
    return YES;
}

-(NSArray*)findChildrenWithAttribute:(NSString*)attributeString matchingName:(NSString*)classString allowPartial:(BOOL)partial
{
    const char *attribute = [attributeString UTF8String];
    const char *className = [classString UTF8String];
	NSMutableArray *const array = [NSMutableArray array];
    findChildren(^BOOL(xmlNodePtr node) {
        for(xmlAttrPtr attr = node->properties; NULL != attr; attr = attr->next)
        {
            if (strcmp((char*)attr->name, attribute) == 0)
            {
                for(xmlNode * child = attr->children; NULL != child; child = child->next)
                {
                    if (partial ? strstr((char*)child->content, className) != NULL : strcmp((char*)child->content, className) == 0) {
                        return YES;
                    }
                }
                return NO;
            }
        }
        return NO;
    }, _node->children, ^BOOL(HTMLNode *node) {
        [array addObject:node];
        return YES;
    });
	return array;
}

-(id)initWithXMLNode:(xmlNode*)xmlNode
{
	if ((self = [super init]))
	{
		_node = xmlNode;
	}
	return self;
}

@end
