//
//  ASPDFBookmark.m
//  PDFReader
//
//  Created by Adam Stone on 04/03/2019.
//  Copyright © 2019 SNC-Lavalin Rail & Transit. All rights reserved.
//

#import "ASPDFBookmark.h"

@implementation ASPDFBookmark

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.pageName forKey:@"ASPDFBookmark_PageName"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.pageNumber] forKey:@"ASPDFBookmark_PageNumber"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        self.pageNumber = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"ASPDFBookmark_PageNumber"] integerValue];
        self.pageName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"ASPDFBookmark_PageName"];
    }
    return self;
}

@end
