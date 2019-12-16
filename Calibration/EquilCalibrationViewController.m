//
//  EquilCalibrationViewController.m
//  PenTestOSX
//
//  Created by Luidia on 2019
//  Copyright © 2019년 Luidia. All rights reserved.
//

#import "EquilCalibrationViewController.h"
#import "PNFPenLib.h"
#import "CalibWindowController.h"
#import "Common.h"

enum CaliType {
    CaliType_SmartPen_Top = 0,
    CaliType_SmartPen_Bottom,
    CaliType_SmartMarker_Top,
    CaliType_SmartMarker_Left,
    CaliType_SmartMarker_Bottom
};

@interface EquilCalibrationViewController ()
{
    IBOutlet NSImageView *bgImageView;
    IBOutlet NSButton *cancelBtn;
    IBOutlet NSButton *retryBtn;
    IBOutlet NSImageView *pointer;
    IBOutlet NSImageView *pointer2;
    IBOutlet NSTextField *titleLabel;
    IBOutlet NSTextView *descLabel;

    enum CaliType type;
    int calPointCnt;
    int count;
    CGPoint m_CalResultPoint[4];
    CGPoint m_CalResultPointTemp[4];
    int penErrorCnt;
    int temperatureCnt;
    CGPoint p;
    CGPoint p2;
}
@end

@implementation EquilCalibrationViewController
@synthesize delegate;
@synthesize curScreenSize;
@synthesize mainWindowCtr;

-(void) dealloc {
    if (m_PenController && (m_PenController.modelCode == EquilSmartMarker || m_PenController.modelCode == EquilSmartMarkerBLE)) {
        [m_PenController StartReadQ];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_PEN_READ_DATA" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_LOG_MSG" object:nil];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        delegate = nil;
    }
    return self;
}
-(void) SetPenController:(PNFPenController *) pController {
    m_PenController = pController;
}
-(void) loadView {
    [super loadView];
    
    if (m_PenController) {
        [m_PenController EndReadQ];
    }
    
    penErrorCnt = 0;
    temperatureCnt = 0;
    
    [titleLabel setStringValue:@"Select your Page size"];
    [descLabel setString:@""];
    [descLabel setAlignment:NSCenterTextAlignment];
    [descLabel setTextColor:[NSColor whiteColor]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PenHandlerWithMsg:) name:@"PNF_PEN_READ_DATA" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FreeLogMsg:) name:@"PNF_LOG_MSG" object:nil];
    
    [m_PenController setRetObj:self];
    
    [self InitData];
}
-(void) InitData
{
    count = 0;
    calPointCnt = 2;
    if (m_PenController.modelCode == 4 || m_PenController.modelCode == 5) {
        NSString* desc = [NSString stringWithFormat:@"%@", @"On your writing surface, use the [MODEL] to tap the points in order, as shown in the picture."];
        desc = [desc stringByReplacingOccurrencesOfString:@"[MODEL]" withString:@"Equil Smartmarker"];
        [descLabel setString:desc];

        if (m_PenController.StationPosition == DIRECTION_TOP) {
            type = CaliType_SmartMarker_Top;
        }
        else if (m_PenController.StationPosition == DIRECTION_BOTTOM) {
            type = CaliType_SmartMarker_Bottom;
        }
        else {
            type = CaliType_SmartMarker_Left;
        }
    }
    else {
        NSString* desc = [NSString stringWithFormat:@"%@", @"On your writing surface, use the [MODEL] to tap the points in order, as shown in the picture."];
        desc = [desc stringByReplacingOccurrencesOfString:@"[MODEL]" withString:@"Equil Smartpen"];
        [descLabel setString:desc];
//        BOOL top = [[[NSUserDefaults standardUserDefaults] objectForKey:kSmartpenPositionTop] boolValue];
//        if (top)
            type = CaliType_SmartPen_Top;
//        else
//            type = CaliType_SmartPen_Bottom;
    }
    switch (type) {
        case CaliType_SmartMarker_Top:
        case CaliType_SmartMarker_Bottom: {
            p = CGPointMake(22, 303);
            p2 = CGPointMake(270, 89);
            [bgImageView setImage:[NSImage imageNamed:@"cali_sm_01"]];
            if (type == CaliType_SmartMarker_Bottom)
                [bgImageView setImage:[NSImage imageNamed:@"cali_sm_03"]];
            break;
        }
        case CaliType_SmartMarker_Left: {
            p = CGPointMake(34, 284);
            p2 = CGPointMake(274, 152);
            [bgImageView setImage:[NSImage imageNamed:@"cali_sm_02"]];
            break;
        }
        case CaliType_SmartPen_Top: {
            p = CGPointMake(46, 311);
            p2 = CGPointMake(246, 56);
            [bgImageView setImage:[NSImage imageNamed:@"cali_s"]];
            break;
        }
        case CaliType_SmartPen_Bottom: {
            p = CGPointMake(46, 334);
            p2 = CGPointMake(246, 56);
            [bgImageView setImage:[NSImage imageNamed:@"cali_s_bot"]];
            break;
        }
        default:
            break;
    }
    [pointer setFrame:CGRectMake(p.x, p.y, pointer.frame.size.width, pointer.frame.size.height)];
    NSString* countStr = [NSString stringWithFormat:@"eq_pointer_%02d", count+1];
    [pointer setImage:[NSImage imageNamed:countStr]];
    [pointer setAlphaValue:1];
    
    [pointer2 setFrame:CGRectMake(p2.x, p2.y, pointer2.frame.size.width, pointer2.frame.size.height)];
    [pointer2 setAlphaValue:1];
}
-(void) FreeLogMsg:(NSNotification *) note
{
    NSString * szS = (NSString *) [note object];
    if ([szS compare:@"FAIL_LISTENING"] == 0 ) {
//        message:@"abnormal connect. please reconnect device"
//        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@""
//                                                     message:[BaseCom GetString:TxtVIEWCONTROLLER_PENCONNECT_FAIL_MSG]
//                                                    delegate:nil
//                                           cancelButtonTitle:[BaseCom GetString:TxtCOMMON_OK]
//                                           otherButtonTitles:nil];
//        [av show];
//        [av release];
        return;
    }
    else if ([szS isEqualToString:@"CONNECTED"]) {
        penErrorCnt = 0;
    }
    else if ([szS isEqualToString:@"INVALID_PROTOCOL"]) {
        return;
    }
    else if ([szS isEqualToString:@"SESSION_CLOSED"]) {
        
    }
    else if ([szS isEqualToString:@"PEN_RMD_ERROR"]) {
        if (m_PenController && (m_PenController.PenStatus == PEN_DOWN || m_PenController.PenStatus == PEN_MOVE)) {
            penErrorCnt++;
            if (penErrorCnt > 5) {
//                [self.view makeToast:[BaseCom GetString:TxtVIEWCONTROLLER_PEN_ERROR_MSG]
//                            duration:TOAST_DURATION
//                            position:@"bottom"];
                penErrorCnt = 0;
            }
        }
        return;
    }
    else if ([szS isEqualToString:@"FIRST_DATA_RECV"]) {
    }
}
-(void) PenHandlerWithMsg:(NSNotification*) note
{
    NSDictionary* dic = [note object];
    if ([m_PenController getRetObj] != self)
        return;
    [self PenHandlerWithDictionary:dic];
}
-(void) PenHandlerWithDictionary:(NSDictionary*) dic
{
    CGPoint ptRaw = [[dic objectForKey:@"ptRaw"] pointValue];
    CGPoint ptConv = [[dic objectForKey:@"ptConv"] pointValue];
    int PenStatus  =[[dic objectForKey:@"PenStatus"] intValue];
    int Temperature = [[dic objectForKey:@"Temperature"] intValue];
    int modelCode = [[dic objectForKey:@"modelCode"] intValue];
    int SMPenFlag = [[dic objectForKey:@"SMPenFlag"] intValue];
    int SMPenState = [[dic objectForKey:@"SMPenState"] intValue];
    int pressure = [[dic objectForKey:@"pressure"] intValue];
    
    [self PenHandlerWithArgs:ptRaw
                      ptConv:ptConv
                   PenStatus:PenStatus
                 Temperature:Temperature
                   ModelCode:modelCode
                   SMPenFlag:SMPenFlag
                  SMPenState:SMPenState
                    Pressure:pressure];
    
}
-(void) PenHandler:(id) sender
{
}
-(void) PenHandlerWithArgs:(CGPoint) Arg_ptRaw ptConv:(CGPoint) Arg_ptConv PenStatus:(int) Arg_PenStatus
               Temperature:(int) Arg_Temperature ModelCode:(int) Arg_modelCode
                SMPenFlag :(int) Arg_SMPenFlag SMPenState:(int) Arg_SMPenState
                  Pressure:(int) Arg_pressure
{
    if (m_PenController.modelCode == 4 || m_PenController.modelCode == 5) {
        int smFlag = (Arg_SMPenFlag & 0x01);
        if (smFlag == 0)
            return;
    }
    
    if (count == calPointCnt) {	// already finish
        return;
    }
    if (Arg_Temperature <= 10) {
        temperatureCnt++;
        if (temperatureCnt >= 1000) {
            temperatureCnt = 0;
//            [self.view makeToast:[BaseCom GetString:TxtVIEWCONTROLLER_PEN_TEMP_ERROR_MSG]
//                        duration:TOAST_DURATION
//                        position:@"bottom"];
        }
    }
    else {
        temperatureCnt = 0;
    }
    
    switch (Arg_PenStatus) {
        case PEN_UP: {
            m_CalResultPointTemp[count].x = Arg_ptRaw.x;
            m_CalResultPointTemp[count].y = Arg_ptRaw.y;
            count++;
            
            if (count == calPointCnt) {
                NSAlert* alert = [[[NSAlert alloc] init] autorelease];
                [alert addButtonWithTitle:@"Apply"];
                [alert addButtonWithTitle:@"Retry"];
                [alert addButtonWithTitle:@"Cancel"];
                [alert setMessageText:@"Paper Size"];
                [alert setAlertStyle:NSInformationalAlertStyle];
                [alert beginSheetModalForWindow:mainWindowCtr.window
                                  modalDelegate:self
                                 didEndSelector:@selector(calibrationAlertEnded:returnCode:contextInfo:)
                                    contextInfo:NULL];
            }

            NSString* pointStr = [NSString stringWithFormat:@"eq_pointer_%02d", count+1];
            [pointer setImage:[NSImage imageNamed:pointStr]];
            [pointer setNeedsDisplay];
            
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:0.2f];
            [pointer setFrame:CGRectMake(p2.x, p2.y, pointer.frame.size.width, pointer.frame.size.height)];
            [pointer2 setAlphaValue:0];
            [NSAnimationContext endGrouping];
        }
    }
}
-(void)calibrationAlertEnded:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_LOG_MSG" object:nil];
        m_CalResultPoint[0].x = m_CalResultPointTemp[0].x;
        m_CalResultPoint[0].y = m_CalResultPointTemp[0].y;
        m_CalResultPoint[1].x = m_CalResultPointTemp[0].x;
        m_CalResultPoint[1].y = m_CalResultPointTemp[1].y;
        m_CalResultPoint[2].x = m_CalResultPointTemp[1].x;
        m_CalResultPoint[2].y = m_CalResultPointTemp[1].y;
        m_CalResultPoint[3].x = m_CalResultPointTemp[1].x;
        m_CalResultPoint[3].y = m_CalResultPointTemp[0].y;
        if (type == CaliType_SmartPen_Bottom) {
            m_CalResultPoint[0].x = m_CalResultPointTemp[1].x;
            m_CalResultPoint[0].y = m_CalResultPointTemp[1].y;
            m_CalResultPoint[1].x = m_CalResultPointTemp[1].x;
            m_CalResultPoint[1].y = m_CalResultPointTemp[0].y;
            m_CalResultPoint[2].x = m_CalResultPointTemp[0].x;
            m_CalResultPoint[2].y = m_CalResultPointTemp[0].y;
            m_CalResultPoint[3].x = m_CalResultPointTemp[0].x;
            m_CalResultPoint[3].y = m_CalResultPointTemp[1].y;
        }
        float w = m_CalResultPoint[2].x-m_CalResultPoint[0].x;
        float h = m_CalResultPoint[1].y-m_CalResultPoint[0].y;
        CGRect rect = CGRectMake(0, 0, self.curScreenSize.width, (h*self.curScreenSize.width)/w);
        [m_PenController setRetObj:nil];
        if (delegate)
        {
            if ([self.delegate respondsToSelector:@selector(closeCalibViewController_FromEquilCalibrationViewController:caliRect:)]) {
                CGRect caliRect = CGRectMake(m_CalResultPoint[0].x, m_CalResultPoint[0].y, w, h);
                [delegate closeCalibViewController_FromEquilCalibrationViewController:rect caliRect:caliRect];
            }
        }
    }
    else if (returnCode == NSAlertSecondButtonReturn) {
        [self retryClicked:nil];
        return;
    }
    else if (returnCode == NSAlertThirdButtonReturn) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_LOG_MSG" object:nil];
        if (delegate)
        {
            if ([self.delegate respondsToSelector:@selector(closeCalibViewController_FromEquilCalibrationViewController)])
                [delegate closeCalibViewController_FromEquilCalibrationViewController];
        }
    }
}
- (IBAction)backClick:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_LOG_MSG" object:nil];
    if (delegate)
    {
        if ([self.delegate respondsToSelector:@selector(closeCalibViewController_FromEquilCalibrationViewController)])
            [delegate closeCalibViewController_FromEquilCalibrationViewController];
    }
}
- (IBAction)retryClicked:(id)sender {
    [self InitData];
}

@end
