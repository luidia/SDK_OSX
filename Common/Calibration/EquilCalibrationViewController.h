//
//  EquilCalibrationViewController.h
//  Equil Note
//
//  Created by Choi on 2014. 12. 4..
//  Copyright (c) 2014년 choi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol EquilCalibrationViewControllerDelegate
-(void) closeCalibViewController_FromEquilCalibrationViewController;
-(void) closeCalibViewController_FromEquilCalibrationViewController:(CGRect)rect caliRect:(CGRect)caliRect;
@end

@class PNFPenController;
@class CalibWindowController;

@interface EquilCalibrationViewController : NSViewController
{
    CalibWindowController* mainWindowCtr;
    
    id<EquilCalibrationViewControllerDelegate> delegate;
    PNFPenController*	m_PenController;
    NSSize curScreenSize;
}
@property (readwrite) NSSize curScreenSize;
@property (assign) CalibWindowController* mainWindowCtr;
@property (nonatomic, assign) id delegate;

-(void) PenHandler:(id) sender;
-(void) SetPenController:(PNFPenController *) pController;
@end
