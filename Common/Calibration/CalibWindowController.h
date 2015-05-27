//
//  CalibWindowController.h
//  UltraNoteMac
//
//  Created by choi on 8/29/13.
//  Copyright (c) 2013 choi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EquilCalibrationViewController.h"
@interface CalibWindowController : NSWindowController
{
    IBOutlet NSView *mainView;
    EquilCalibrationViewController* equilCalibViewController;
}
@property (retain) EquilCalibrationViewController* equilCalibViewController;
@end
