//
//  TimeTestWindowController.h
//  PenTestOSX
//
//  Created by choi on 14. 3. 21..
//  Copyright (c) 2014년 choi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PNFPenController;

@protocol TimeTestWindowControllerDelegate
-(void) closeTimeTestWindowController;
@end

@interface TimeTestWindowController : NSWindowController
{
    id<TimeTestWindowControllerDelegate> delegate;
    PNFPenController *penController;
}
@property (nonatomic, assign) id delegate;

-(void) SetPenController:(PNFPenController *) pController;
-(void) PenHandler:(id) sender;

@end
