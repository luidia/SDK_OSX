//
//  EquilCalibrationViewController.h
//  PenTestOSX
//
//  Created by Luidia on 2019
//  Copyright © 2019년 Luidia. All rights reserved.
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
