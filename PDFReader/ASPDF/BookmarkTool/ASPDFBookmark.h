//
//  ASPDFBookmark.h
//  PDFReader
//
//  Created by Adam Stone on 04/03/2019.
//  Copyright © 2019 SNC-Lavalin Rail & Transit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASPDFBookmark : NSObject <NSSecureCoding, NSCoding>

@property (assign, nonatomic) NSInteger pageNumber;
@property (assign, nonatomic) NSString *pageName;


@end

NS_ASSUME_NONNULL_END
