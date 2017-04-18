//
//  DrawView.m
//  PenTestOSX
//
//  Created by choi on 14. 3. 21..
//  Copyright (c) 2014년 choi. All rights reserved.
//

#import "DIDrawView.h"
#import "PNFStrokePoint.h"
#import "PNFPenLib.h"

@implementation DIDrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self InitCanvas];
    }
    return self;
}
-(void) awakeFromNib {
    [self InitCanvas];
}
-(void) dealloc {
    if (m_LyrMain) CGLayerRelease(m_LyrMain);
    if (m_CtxMain) CGContextRelease(m_CtxMain);
    [super dealloc];
}
-(void) changeDrawingSize {
    [self clear];
    if (m_LyrMain) CGLayerRelease(m_LyrMain);
    if (m_CtxMain) CGContextRelease(m_CtxMain);
    m_LyrMain = nil;
    m_CtxMain = nil;
    [self InitCanvas];
}
-(void) SetController:(DrawViewController *) pController
{
    m_Controller = pController;
}

-(void) InitCanvas
{
    [self CreateBitmap];
}

-(void) clear
{
    CGRect frame = self.bounds;
    CGContextClearRect(m_CtxLyr, frame);
    [self setNeedsDisplay:YES];
}

-(void) CreateBitmap
{
    CGRect frame = self.bounds;
    if (m_CtxMain) {
        CGContextRelease(m_CtxMain);
    }
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    m_CtxMain = CGBitmapContextCreate(nil,
                                      frame.size.width,
                                      frame.size.height,
                                      8,
                                      4*frame.size.width,
                                      colorspace,
                                      kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    m_LyrMain = CGLayerCreateWithContext(m_CtxMain, frame.size, nil);
    m_CtxLyr = CGLayerGetContext(m_LyrMain);
    CGColorSpaceRelease(colorspace);
    CGContextSetLineDash(m_CtxLyr, 0, nil, 0);
    CGContextSetAllowsAntialiasing(m_CtxLyr, YES);
    CGContextSetShouldAntialias(m_CtxLyr, YES);
    CGContextSetRGBStrokeColor(m_CtxLyr, 0.0,0,0,1.0);
    CGContextSetLineWidth(m_CtxLyr, 2.0);
    CGContextSetLineJoin(m_CtxLyr, kCGLineJoinRound);
    CGContextSetLineCap(m_CtxLyr, kCGLineCapRound);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawLayerInRect(ctx, self.bounds, m_LyrMain);
}
-(void) DoPenProcess:(int) penTip pressure:(int)pressure X:(float) x Y:(float) y color:(NSColor*)color erase:(BOOL)erase eraseSize:(float)eraseSize
{
    if (isnan(x) || isnan(y))
        return;
    
    switch (penTip) {
        case PEN_DOWN: {
            m_ptNew=CGPointMake(x, y);
            m_ptOld = m_ptNew;
            if (erase) {
                CGContextSetRGBStrokeColor(m_CtxLyr, 1,1,1,1);
                CGContextSetLineWidth(m_CtxLyr, eraseSize);
            }
            else {
                if (color) {
                    CGFloat r, g, b, a;
                    [color getRed:&r green:&g blue:&b alpha:&a];
                    CGContextSetRGBStrokeColor(m_CtxLyr, r, g, b, 1.0);
                }
                else {
                    CGContextSetRGBStrokeColor(m_CtxLyr, 0.0,0,0,1.0);
                }
                CGContextSetLineWidth(m_CtxLyr, 2.0);
            }
            break;
        }
        case PEN_MOVE: {
            m_ptNew=CGPointMake(x, y);
            CGContextBeginPath(m_CtxLyr);
            CGContextMoveToPoint(m_CtxLyr, m_ptOld.x, m_ptOld.y);
            CGContextAddLineToPoint(m_CtxLyr, m_ptNew.x, m_ptNew.y);
            CGContextClosePath(m_CtxLyr);
            CGContextStrokePath(m_CtxLyr);
            m_ptOld = m_ptNew;
            [self setNeedsDisplay:YES];
            break;
        }
        case PEN_UP: {
            m_ptNew=CGPointMake(x, y);
            CGContextBeginPath(m_CtxLyr);
            CGContextMoveToPoint(m_CtxLyr, m_ptOld.x, m_ptOld.y);
            CGContextAddLineToPoint(m_CtxLyr, m_ptNew.x, m_ptNew.y);
            CGContextClosePath(m_CtxLyr);
            CGContextStrokePath(m_CtxLyr);
            m_ptOld = m_ptNew;
            [self setNeedsDisplay:YES];
            break;
        }
        default:
            break;
    }
}
@end
