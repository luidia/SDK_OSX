//
//  CalibWindowController.h
//  PenTestOSX
//
//  Created by Luidia on 2019
//  Copyright © 2019년 Luidia. All rights reserved.
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
