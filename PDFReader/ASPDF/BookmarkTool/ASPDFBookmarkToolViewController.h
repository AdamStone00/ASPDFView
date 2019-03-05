//
//  ASPDFBookmarkToolViewController.h
//  PDFReader
//
//  Created by Adam Stone on 04/03/2019.
//  Copyright © 2019 SNC-Lavalin Rail & Transit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PDFKit/PDFKit.h>
#import "ASPDFBookmark.h"

#define pdf_id(pdf_id) [NSString stringWithFormat:@"pdf_%@",(pdf_id)]


@protocol ASPDFBookmarkToolDelegate

-(void)dismissBookmarkTool;
-(void)bookmarkToolDidRequestPageAtIndex:(NSUInteger)pageNumber;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ASPDFBookmarkToolViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

//UI - Config
@property (retain, nonatomic) UIColor *navigationBackgroundColor;
@property (retain, nonatomic) UIColor *navigationForegroundColor;
@property (retain, nonatomic) UIFont *titleFont;

//UI
@property (weak, nonatomic) IBOutlet UITableView *tblBookmarks;

@property (strong, nonatomic) NSString *documentName;
@property (strong, nonatomic) PDFView *pdfView;

@property (nonatomic, retain) NSMutableArray<ASPDFBookmark *> *bookmarks;

@property (nonatomic, weak) id <ASPDFBookmarkToolDelegate> delegate;

@end


NS_ASSUME_NONNULL_END


