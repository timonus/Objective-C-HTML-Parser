//
//  HTMLParser.m
//  StackOverflow
//
//  Created by Ben Reeves on 09/03/2010.
//  Copyright 2010 Ben Reeves. All rights reserved.
//

#import "HTMLParser.h"

#if defined(__has_attribute) && __has_attribute(objc_direct_members)
__attribute__((objc_direct_members))
#endif
@implementation HTMLParser {
    htmlDocPtr _doc;
}

-(HTMLNode*)doc
{
	if (_doc == NULL)
		return NULL;
	
	return [[HTMLNode alloc] initWithXMLNode:(xmlNode*)_doc];
}

-(HTMLNode*)body
{
    if (_doc == NULL)
        return NULL;
    
    return [[self doc] findChildWithTag:@"body"];
}

-(instancetype)initWithData:(NSData*)data error:(NSError**)error
{
	if ((self = [super init]))
	{
		_doc = NULL;

		if (data)
		{
			CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
			CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
            const char *enc = [(__bridge NSString *)cfencstr UTF8String];
            _doc = htmlReadMemory((xmlChar*)[data bytes],
                                  (int)data.length,
                                  "",
                                  enc,
                                  XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
		}
		else
		{
			if (error) 
			{
				*error = [NSError errorWithDomain:@"HTMLParserdomain" code:1 userInfo:nil];
			}

		}
	}
	
	return self;
}

-(void)dealloc
{
	if (_doc)
	{
		xmlFreeDoc(_doc);
	}
}

@end
