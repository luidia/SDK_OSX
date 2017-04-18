//
//  DrawView.h
//  PenTestOSX
//
//  Created by choi on 14. 3. 21..
//  Copyright (c) 2014년 choi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DrawViewController;
@interface DIDrawView : NSView
{
    CGContextRef        m_CtxMain;
    CGLayerRef          m_LyrMain;
    CGContextRef        m_CtxLyr;
    
    CGPoint             m_ptOld;
    CGPoint             m_ptNew;
    
    DrawViewController* m_Controller;
    
    int                 m_nPointCnt;
    NSMutableArray      *m_Points;
}
//-(void) DoPenProcess:(int) penTip X:(float) x Y:(float) y;
-(void) clear;
-(void) SetController:(DrawViewController *) pController;
-(void) changeDrawingSize;

-(void) DoPenProcess:(int) penTip pressure:(int)pressure X:(float) x Y:(float) y color:(NSColor*)color erase:(BOOL)erase eraseSize:(float)eraseSize;
@end
