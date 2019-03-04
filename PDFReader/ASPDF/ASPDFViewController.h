//
//  ASPDFViewController.h
//  PDFReader
//
//  Created by Adam Stone on 06/02/2019.
//  Copyright © 2019 SNC-Lavalin Rail & Transit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PDFKit/PDFKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASPDFView : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, PDFViewDelegate>

//Config Options
@property (retain, nonatomic) UIColor *navigationBackgroundColor;
@property (retain, nonatomic) UIColor *navigationForegroundColor;
@property (retain, nonatomic) UIColor *pageControlBackgroundColor;

@property (retain, nonatomic) UIFont *titleFont;

@property (assign, nonatomic) BOOL enableSearch;
@property (assign, nonatomic) BOOL enableShare;
@property (assign, nonatomic) BOOL enableBookmarking;
@property (assign, nonatomic) BOOL enableViewChange;
@property (assign, nonatomic) BOOL enableAnnotations;


@property (assign, nonatomic) PDFDisplayMode displayMode;
@property (assign, nonatomic) PDFDisplayDirection displayDirection;


//Interface
@property (weak, nonatomic) IBOutlet PDFView *documentContainer;
@property (weak, nonatomic) IBOutlet UINavigationBar *toolbar;
@property (weak, nonatomic) IBOutlet UIView *vwBottomBar;
@property (weak, nonatomic) IBOutlet UICollectionView *pageControl;
@property (weak, nonatomic) IBOutlet UIView *vwTopBar;
@property (weak, nonatomic) IBOutlet UISearchBar *documentSearchBar;
@property (weak, nonatomic) IBOutlet UIView *vwSearchBar;

//Interface Collections
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *viewerButtons;

//Interface Actions
- (IBAction)btnSearchTapped:(id)sender;
- (IBAction)btnPreviousResultTapped:(id)sender;
- (IBAction)btnNextResultTapped:(id)sender;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcSearchOrigin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcDocumentContainerTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcDocumentContainerBottom;

//Storage
@property (strong, nonatomic) NSMutableArray<PDFSelection *> *searchResultArray;


@end

@protocol ASPDFViewDelegate <NSObject>
@optional
@end

NS_ASSUME_NONNULL_END
