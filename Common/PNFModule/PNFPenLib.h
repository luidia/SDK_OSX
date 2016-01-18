//
//  PNFPenLib.h
//  PNFPenLib
//
//  Created by PNF on 5/30/12.
//  Copyright (c) 2012 Choi. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif
#import "PNFDefine.h"
@class _PenController;

@interface PNFPenController : NSObject
{
@protected
    _PenController* m_PenController;
}
@property(readonly) CGPoint     ptRaw;
@property(readonly) CGPoint     ptConv;
@property(readonly) int         PenStatus;
@property(readonly) int         StationPosition;
@property(readonly) int         Temperature;
@property(readonly) BOOL		bConnected;
#if TARGET_OS_IPHONE
#else
@property(readonly) BOOL		bConnectedHID;
@property(readonly) BOOL		bConnectedHIDDongle;
@property(readonly) NSString*	macAddress;
#endif
@property(readonly) BOOL        bStopped;
@property(readonly) BOOL        bExistCalibrationInfo;
@property(readonly) int         pressure;
@property(readonly) int         modelCode;
@property(readonly) int         MCU1Version;
@property(readonly) int         MCU2Version;
@property(readonly) int         HWVersion;
@property(readonly) int         penAliveSec;
@property(readonly) BOOL        AudioMode;
@property(readonly) int         Volume;
@property(readonly) int         battery_station;
@property(readonly) int         battery_pen;

#if TARGET_OS_IPHONE
-(int) startPen;
#else
-(int) startPen:(int)mCode;
#endif
-(void) stopPen;
-(void) restartPen;
-(void) disConnectPen;

-(void) setRetObj:(NSObject *) obj;
-(NSObject*) getRetObj;
-(void) setRetObjForEnv:(NSObject *) obj;

-(void) setCalibrationData:(CGRect) rtDraw GuideMargin:(float) margin CalibPoint:(CGPoint[]) ptCal;

-(void) setProjectiveLevel:(int) nProjectiveLevel;
-(int)  getProjectiveLevel;

-(void) changeAudioMode:(BOOL)audio;
-(void) changeVolume:(int)vol;

-(NSDictionary*) ReadQ;
-(void) RemoveQ;
-(void) ClearQ;
-(void) StartReadQ;
-(void) EndReadQ;

-(void) initPenUp;
-(float) calcSmartMarkerEraseThick:(BOOL)isBig;

#if TARGET_OS_IPHONE
#else
-(void) changeScreenSize:(CGRect)rtDraw;
-(void) InitBTConnection:(int)mCode;
-(NSArray*) savePenInfoCount;
#endif
@end
