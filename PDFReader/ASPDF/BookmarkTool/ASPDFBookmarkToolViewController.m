//
//  ASPDFBookmarkToolViewController.m
//  PDFReader
//
//  Created by Adam Stone on 04/03/2019.
//  Copyright © 2019 SNC-Lavalin Rail & Transit. All rights reserved.
//

#import "ASPDFBookmarkToolViewController.h"

@interface ASPDFBookmarkToolViewController ()

@end

@implementation ASPDFBookmarkToolViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self configureToolBar];
    
    [self setBookmarks:[self loadBookmarks]];
    [self.tblBookmarks reloadData];
}

#pragma mark - Configure UI


-(void)configureUI {
    
    [self.navigationController.navigationBar setTintColor:self.navigationForegroundColor];
    [self.navigationController.navigationBar setBarTintColor:self.navigationBackgroundColor];
    
    NSMutableDictionary *titleBarTextAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarTextAttributes setValue:self.titleFont forKey:NSFontAttributeName];
    [titleBarTextAttributes setValue:self.navigationForegroundColor forKey:NSForegroundColorAttributeName];
    
    [self.navigationController.navigationBar setTitleTextAttributes:titleBarTextAttributes];
    
    [self.tblBookmarks setBounces:NO];
    [self.tblBookmarks setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tblBookmarks.bounds.size.width, 4)]];
    [self.tblBookmarks setDelegate:self];
    [self.tblBookmarks setDataSource:self];
    [self.tblBookmarks setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tblBookmarks.bounds.size.width, 4)]];
}

- (void)configureToolBar {
    
    //Navigation Item
    [self.navigationItem setTitle:@"Bookmarks"];
    
    //CLOSE
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"aspdf-Close"] forState:UIControlStateNormal];
    [closeButton setTitle:@"" forState:UIControlStateNormal];
    [closeButton sizeToFit];
    [closeButton addTarget:self action:@selector(closeTool) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    
    //Add Tools to Navigation Item
    [self.navigationItem setRightBarButtonItem:closeButtonItem];
    
    //ADD
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:[UIImage imageNamed:@"aspdf-Add"] forState:UIControlStateNormal];
    [addButton setTitle:@"" forState:UIControlStateNormal];
    [addButton sizeToFit];
    [addButton addTarget:self action:@selector(addBookmark) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    
    //Add cloe button to
    [self.navigationItem setLeftBarButtonItem:addButtonItem];
    
    //Set NavItem To View
   // [self.navigationController.navigationBar pushNavigationItem:self.navigationItem animated:NO];
    
}

#pragma mark -  Save and Load Bookmarks

- (NSMutableArray<ASPDFBookmark *> *) loadBookmarks {
    
    NSMutableArray<ASPDFBookmark *>* bookmarksArray = nil;
    
    NSData *storedBookmarks = [[NSUserDefaults standardUserDefaults] objectForKey:pdf_id(self.documentName)];
    
    NSError *err;
    
    NSArray<ASPDFBookmark *>* storedBookmarksArray = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[[NSArray class], [ASPDFBookmark class]]] fromData:storedBookmarks error:&err];
    
    if (storedBookmarksArray) {
        bookmarksArray = [storedBookmarksArray mutableCopy];
    }else{
        bookmarksArray = [NSMutableArray<ASPDFBookmark *> array];
    }
    return bookmarksArray;
}

- (void) saveBookmarks {
    
    NSData *bookmarkData = [NSKeyedArchiver archivedDataWithRootObject:self.bookmarks requiringSecureCoding:NO error:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:bookmarkData forKey:pdf_id(self.documentName)];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return self.bookmarks.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ASPDFBookmark *bookmark = [self.bookmarks objectAtIndex:indexPath.row];
    
    static NSString *cellIdentifier = @"bookmarkCell";
    UITableViewCell *cell = [self.tblBookmarks dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell.textLabel setText:bookmark.pageName];
    [cell.textLabel setFont:self.titleFont];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger index = indexPath.row;
    ASPDFBookmark *bookmark = [self.bookmarks objectAtIndex:index];
    if (self.delegate){
        [self.delegate bookmarkToolDidRequestPageAtIndex:bookmark.pageNumber - 1];
    }
}

#pragma mark - Add Bookmark

- (void) addBookmark {
    
    ASPDFBookmark *bookmark = [[ASPDFBookmark alloc] init];
    [bookmark setPageNumber:[self.pdfView.currentPage.label integerValue]];
    [bookmark setPageName:[NSString stringWithFormat:@"Page %@", self.pdfView.currentPage.label]];
    [self.bookmarks addObject:bookmark];
    
    [self saveBookmarks];
    [self.tblBookmarks reloadData];
    
}

#pragma mark - Close

- (void) closeTool {
    if (self.delegate){
        [self.delegate dismissBookmarkTool];
    }
}

@end
