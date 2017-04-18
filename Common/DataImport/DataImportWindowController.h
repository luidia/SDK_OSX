//
//  DataImportWindowController.h
//  PenTestOSXExtension
//
//  Created by Choi on 5/28/15.
//  Copyright (c) 2015 PNF. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PNFPenLib.h"

@interface DataImportWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet NSTableView *listTableView;
    IBOutlet NSTableView *infoTableView;
 
    PNFPenController *penController;
    
    NSMutableArray*	folderItems;
    NSMutableArray*	fileItems;
    
    NSMutableDictionary* infoDic;
    
    NSThread* convertDataThread;
    NSMutableDictionary* convertDic;
    IBOutlet NSProgressIndicator *indicator;
    
}
@property (nonatomic, assign) id delegate;
@property (nonatomic ,retain) NSMutableArray*	folderItems;
@property (nonatomic ,retain) NSMutableArray*	fileItems;
@property (retain) NSMutableDictionary* infoDic;
@property (retain) NSThread* convertDataThread;
@property (retain) NSMutableDictionary* convertDic;

-(void) SetPenController:(PNFPenController *) pController;
-(void) updateFileList;

@end
