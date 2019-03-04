//
//  ASPDFPageControlViewCell.h
//  PDFReader
//
//  Created by Adam Stone on 08/02/2019.
//  Copyright © 2019 SNC-Lavalin Rail & Transit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASPDFPageControlViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgPageThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *lblPageNumber;
@property (weak, nonatomic) UIColor *selectedColor;

@end

NS_ASSUME_NONNULL_END
