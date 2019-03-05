#  PDF Reader v1.0.0

Simple PDF reader using the PDFKit framework that allows the opening of PDFs in a self contained controller.

---

## Supported Features

- Document Search
- Document Sharing
- Bookmarking
- Annotation

## Installation

Drag the entire <ASPDF> folder into your project. Make sure you also include PDFKit.framework in your project.

## Usage

### Basic 

Create an instance of the viewer

```objective-c
ASPDFView *pdfViewer = [[ASPDFView alloc] init];
```

Load a PDF document from a URL or resource store and assign it as the PDFDocument for the viewer along with a name and present the controller.

```objective-c
NSURL *url = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"pdf"];
[pdfViewer setPdfDocument:[[PDFDocument alloc] initWithURL:url]];
[pdfViewer setDocumentName:@"Example PDF"];
[self presentViewController:pdfViewer animated:YES completion:nil];
```
## Configuration

PDF Reader has several options for configuration:

### Style

- navigationBackgroundColor (UIColor)
- navigationForegroundColor (UIColor)
- pageControlBackgroundColor (UIColor)
- titleFont (UIFont)

### Feature Options
- enableSearch
- enableShare
- enableBookmarking
- enableAnnotations

## Project Details

### Requirements
* Swift 4.0
* Xcode 10.0+
* iOS 11.0+

