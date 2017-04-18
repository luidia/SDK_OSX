//
//  DrawViewWindowController.m
//  PenTestOSX
//
//  Created by choi on 14. 3. 21..
//  Copyright (c) 2014년 choi. All rights reserved.
//

#import "DIResultViewController.h"
#import "DIDrawView.h"
#import "PNFPenLib.h"
@interface DIResultViewController ()
{
    int curPage;
    IBOutlet NSButton *prevBtn;
    IBOutlet NSButton *nextBtn;
    IBOutlet NSTextField *pageLabel;
}
@end

@implementation DIResultViewController
@synthesize delegate;
@synthesize drawView;
@synthesize penController;
@synthesize pages;

-(void) dealloc {
    [super dealloc];
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        delegate = nil;
    }
    return self;
}
- (BOOL)windowShouldClose:(NSWindow *)sender {
    if (delegate) {
        if (delegate)
        {
            if ([self.delegate respondsToSelector:@selector(closeDIResultViewController)])
                [delegate closeDIResultViewController];
        }
    }
    return YES;
}
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    curPage = 0;
    [self updateView];
}
- (IBAction)prevClicked:(id)sender {
    curPage+=-1;
    [self updateView];
}
- (IBAction)nextClicked:(id)sender {
    curPage+=1;
    [self updateView];
}
-(void) updateView {
    [NSTimer scheduledTimerWithTimeInterval:0.1f
                                     target:self
                                   selector:@selector(updateViewImpl)
                                   userInfo:nil
                                    repeats:NO];
}
-(void) updateViewImpl {
    [drawView clear];
    Page* page = [self.pages objectAtIndex:curPage];
    
    [pageLabel setStringValue:[NSString stringWithFormat:@"%d / %d", curPage+1, (int)self.pages.count]];
    
    if (self.pages.count == 1) {
        [prevBtn setHidden:YES];
        [nextBtn setHidden:YES];
        [pageLabel setHidden:YES];
    }
    else {
        if (curPage == 0) {
            [prevBtn setEnabled:NO];
            [nextBtn setEnabled:YES];
        }
        else if (curPage == self.pages.count-1) {
            [prevBtn setEnabled:YES];
            [nextBtn setEnabled:NO];
        }
        else {
            [prevBtn setEnabled:YES];
            [nextBtn setEnabled:YES];
        }
    }
    
    float marginY = 36.;
    float height = 844.;
    if (self.penController.bConnected) {
        switch (self.penController.modelCode) {
            case SmartPen: {
                [drawView setFrame:CGRectMake(0, marginY, self.window.frame.size.width, height)];
                break;
            }
            case LolLolPen: {
                [drawView setFrame:CGRectMake(0, marginY, self.window.frame.size.width, height)];
                break;
            }
            default: {
                CGPoint whiteSpaceOffset = CGPointZero;
                BOOL LandscapeMode = NO;
                float calcW = 0.;
                float calcH = 0.;
                if (page.calibrationSize == Custom) {
                    whiteSpaceOffset = CGPointZero;
                    float w = page.calibrationRect.size.width;
                    float h = page.calibrationRect.size.height;
                    calcW = self.window.frame.size.width;
                    calcH = (int)((h*self.window.frame.size.width)/w);
                    if (calcH > height) {
                        calcH = height;
                        calcW = (int)((w*height)/h);
                    }
                }
                else {
                    CGSize defaultSize = CGSizeZero;
                    defaultSize = [self GetDefaultSizeByPaper:page.calibrationSize];
                    
                    switch (page.calibrationSize) {
                        case FT6X4:
                        case FT6X5:
                        case FT8X4:
                        case FT8X5:
                            LandscapeMode = YES;
                            break;
                        default:
                            LandscapeMode = NO;
                            break;
                    }
                    
                    float w = defaultSize.width;
                    float h = defaultSize.height;
                    calcW = self.window.frame.size.width;
                    calcH = (int)((h*self.window.frame.size.width)/w);
                    if (calcH > height) {
                        calcH = height;
                        calcW = (int)((w*height)/h);
                    }
                    float ratio = page.calibrationRect.size.height/page.calibrationRect.size.width;
                    whiteSpaceOffset = CGPointMake(0, calcH-(int)(calcW*ratio));
                    calcH = calcH-whiteSpaceOffset.y;
                    
                    if (LandscapeMode) {
                        w = defaultSize.width;
                        h = defaultSize.height;
                        calcW = (int)((w*height)/h);
                        calcH = height;
                        
                        if (calcW > self.window.frame.size.width) {
                            calcW = self.window.frame.size.width;
                            calcH = (int)((h*self.window.frame.size.width)/w);
                        }
                        float ratio = page.calibrationRect.size.width/page.calibrationRect.size.height;
                        whiteSpaceOffset = CGPointMake(calcW-(int)(calcH*ratio), 0);
                        calcW = calcW-whiteSpaceOffset.x;
                    }
                }
                
                if (LandscapeMode) {
                    [drawView setFrame:CGRectMake(0, (self.window.frame.size.height-marginY-calcH)/2, calcW+whiteSpaceOffset.x, calcH)];
                }
                else {
                    [drawView setFrame:CGRectMake((self.window.frame.size.width-calcW)/2, marginY, calcW, calcH+whiteSpaceOffset.y)];
                }
                CGPoint calResultPoint[4];
                calResultPoint[0] = CGPointMake(page.calibrationRect.origin.x, page.calibrationRect.origin.y);
                calResultPoint[1] = CGPointMake(page.calibrationRect.origin.x, page.calibrationRect.origin.y+page.calibrationRect.size.height);
                calResultPoint[2] = CGPointMake(page.calibrationRect.origin.x+page.calibrationRect.size.width,
                                                page.calibrationRect.origin.y+page.calibrationRect.size.height);
                calResultPoint[3] = CGPointMake(page.calibrationRect.origin.x+page.calibrationRect.size.width,
                                                page.calibrationRect.origin.y);
                if (LandscapeMode) {
                    [penController setCalibrationData:CGRectMake(0, 0, drawView.bounds.size.width-whiteSpaceOffset.x, drawView.bounds.size.height)
                                          GuideMargin:0
                                           CalibPoint:calResultPoint];
                }
                else {
                    [penController setCalibrationData:CGRectMake(0, 0, drawView.bounds.size.width, drawView.bounds.size.height-whiteSpaceOffset.y)
                                          GuideMargin:0
                                           CalibPoint:calResultPoint];
                }
                break;
            }
        }
    }
    else {
        [drawView setFrame:CGRectMake(0, marginY, self.window.frame.size.width, height)];
    }
    [drawView changeDrawingSize];

    for (Stroke* s in page.strokeData) {
        NSColor* color = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
        CGPoint p = CGPointMake(s.point.x, drawView.frame.size.height-s.point.y);
        if (penController.modelCode == 4) {
            BOOL erase = NO;
            BOOL big = NO;
            switch (s.colorForSM) {
                case 0x51: // red marker
                    color = [NSColor colorWithRed:1.0 green:0 blue:0 alpha:1];
                    break;
                case 0x52: // green marker
                    color = [NSColor colorWithRed:60.0/255.0 green:184.0/255.0 blue:120.0/255.0 alpha:1];
                    break;
                case 0x53:
                    color = [NSColor colorWithRed:1.0 green:1.0 blue:0 alpha:1];
                    break;
                case 0x54:
                    color = [NSColor colorWithRed:0 green:0 blue:1.0 alpha:1];
                    break;
                case 0x56:
                    color = [NSColor colorWithRed:128.0/255.0 green:0 blue:128.0/255.0 alpha:1];
                    break;
                case 0x58:
                    color = [NSColor colorWithRed:0 green:0 blue:0 alpha:1];
                    break;
                case 0x59:  // eraser cap
                    erase = YES;
                    color = [NSColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1];
                    break;
                case 0x50:
                case 0x5C:  // big eraser
                    erase = YES;
                    big = YES;
                    color = [NSColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1];
                    break;
                default:
                    break;
            }
            [drawView DoPenProcess:s.strokeType pressure:100 X:p.x Y:p.y color:color erase:erase eraseSize:s.eraseSize];
        }
        else {
            [drawView DoPenProcess:s.strokeType pressure:100 X:p.x Y:p.y color:color erase:NO eraseSize:s.eraseSize];
        }
    }
}
- (IBAction)clearClicked:(id)sender {
    [self.drawView clear];
}
-(CGSize) GetDefaultSizeByPaper:(int) nPaper
{
    CGSize defaultSize = CGSizeZero;
    switch (nPaper) {
        case  Letter:
        {
            defaultSize = CGSizeMake(216, 279);
        }
            break;
        case A4:
        {
            defaultSize = CGSizeMake(210, 297);
        }
            break;
        case  A5:
        {
            defaultSize = CGSizeMake(148, 210);
        }
            break;
        case B5:
        {
            defaultSize = CGSizeMake(176, 250);
        }
            break;
            
        case B6:
        {
            defaultSize = CGSizeMake(125, 175);
        }
            break;
            
        case FT6X4:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(1828, 1219);
        }
            break;
            
        case FT6X5:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(1828, 1524);
        }
            break;
        case FT8X4:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(2438, 1219);
        }
            break;
        case FT8X5:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(2438, 1524);
        }
            break;
        case FT3X5:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(914, 1524);
        }
            break;
        case FT3X6:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(914, 1828);
        }
            break;
        case FT4X6:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(1219, 1828);
        }
            break;
        case FT3X5_BOTTOM:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(914, 1524);
        }
            break;
        case FT3X6_BOTTOM:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(914, 1828);
        }
            break;
        case FT4X6_BOTTOM:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(1219, 1828);
        }
            break;
        default:
            NSLog(@"%d is not define size",nPaper);
            break;
    }
    return defaultSize;
    
}
@end
