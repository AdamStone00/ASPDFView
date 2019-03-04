//
//  ASPDFViewController.m
//  PDFReader
//
//  Created by Adam Stone on 06/02/2019.
//  Copyright © 2019 SNC-Lavalin Rail & Transit. All rights reserved.
//

#import "ASPDFViewController.h"
#import "ASPDFPageControlViewCell.h"

static NSString *pageThumbnailCellIdentifier = @"PageThumbnailCell";

@interface ASPDFView ()

//Internal
@property (strong, nonatomic) PDFDocument *pdfDocument;
@property (strong, nonatomic) UIBarButtonItem* shareButtonItem;
@property (strong, nonatomic) UIBarButtonItem* searchButtonItem;
@property (strong, nonatomic) UIBarButtonItem* bookmarkButtonItem;
@property (strong, nonatomic) UIBarButtonItem* annotationButtonItem;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (assign, nonatomic) int searchResultIndex;

@end

@implementation ASPDFView

@synthesize toolbar;
@synthesize vwBottomBar;
@synthesize vwTopBar;
@synthesize documentContainer;
@synthesize lcSearchOrigin;
@synthesize vwSearchBar;
@synthesize documentSearchBar;

#pragma mark - Init

- (id)init
{
    self = [self initWithNibName:@"ASPDFView" bundle:nil];
    
    if (self) {
        
        // SET DEFAULT VALUES - UI
        [self setNavigationBackgroundColor:[UIColor blackColor]];
        [self setNavigationForegroundColor:[UIColor whiteColor]];
        [self setTitleFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
        
        // SET DEFAULT VALUES - CONFIG
        [self setDisplayMode:kPDFDisplaySinglePage];
        [self setDisplayDirection:kPDFDisplayDirectionHorizontal];
        
        [self setEnableSearch: YES];
        [self setEnableShare: YES];
        [self setEnableBookmarking: YES];
        [self setEnableViewChange: YES];
        [self setEnableAnnotations: YES];
        
        // SET DEFAULT VALUES - SOTRAGE
        [self setSearchResultArray:[[NSMutableArray alloc] init]];
        
    };
    
    return self;
}

#pragma mark - Load

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configureUI];
    [self configureToolBar];
    [self configurePageControl];
    [self preparePDFView];
    [self loadPDFDocument];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updatePageControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self togglSearchTool];
    
    //Notifications For Page Change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFViewDidChangePage:) name:PDFViewPageChangedNotification object:self.documentContainer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentFinishedSearching:) name:PDFDocumentDidEndFindNotification object:self.pdfDocument];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    //Remove notifications For Page Change
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFViewPageChangedNotification object:self.documentContainer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PDFDocumentDidEndFindNotification object:self.pdfDocument];
    
}


#pragma mark - Prepare PDF View

- (void)preparePDFView {
    
    //Setup Document Container
    [self.documentContainer setBackgroundColor:[UIColor lightGrayColor]];
    [self.documentContainer setAutoScales:YES];
    [self.documentContainer setMaxScaleFactor:2.0];
    [self.documentContainer setMinScaleFactor:self.documentContainer.scaleFactorForSizeToFit];
    [self.documentContainer setDisplayMode:self.displayMode];
    [self.documentContainer zoomIn:self];
    [self.documentContainer setDisplayDirection:self.displayDirection];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleToolbarUI)];
    [self.documentContainer addGestureRecognizer:tapGesture];
    
}

-(void)configureUI {
    
    [self.toolbar setTintColor:self.navigationForegroundColor];
    [self.toolbar setBarTintColor:self.navigationBackgroundColor];
    
    NSMutableDictionary *titleBarTextAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarTextAttributes setValue:self.titleFont forKey:NSFontAttributeName];
    [titleBarTextAttributes setValue:self.navigationForegroundColor forKey:NSForegroundColorAttributeName];
    
    [self.toolbar setTitleTextAttributes:titleBarTextAttributes];

    [self.vwBottomBar setBackgroundColor:self.navigationBackgroundColor];
    [self.pageControl setBackgroundColor:self.navigationBackgroundColor];
    [self.vwTopBar setBackgroundColor:self.navigationBackgroundColor];
    
    [self.vwSearchBar setBackgroundColor:self.navigationBackgroundColor];
    [self.documentSearchBar setBarTintColor:self.navigationBackgroundColor];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setDefaultTextAttributes:@{NSFontAttributeName:self.titleFont}];
    
    for (UIButton *btn in self.viewerButtons){
        [btn setTintColor:self.navigationForegroundColor];
    }
}

#pragma mark - Document Load

- (void)loadPDFDocument {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"pdf"];
    [self setPdfDocument:[[PDFDocument alloc] initWithURL:url]];
    [self.pdfDocument setDelegate:(id)self];
    [self.documentContainer setDocument:self.pdfDocument];
    [self.documentContainer usePageViewController:(self.displayMode == kPDFDisplaySinglePage) ? YES :NO withViewOptions:nil];
    
}


#pragma mark - Page Control DataSource and Delegate

-(void)configurePageControl {
    
    [self.pageControl setDelegate:self];
    [self.pageControl setDataSource:self];
    [self.pageControl registerNib:[UINib nibWithNibName:@"ASPDFPageControlCell" bundle:nil] forCellWithReuseIdentifier:pageThumbnailCellIdentifier];
    
}

- (NSInteger)pageCount {
    
     return self.pdfDocument.pageCount > 0 ? self.pdfDocument.pageCount : 0;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [self pageCount];
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ASPDFPageControlViewCell *cell = [self.pageControl dequeueReusableCellWithReuseIdentifier:pageThumbnailCellIdentifier forIndexPath:indexPath];
    
    PDFPage *pdfPage = [self.pdfDocument pageAtIndex:indexPath.item];
    
    if (pdfPage){
        UIImage *thumbnail = [pdfPage thumbnailOfSize:cell.bounds.size forBox:kPDFDisplayBoxCropBox];
        [cell.imgPageThumbnail setImage:thumbnail];
        [cell.lblPageNumber setText:[NSString stringWithFormat:@"%ld", indexPath.item + 1]];
        [cell setSelectedColor:[self navigationForegroundColor]];
    }

    [cell setHighlighted:[self.documentContainer.currentPage isEqual:pdfPage] ? YES : NO];
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PDFPage *pdfPage = [self.pdfDocument pageAtIndex:indexPath.item];
    [self.documentContainer goToPage:pdfPage];
    
}

#pragma mark - Page Control Events

-(void)updatePageControl{
    
    NSUInteger row = [self.pdfDocument indexForPage:self.documentContainer.currentPage];
    
    if(self.selectedIndexPath){
        [self.pageControl reloadItemsAtIndexPaths:@[self.selectedIndexPath]];
    }
    
    [self setSelectedIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    [self.pageControl reloadItemsAtIndexPaths:@[self.selectedIndexPath]];
    
    if (![self.pageControl.indexPathsForVisibleItems containsObject:self.selectedIndexPath]) {
        [self.pageControl scrollToItemAtIndexPath:self.selectedIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
    
}

#pragma mark - PDF Document Notifications / Delegate

-(void)PDFViewDidChangePage:(NSNotification *)notification{
    
    [self updatePageControl];
    
}


#pragma mark -  Top / Bottom Bars

- (void)toggleToolbarUI {
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        if (self.vwTopBar.alpha == 0){self.vwTopBar.hidden = NO;}
        self.vwTopBar.alpha = self.vwTopBar.alpha == 1 ? 0 : 1;
        
        if (self.vwBottomBar.alpha == 0){self.vwBottomBar.hidden = NO;}
        self.vwBottomBar.alpha = self.vwBottomBar.alpha == 1 ? 0 : 1;
        
        /*
        if (self.vwTopBar.alpha == 0){
            [self.lcDocumentContainerTop setConstant:0];
            [self.lcDocumentContainerBottom setConstant:0];
        }else{
            [self.lcDocumentContainerTop setConstant:self.vwTopBar.bounds.size.height];
            [self.lcDocumentContainerBottom setConstant:self.vwBottomBar.bounds.size.height];
        }
        
        [self.documentContainer zoomIn:self];*/
        
        if (self.lcSearchOrigin.constant == 0){
            if (self.vwSearchBar.alpha == 0){self.vwSearchBar.hidden = NO;}
            self.vwSearchBar.alpha = self.vwSearchBar.alpha == 1 ? 0 : 1;
        }
        
    } completion:^(BOOL finished) {
        
        if (self.vwTopBar.alpha == 0){self.vwTopBar.hidden = YES;}
        
        if (self.vwBottomBar.alpha == 0){self.vwBottomBar.hidden = YES;}
        
        if (self.lcSearchOrigin.constant == 0){
            if (self.vwSearchBar.alpha == 0){self.vwSearchBar.hidden = YES;}
        }
        
    }];
    
}

- (void)configureToolBar {

    //Tools Array
    NSMutableArray *toolbarOptions = [[NSMutableArray alloc] init];
    
    //Navigation Item
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"PDF VIEWER"];
    
    //SHARE
    if (self.enableShare){
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton setImage:[UIImage imageNamed:@"aspdf-Share"] forState:UIControlStateNormal];
        [shareButton setTitle:@"" forState:UIControlStateNormal];
        [shareButton sizeToFit];
        [shareButton addTarget:self action:@selector(shareDocument) forControlEvents:UIControlEventTouchUpInside];
        self.shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
        [toolbarOptions addObject:self.shareButtonItem];
        
    }
    
    //SEARCH
    if (self.enableSearch){
        
        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [searchButton setImage:[UIImage imageNamed:@"aspdf-Search"] forState:UIControlStateNormal];
        [searchButton setTitle:@"" forState:UIControlStateNormal];
        [searchButton sizeToFit];
        [searchButton addTarget:self action:@selector(togglSearchTool) forControlEvents:UIControlEventTouchUpInside];
        self.searchButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
        [toolbarOptions addObject:self.searchButtonItem];
        
    }
    
    //BOOKMARK
    if (self.enableBookmarking){
        
        UIButton *bookmarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [bookmarkButton setImage:[UIImage imageNamed:@"aspdf-BookmarkEmpty"] forState:UIControlStateNormal];
        [bookmarkButton setTitle:@"" forState:UIControlStateNormal];
        [bookmarkButton sizeToFit];
        [bookmarkButton addTarget:self action:@selector(shareDocument) forControlEvents:UIControlEventTouchUpInside];
        self.bookmarkButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bookmarkButton];
        [toolbarOptions addObject:self.bookmarkButtonItem];
        
    }
    
    //ANNOTATION
    if (self.enableAnnotations){
        
        UIButton *annotationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [annotationButton setImage:[UIImage imageNamed:@"aspdf-Annotation"] forState:UIControlStateNormal];
        [annotationButton setTitle:@"" forState:UIControlStateNormal];
        [annotationButton sizeToFit];
        [annotationButton addTarget:self action:@selector(shareDocument) forControlEvents:UIControlEventTouchUpInside];
        self.annotationButtonItem = [[UIBarButtonItem alloc] initWithCustomView:annotationButton];
        [toolbarOptions addObject:self.annotationButtonItem];
        
    }
    
    //Add Tools to Navigation Item
    [navItem setRightBarButtonItems:toolbarOptions];
    
    //CLOSE
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"aspdf-Close"] forState:UIControlStateNormal];
    [closeButton setTitle:@"" forState:UIControlStateNormal];
    [closeButton sizeToFit];
    [closeButton addTarget:self action:@selector(closeDocument) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    
    //Add cloe button to
    [navItem setLeftBarButtonItem:closeButtonItem];
    
    //Set NavItem To View
    [self.toolbar pushNavigationItem:navItem animated:NO];
    
}

#pragma mark - Share Tool

-(void)shareDocument{
    NSData *pdfData = self.pdfDocument.dataRepresentation;
    if (pdfData){
        UIActivityViewController *shareView = [[UIActivityViewController alloc] initWithActivityItems:@[pdfData] applicationActivities:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (shareView.popoverPresentationController){
                [shareView.popoverPresentationController setBarButtonItem:self.shareButtonItem];
            }
            [self presentViewController:shareView animated:YES completion:nil];
        });
    }else{
        //TODO - Error Handling
    }
}

#pragma mark - Search Tool

-(void)togglSearchTool{
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.lcSearchOrigin setConstant:self.lcSearchOrigin.constant == 0 ? -self.vwTopBar.bounds.size.height : 0];
        if (self.vwSearchBar.alpha == 0){self.vwSearchBar.hidden = NO;}
        self.vwSearchBar.alpha = self.vwSearchBar.alpha == 1 ? 0 : 1;
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        if (self.vwSearchBar.alpha == 0){self.vwSearchBar.hidden = YES;}
        
    }];
}

- (IBAction)btnSearchTapped:(id)sender {
    
    //REsign Keyboard
    [self.documentSearchBar resignFirstResponder];
    
    //Clear Old Results
    [self.searchResultArray removeAllObjects];
    
    //Clear Index
    [self setSearchResultIndex:0];
    
    //Check Length of Search String
    if ([self.documentSearchBar.text length] > 0){
         [self.pdfDocument beginFindString:self.documentSearchBar.text withOptions:NSCaseInsensitiveSearch];
    }
    
}

- (void)didMatchString:(PDFSelection *)instance {
    
    //Match found, att it to results array
    [instance setColor:[UIColor yellowColor]];
    [self.searchResultArray addObject:instance];
    
}

-(void)documentFinishedSearching:(NSNotification *)notification{
    
    [self.documentContainer setHighlightedSelections:nil];
    
    if ([self.searchResultArray count]){
        [self.documentContainer setCurrentSelection:[self.searchResultArray objectAtIndex:self.searchResultIndex] animate:YES];
    }
  
}

- (IBAction)btnPreviousResultTapped:(id)sender {
    if ([self.searchResultArray count] && self.searchResultIndex != 0){
        [self setSearchResultIndex:self.searchResultIndex +- 1];
        PDFSelection *result = [self.searchResultArray objectAtIndex:self.searchResultIndex];
        if ([result.pages firstObject] != self.documentContainer.currentPage){
            [self.documentContainer goToPage:[result.pages firstObject]];
        }
        [self.documentContainer setCurrentSelection:result animate:YES];
    }
}

- (IBAction)btnNextResultTapped:(id)sender {
    if ([self.searchResultArray count] && self.searchResultIndex < ([self.searchResultArray count] - 1)){
        [self setSearchResultIndex:self.searchResultIndex += 1];
        PDFSelection *result = [self.searchResultArray objectAtIndex:self.searchResultIndex];
        if ([result.pages firstObject] != self.documentContainer.currentPage){
            [self.documentContainer goToPage:[result.pages firstObject]];
        }
        [self.documentContainer setCurrentSelection:result animate:YES];
    }
}

- (IBAction)btnCloseSearchTapped:(id)sender {
    
    //Remove any current selection
    [self.documentContainer setCurrentSelection:nil];
    
    //REsign Keyboard
    [self.documentSearchBar resignFirstResponder];
    
    //Clear Old Results
    [self.searchResultArray removeAllObjects];
    
    //Clear Index
    [self setSearchResultIndex:0];
    
    //Hide UI
    [self togglSearchTool];
    
}

#pragma mark - Close Documents

-(void)closeDocument{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
