//
//  DrawViewWindowController.h
//  PenTestOSX
//
//  Created by choi on 14. 3. 21..
//  Copyright (c) 2014년 choi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DIDrawView.h"
#import "DataModel.h"

@class PNFPenController;

@protocol DIResultViewControllerDelegate
-(void) closeDIResultViewController;
@end

@interface DIResultViewController : NSWindowController
{
    id<DIResultViewControllerDelegate> delegate;
    IBOutlet DIDrawView *drawView;
    PNFPenController* penController;
    NSMutableArray* pages;
}
@property (assign) NSMutableArray* pages;
@property (retain) PNFPenController* penController;
@property (assign) DIDrawView *drawView;
@property (nonatomic, assign) id delegate;

@end
