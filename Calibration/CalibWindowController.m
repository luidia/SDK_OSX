//
//  CalibWindowController.m
//  PenTestOSX
//
//  Created by Luidia on 2019
//  Copyright © 2019년 Luidia. All rights reserved.
//

#import "CalibWindowController.h"

@interface CalibWindowController ()

@end

@implementation CalibWindowController
@synthesize equilCalibViewController;

-(void) dealloc {
    self.equilCalibViewController = nil;
    [super dealloc];
}
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        self.equilCalibViewController = [[[EquilCalibrationViewController alloc] initWithNibName:@"EquilCalibrationViewController" bundle:nil] autorelease];
        self.equilCalibViewController.mainWindowCtr = self;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [mainView addSubview:self.equilCalibViewController.view];
}
@end
