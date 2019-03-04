//
//  ASPDFPageControlViewCell.m
//  PDFReader
//
//  Created by Adam Stone on 08/02/2019.
//  Copyright © 2019 SNC-Lavalin Rail & Transit. All rights reserved.
//

#import "ASPDFPageControlViewCell.h"

@implementation ASPDFPageControlViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        self.layer.borderColor = [self selectedColor].CGColor;
        self.layer.borderWidth = 1.2;
    }else{
        self.layer.borderColor = UIColor.clearColor.CGColor;
    }
}

@end
