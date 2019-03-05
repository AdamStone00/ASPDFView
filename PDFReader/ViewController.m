//
//  ViewController.m
//  PDFReader
//
//  Created by Adam Stone on 06/02/2019.
//  Copyright © 2019 SNC-Lavalin Rail & Transit. All rights reserved.
//

#import "ViewController.h"
#import "ASPDF/ASPDFViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)btnLoadPDFTapped:(id)sender {
    
    ASPDFView *pdfViewer = [[ASPDFView alloc] init];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"pdf"];
    [pdfViewer setPdfDocument:[[PDFDocument alloc] initWithURL:url]];
    [pdfViewer setDocumentName:@"Example PDF"];
    [pdfViewer setNavigationBackgroundColor:[UIColor colorWithRed:0.21 green:0.29 blue:0.36 alpha:1.00]];
    [pdfViewer setNavigationForegroundColor:[UIColor colorWithRed:0.93 green:0.94 blue:0.95 alpha:1.00]];
    [self presentViewController:pdfViewer animated:YES completion:nil];
    
}
@end
