//
//  DataImportWindowController.m
//  PenTestOSXExtension
//
//  Created by Choi on 5/28/15.
//  Copyright (c) 2015 PNF. All rights reserved.
//

#import "DataImportWindowController.h"
#import "DataModel.h"
#import "FuncCell.h"
#import "ListCell.h"
#import "DIResultViewController.h"

#define THREAD_DELAY 0.5f

@interface DataImportWindowController () <ListCellDelegate, DIResultViewControllerDelegate>
{
    IBOutlet NSTextView *debugTextView;
    
    BOOL di_down_cancel;
    int di_down_count;
    int di_all_count;
    int di_cur_convert_idx;
    BOOL allDownMode;
    int totalread;
    double stime;
    double etime;
    
    NSIndexPath* selectedIndexPath;
    
    NSMutableArray* pageData;
    Page* currentPage;
    int saveSMFlag;
    BOOL checkDualSide;
    BOOL USBImport;
    
    DIResultViewController* diResultViewController;
}
@property (readwrite) BOOL di_down_cancel;
@property (readwrite) int di_down_count;
@property (readwrite) int di_all_count;
@property (readwrite) int di_cur_convert_idx;
@property (readwrite) BOOL allDownMode;
@property (readwrite) int totalread;
@property (readwrite) double stime;
@property (readwrite) double etime;
@property (readwrite) int saveSMFlag;;
@property (readwrite) BOOL checkDualSide;
@property (retain) NSIndexPath* selectedIndexPath;
@property (retain) NSMutableArray* pageData;
@property (assign) Page* currentPage;
@property (readwrite) BOOL USBImport;
@property (retain) DIResultViewController* diResultViewController;
@end

@implementation DataImportWindowController
@synthesize folderItems, fileItems;
@synthesize infoDic;
@synthesize convertDataThread, convertDic;
@synthesize di_down_cancel, di_down_count, di_all_count, allDownMode, totalread, stime, etime;
@synthesize di_cur_convert_idx;
@synthesize selectedIndexPath;
@synthesize delegate;
@synthesize pageData;
@synthesize currentPage;
@synthesize saveSMFlag;
@synthesize checkDualSide;
@synthesize USBImport;
@synthesize diResultViewController;

-(void) dealloc {
    [self.pageData removeAllObjects];
    self.pageData = nil;
    
    [self.folderItems removeAllObjects];
    self.folderItems = nil;
    
    [self.fileItems removeAllObjects];
    self.fileItems = nil;
    
    [self.infoDic removeAllObjects];
    self.infoDic = nil;
    
    [self.convertDic removeAllObjects];
    self.convertDic = nil;
    
    self.selectedIndexPath = nil;
    
    self.diResultViewController = nil;
    
    [self stopConvertDataThread];
    
    [super dealloc];
}
-(id) initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        self.folderItems = [[[NSMutableArray alloc] init] autorelease];
        self.fileItems = [[[NSMutableArray alloc] init] autorelease];
        self.infoDic = [[[NSMutableDictionary alloc] init] autorelease];
        self.convertDic = [[[NSMutableDictionary alloc] init] autorelease];
        self.pageData = [[[NSMutableArray alloc] init] autorelease];
        self.convertDataThread = nil;
        self.selectedIndexPath = nil;
        self.diResultViewController = nil;
        self.USBImport = NO;
        delegate = nil;
        [self initVar];
    }
    return self;
}
- (void)windowDidLoad {
    [super windowDidLoad];
    if (penController.bConnectedHID)
        self.USBImport = YES;
    [self initVar];
    
    NSNumber* key = [NSNumber numberWithInt:0];
    NSMutableArray* items = [[[NSMutableArray alloc] init] autorelease];
    [items addObject:@"Refresh"];
    [items addObject:@"Down All"];
    [items addObject:@"Remove All"];
    if (self.USBImport) {
        
    }
    else {
        [items addObject:@"Free Space"];
        [items addObject:@"Show Data Time"];
        [items addObject:@"Initialize"];
    }
    [items addObject:@"Clear Log"];
    [self.infoDic setObject:items forKey:key];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DICallback:) name:@"PNF_MSG" object:nil];
    
    listTableView.delegate = self;
    listTableView.dataSource = self;
    
    infoTableView.delegate = self;
    infoTableView.dataSource = self;
    
    [self refresh];
}
-(void) initVar {
    di_cur_convert_idx = 0;
    di_down_cancel = NO;
    di_down_count = 0;
    di_all_count = 0;
    allDownMode = NO;
    totalread = 0;
    stime = 0;
    etime = 0;
}
-(void) showIndicator {
    [self.window setIgnoresMouseEvents:YES];
    [indicator setHidden:NO];
    [indicator startAnimation:self];
}
-(void) hideIndicator {
    [self.window setIgnoresMouseEvents:NO];
    [indicator setHidden:YES];
    [indicator stopAnimation:self];
}

-(void) refresh {
    [self showIndicator];
    [self.folderItems removeAllObjects];
    [self.fileItems removeAllObjects];
    if (self.USBImport) {
        [penController checkDiData];
    }
    else {
        [penController setDIState:DI_ShowList];
    }
}
-(void) updateFileList {
    if (self.USBImport) {
        self.folderItems = [penController USBManager_FolderList];
        self.fileItems = [penController USBManager_FileList];
        di_all_count = (int)([penController USBManager_Dic].count);
    }
    else {
        self.folderItems = [penController getDIFolderName];
        for (int i=0; i<self.folderItems.count; i++) {
            [penController setChoiceFolder:i setState:0];
            [self.fileItems addObject:[penController getDIFileName:i]];
        }
        di_all_count = [penController getDIAllFileCount];
    }
    [listTableView reloadData];
    [self hideIndicator];
}
-(void) DIAllFileDown {
    int count = 0;
    if (self.USBImport) {
        count = (int)([penController USBManager_Dic].count);
    }
    else {
        count = [penController getDIAllFileCount];
    }
    if (self.USBImport) {
        if(!self.di_down_cancel) {
            int ncnt = count - self.di_down_count;
            if(ncnt > 0) {
                int nfolder =0;
                int nfile = 0;
                int t_folder = (int)[penController USBManager_FolderList].count;
                int t_file = 0;
                for(int i=0;i<t_folder;i++) {
                    t_file += (int)[[[penController USBManager_FileList] objectAtIndex:i] count];
                    if(self.di_down_count < t_file) {
                        nfolder = i;
                        if(i > 0) {
                            for(int j=0;j<nfolder;j++) {
                                nfile += (int)[[[penController USBManager_FileList] objectAtIndex:j] count];
                            }
                        }
                        break;
                    }
                }
                
                int section = nfolder;
                int row = (di_down_count-nfile);
                NSString* folderName = [penController.USBManager_FolderList objectAtIndex:section];
                NSString* fileName = [[penController.USBManager_FileList objectAtIndex:section] objectAtIndex:row];
                NSString* dateName = [NSString stringWithFormat:@"%@%@", folderName, fileName];
                NSString *key = @"20";
                key = [key stringByAppendingString:[NSString stringWithFormat:@"%@/%@/%@ %@:%@:%@",
                                                    [dateName substringWithRange:NSMakeRange(0, 2)],
                                                    [dateName substringWithRange:NSMakeRange(2, 2)],
                                                    [dateName substringWithRange:NSMakeRange(4, 2)],
                                                    [dateName substringWithRange:NSMakeRange(6, 2)],
                                                    [dateName substringWithRange:NSMakeRange(8, 2)],
                                                    [dateName substringWithRange:NSMakeRange(10, 2)]
                                                    ]];
                NSDictionary* dic = [penController.USBManager_Dic objectForKey:key];
                NSString* path = [dic objectForKey:@"path"];
                dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(aQueue, ^{
                    NSMutableData* d = [[[NSMutableData alloc] initWithContentsOfFile:[dic objectForKey:@"path"]] autorelease];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        BOOL isDir = NO;
                        if ((![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) ||
                            [d length] == 0) {
                            [NSTimer scheduledTimerWithTimeInterval:0.1
                                                             target:self
                                                           selector:@selector(cancelDIFromUSB)
                                                           userInfo:nil
                                                            repeats:NO];
                            return;
                        }
                        [penController checkDICalFromUSB:d];
                        return;
                    });
                });
                return;
            }
            else
            {
                NSLog(@"\n\nall down files : %d, %d\n\n", di_down_count, count);
                double endtime = CACurrentMediaTime() - stime;
                float speed = ((float)totalread/endtime)/1000.;
                
                NSString* tile = @"[ALL File Download] OK!!";
                NSString* msg = [NSString stringWithFormat:@"count : %d\ndownloading time : %f\ntotal size : %d\nspeed : %.02f kbyte/sec",
                                 di_down_count, endtime, totalread, speed];
                if (self.USBImport) {
                    msg = [NSString stringWithFormat:@"count : %d\ndownloading time : %f",
                           di_down_count, endtime];
                }
                NSAlert* alert = [[[NSAlert alloc] init] autorelease];
                [alert setMessageText:tile];
                [alert setInformativeText:msg];
                [alert addButtonWithTitle:@"OK"];
                [alert setAlertStyle:NSInformationalAlertStyle];
                [alert beginSheetModalForWindow:self.window
                                  modalDelegate:nil
                                 didEndSelector:nil
                                    contextInfo:NULL];
                self.allDownMode = NO;
                [self hideIndicator];
                return;
            }
        }
        else {
            NSString* tile = @"[ALL File Download] CANCEL!!";
            NSString* msg = [NSString stringWithFormat:@"count : %d", di_down_count];
            NSAlert* alert = [[[NSAlert alloc] init] autorelease];
            [alert setMessageText:tile];
            [alert setInformativeText:msg];
            [alert addButtonWithTitle:@"OK"];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert beginSheetModalForWindow:self.window
                              modalDelegate:nil
                             didEndSelector:nil
                                contextInfo:NULL];
            self.allDownMode = NO;
            [self hideIndicator];
        }
    }
    else {
        if(!self.di_down_cancel) {
            int ncnt = count - self.di_down_count;
            if(ncnt > 0) {
                int nfolder =0;
                int nfile = 0;
                int t_folder = [penController getFolderCount];
                int t_file = 0;
                for(int i=0;i<t_folder;i++) {
                    t_file += [penController getFileCount:i];
                    if(self.di_down_count < t_file) {
                        nfolder = i;
                        if(i > 0) {
                            for(int j=0;j<nfolder;j++) {
                                nfile += [penController getFileCount:j];
                            }
                        }
                        [penController setChoiceFolder:nfolder setState:0];
                        [penController setChoiceFile:(di_down_count-nfile) fileDel:false];
                        break;
                    }
                }
            }
            else
            {
                NSLog(@"\n\nall down files : %d, %d\n\n", di_down_count, count);
                double endtime = CACurrentMediaTime() - stime;
                float speed = ((float)totalread/endtime)/1000.;
                
                NSString* tile = @"[ALL File Download] OK!!";
                NSString* msg = [NSString stringWithFormat:@"count : %d\ndownloading time : %f\ntotal size : %d\nspeed : %.02f kbyte/sec",
                                 di_down_count, endtime, totalread, speed];
                
                NSAlert* alert = [[[NSAlert alloc] init] autorelease];
                [alert setMessageText:tile];
                [alert setInformativeText:msg];
                [alert addButtonWithTitle:@"OK"];
                [alert setAlertStyle:NSInformationalAlertStyle];
                [alert beginSheetModalForWindow:self.window
                                  modalDelegate:nil
                                 didEndSelector:nil
                                    contextInfo:NULL];
                self.allDownMode = NO;
                [self hideIndicator];
                return;
            }
        }
        else
        {
            NSString* tile = @"[ALL File Download] CANCEL!!";
            NSString* msg = [NSString stringWithFormat:@"count : %d", di_down_count];
            NSAlert* alert = [[[NSAlert alloc] init] autorelease];
            [alert setMessageText:tile];
            [alert setInformativeText:msg];
            [alert addButtonWithTitle:@"OK"];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert beginSheetModalForWindow:self.window
                              modalDelegate:nil
                             didEndSelector:nil
                                contextInfo:NULL];
            self.allDownMode = NO;
            [self hideIndicator];
        }
    }
}
#pragma mark PenController Notification
-(void) SetPenController:(PNFPenController *) pController {
    penController = pController;
}
- (IBAction)testClicked:(id)sender {
    [self initVar];
    self.allDownMode = NO;
    self.di_all_count = 1;
    self.di_cur_convert_idx = 0;
    [self.convertDic removeAllObjects];
    stime = CACurrentMediaTime();
    [penController setChoiceFolder:0 setState:0];
    [penController setChoiceFile:0 fileDel:NO];
}
-(void) DICallback:(NSNotification *) note {
    NSString * szS = (NSString *) [note object];
    NSLog(@"DI CALLBACK - %@", szS);
    if([szS isEqualToString:@"DI_ShowList"]) {
        NSLog(@"ALL FILE CNT : %d", [penController getDIAllFileCount]);
        int len = [penController getFolderCount];
        szS = [szS stringByAppendingString:@"\n=========================="];
        for(int i=0;i<len;i++) {
            NSString* slog = [NSString stringWithFormat:@"\nDI - folder(%d), file(%d)", i+1, [penController getFileCount:i]];
            szS = [szS stringByAppendingString:slog];
        }
        [self updateFileList];
    }
    else if([szS isEqualToString:@"DI_FileOpen"]) {
        if (self.allDownMode) {
            totalread += [penController getDIFileSize];
            
            NSString* stmp = [[penController getDISavefileName] objectAtIndex:0];
            NSLog(@"SAVEFILENAME : %@, length:%d", stmp, (int)stmp.length);
            if (self.USBImport) {
                int nfolder =0;
                int nfile = 0;
                int t_folder = (int)[penController USBManager_FolderList].count;
                int t_file = 0;
                for(int i=0;i<t_folder;i++) {
                    t_file += (int)[[[penController USBManager_FileList] objectAtIndex:i] count];
                    if(self.di_down_count < t_file) {
                        nfolder = i;
                        if(i > 0) {
                            for(int j=0;j<nfolder;j++) {
                                nfile += (int)[[[penController USBManager_FileList] objectAtIndex:j] count];
                            }
                        }
                        break;
                    }
                }
                
                int section = nfolder;
                int row = (di_down_count-nfile);
                NSString* folderName = [penController.USBManager_FolderList objectAtIndex:section];
                NSString* fileName = [[penController.USBManager_FileList objectAtIndex:section] objectAtIndex:row];
                NSString* dateName = [NSString stringWithFormat:@"%@%@", folderName, fileName];
                stmp = dateName;
            }
            int cnt = (int)penController.di_file_data_mg.count;
            NSLog(@"penController.di_file_data_mg.count = %d", (int)penController.di_file_data_mg.count);
            if (cnt > 0) {
                NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
                [dic setObject:[NSNumber numberWithBool:YES] forKey:@"valid"];
                [dic setObject:penController.di_file_data_mg forKey:@"data"];
                [dic setObject:penController.di_file_data_mg_paper forKey:@"size"];
                [dic setObject:stmp forKey:@"name"];
                [self.convertDic setObject:dic forKey:[NSNumber numberWithInt:di_down_count]];
            }
            else {
                // invalid file
                NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
                [dic setObject:[NSNumber numberWithBool:NO] forKey:@"valid"];
                [dic setObject:stmp forKey:@"name"];
                [self.convertDic setObject:dic forKey:[NSNumber numberWithInt:di_down_count]];
            }
            
            if (di_down_count == 0)
                [self startConvertDataThread];
            
            di_down_count++;
            
            [self DIAllFileDown];
        }
        else {
            totalread += [penController getDIFileSize];
            NSString* stmp = [[penController getDISavefileName] objectAtIndex:0];
            NSLog(@"SAVEFILENAME : %@, length:%d", stmp, (int)stmp.length);
            [self.pageData removeAllObjects];
            if (self.USBImport) {
                NSString* folderName = [penController.USBManager_FolderList objectAtIndex:self.selectedIndexPath.section];
                NSString* fileName = [[penController.USBManager_FileList objectAtIndex:self.selectedIndexPath.section] objectAtIndex:self.selectedIndexPath.item];
                NSString* dateName = [NSString stringWithFormat:@"%@%@", folderName, fileName];
                stmp = dateName;
            }
            int cnt = (int)penController.di_file_data_mg.count;
            if (cnt > 0) {
                NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
                [dic setObject:[NSNumber numberWithBool:YES] forKey:@"valid"];
                [dic setObject:penController.di_file_data_mg forKey:@"data"];
                [dic setObject:penController.di_file_data_mg_paper forKey:@"size"];
                [dic setObject:stmp forKey:@"name"];
                [self.convertDic setObject:dic forKey:[NSNumber numberWithInt:di_down_count]];
            }
            else {
                // invalid file
                NSMutableDictionary* dic = [[[NSMutableDictionary alloc] init] autorelease];
                [dic setObject:[NSNumber numberWithBool:NO] forKey:@"valid"];
                [dic setObject:stmp forKey:@"name"];
                [self.convertDic setObject:dic forKey:[NSNumber numberWithInt:di_down_count]];
            }
            
            [self startConvertDataThread];
            
            [self hideIndicator];
            
            double endtime = CACurrentMediaTime() - stime;
            float speed = ((float)totalread/endtime)/1000.;
            NSString* title = @"[File Download] complete!!";
            NSString* msg = [NSString stringWithFormat:@"%@\nFigure count : %d\ndownloading time : %f\ntotal size : %d\nspeed : %.02f kbyte/sec",
                             cnt==0?@"Invalid":@"Valid", [penController di_figure_count], endtime, totalread, speed];
            if (self.USBImport) {
                msg = [NSString stringWithFormat:@"%@\nFigure count : %d\ndownloading time : %f",
                       cnt==0?@"Invalid":@"Valid", [penController di_figure_count], endtime];
            }
            NSAlert* alert = [[[NSAlert alloc] init] autorelease];
            [alert setMessageText:title];
            [alert setInformativeText:msg];
            [alert addButtonWithTitle:@"OK"];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert beginSheetModalForWindow:self.window
                              modalDelegate:nil
                             didEndSelector:nil
                                contextInfo:NULL];
        }
    }
    else if([szS isEqualToString:@"FILE_DELETE_SUCCESS"] || [szS isEqualToString:@"FILE_DELETE_FAIL"]) {
        [self hideIndicator];
        
        NSString* title = @"[Remove File] complete!!";
        if ([szS isEqualToString:@"FILE_DELETE_FAIL"])
            title = @"[Remove File] failed!!";
        
        NSAlert* alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:title];
        [alert setInformativeText:@""];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:self.window
                          modalDelegate:self
                         didEndSelector:@selector(alertEndedForFileDelete:returnCode:contextInfo:)
                            contextInfo:NULL];
    }
    else if([szS isEqualToString:@"DI_ShowFreeSpace"]) {
        [self hideIndicator];
        
        NSString* title = @"[Disk free space] complete!!";
        NSString* msg = [NSString stringWithFormat:@"[ %d ] KBytes", penController.di_freespace];
        NSAlert* alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:title];
        [alert setInformativeText:msg];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:self.window
                          modalDelegate:nil
                         didEndSelector:nil
                            contextInfo:NULL];
    }
    else if ([szS isEqualToString:@"DI_ShowDate"]) {
        [self hideIndicator];
        
        NSString* title = @"[Show Date&Time] complete!!";
        NSString* msg = @"";
        uint8_t *res = (uint8_t *)[[penController getDIShowData] bytes];
        char temp[3];
        for(int i=0;i<6;i++)
        {
            temp[0] = temp[1] = temp[2] = 0;
            (void)sprintf(temp, "%02x", res[i]);
            int dec = (int)strtol(temp, NULL, 16);
            
            msg = [msg stringByAppendingString:[NSString stringWithFormat:@"%02d", dec]];
            if(i < 5) msg = [msg stringByAppendingString:@"-"];
        }
        
        NSAlert* alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:title];
        [alert setInformativeText:msg];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:self.window
                          modalDelegate:nil
                         didEndSelector:nil
                            contextInfo:NULL];
    }
    else if([szS isEqualToString:@"OK_ASK_REMOVEALL"] || [szS isEqualToString:@"FAIL_ASK_REMOVEALL"])
    {
        [self hideIndicator];
        
        NSString* title = @"[Remove All(folder&file)] complete!!";
        if ([szS isEqualToString:@"FAIL_ASK_REMOVEALL"])
            title = @"[Remove All(folder&file)] failed!!";
        
        NSAlert* alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:title];
        [alert setInformativeText:@""];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:self.window
                          modalDelegate:self
                         didEndSelector:@selector(alertEndedForFileDelete:returnCode:contextInfo:)
                            contextInfo:NULL];
    }
    else if([szS isEqualToString:@"OK_ASK_INIT_DISK"] || [szS isEqualToString:@"FAIL_ASK_INIT_DISK"])
    {
        [self hideIndicator];
        
        NSString* title = @"Init Disk Done!!";
        if ([szS isEqualToString:@"FAIL_ASK_INIT_DISK"])
            title = @"Init Disk Fail!!";
        
        NSAlert* alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:title];
        [alert setInformativeText:@""];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:self.window
                          modalDelegate:self
                         didEndSelector:@selector(alertEndedForFileDelete:returnCode:contextInfo:)
                            contextInfo:NULL];
    }
    else if([szS isEqualToString:@"FAIL_ACK"])
    {
    }
    else if([szS isEqualToString:@"DI_SEND_ERR"]) {
        [self hideIndicator];
    }
    else if([szS isEqualToString:@"DI_SEND_ERR_RE"])
    {
    }
    else if([szS isEqualToString:@"DI_APP_RESTART"])
    {
    }
    else if([szS isEqualToString:@"DI_CONNECT_CLOSED"])
    {
    }
    else if([szS isEqualToString:@"FOLDER_DELETE_SUCCESS"])
    {
    }
    else if([szS isEqualToString:@"IMPORT_NEW_FROM_USB_WITH_CHECK_FIRMWARE_VERSION"])
    {
        [self setupDIUSB];
    }
    else if([szS isEqualToString:@"IMPORT_NEW_FROM_USB"])
    {
        [self setupDIUSB];
    }
    else if([szS isEqualToString:@"IMPORT_FROM_USB_EMPTY"])
    {
        [self setupDIUSB];
    }
    else
    {
        return;
    }
}
-(void) setupDIUSB {
    [self updateFileList];
}
-(void)alertEndedForFileDelete:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    [self refresh];
}

-(void)alertEndedForRemoveAll:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) { // cancel
    }
    else if (returnCode == NSAlertSecondButtonReturn) { // ok
        if (self.USBImport) {
            [[NSFileManager defaultManager] removeItemAtPath:[penController USBManager_RootPath] error:nil];
            NSString* title = @"[Remove All(folder&file)] complete!!";
            NSAlert* alert = [[[NSAlert alloc] init] autorelease];
            [alert setMessageText:title];
            [alert setInformativeText:@""];
            [alert addButtonWithTitle:@"OK"];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert beginSheetModalForWindow:self.window
                              modalDelegate:self
                             didEndSelector:@selector(alertEndedForFileDelete:returnCode:contextInfo:)
                                contextInfo:NULL];
        }
        else {
            [self showIndicator];
            [penController setDIState:DI_RemoveAll];
        }
    }
}

-(void)alertEndedForADown:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) { // cancel
    }
    else if (returnCode == NSAlertSecondButtonReturn) { // ok
        [self initVar];
        [self showIndicator];
        self.allDownMode = NO;
        self.di_all_count = 1;
        self.di_cur_convert_idx = 0;
        [self.convertDic removeAllObjects];
        [self.pageData removeAllObjects];
        stime = CACurrentMediaTime();
        if (self.USBImport) {
            int section = (int)self.selectedIndexPath.section;
            int row = (int)self.selectedIndexPath.item;
            NSString* folderName = [penController.USBManager_FolderList objectAtIndex:section];
            NSString* fileName = [[penController.USBManager_FileList objectAtIndex:section] objectAtIndex:row];
            NSString* dateName = [NSString stringWithFormat:@"%@%@", folderName, fileName];
            NSString *key = @"20";
            key = [key stringByAppendingString:[NSString stringWithFormat:@"%@/%@/%@ %@:%@:%@",
                                                [dateName substringWithRange:NSMakeRange(0, 2)],
                                                [dateName substringWithRange:NSMakeRange(2, 2)],
                                                [dateName substringWithRange:NSMakeRange(4, 2)],
                                                [dateName substringWithRange:NSMakeRange(6, 2)],
                                                [dateName substringWithRange:NSMakeRange(8, 2)],
                                                [dateName substringWithRange:NSMakeRange(10, 2)]
                                                ]];
            NSDictionary* dic = [penController.USBManager_Dic objectForKey:key];
            NSString* path = [dic objectForKey:@"path"];
            dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(aQueue, ^{
                NSMutableData* d = [[[NSMutableData alloc] initWithContentsOfFile:[dic objectForKey:@"path"]] autorelease];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    BOOL isDir = NO;
                    if ((![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) ||
                        [d length] == 0) {
                        [NSTimer scheduledTimerWithTimeInterval:0.1
                                                         target:self
                                                       selector:@selector(cancelDIFromUSB)
                                                       userInfo:nil
                                                        repeats:NO];
                        return;
                    }
                    [penController checkDICalFromUSB:d];
                    return;
                });
            });
        }
        else {
            [penController setChoiceFolder:(int)[self.selectedIndexPath section] setState:0];
            [penController setChoiceFile:(int)[self.selectedIndexPath item] fileDel:NO];
        }
    }
}
-(void) cancelDIFromUSB {
    NSLog(@"cancelDIFromUSB");
    [self hideIndicator];
    di_down_cancel = YES;
    [self refresh];
    return;
}

-(void) downFailForEmpty {
    NSString* title = @"Import data is empty!";
    NSAlert* alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@""];
    [alert setInformativeText:title];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert beginSheetModalForWindow:self.window
                      modalDelegate:nil
                     didEndSelector:nil
                        contextInfo:NULL];
}

-(void)alertEndedForDownAll:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) { // cancel
    }
    else if (returnCode == NSAlertSecondButtonReturn) { // ok
        [self initVar];
        self.allDownMode = YES;
        if (self.USBImport) {
            self.di_all_count = (int)([penController USBManager_Dic].count);
        }
        else {
            self.di_all_count = [penController getDIAllFileCount];
        }
        
        if (di_all_count == 0) {
            [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(downFailForEmpty)
                                           userInfo:nil
                                            repeats:NO];
            return;
        }
        
        self.di_cur_convert_idx = 0;
        [self.convertDic removeAllObjects];
        [self.pageData removeAllObjects];
        
        stime = CACurrentMediaTime();
        
        [self showIndicator];
        [self DIAllFileDown];
    }
}

-(void)alertEndedForInitialize:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) { // cancel
    }
    else if (returnCode == NSAlertSecondButtonReturn) { // ok
        if (self.USBImport) {
        }
        else {
            [self showIndicator];
            [penController setDIState:DI_InitializeDisk];
        }
    }
}

-(void)alertEndedForARemove:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) { // cancel
    }
    else if (returnCode == NSAlertSecondButtonReturn) { // ok
        if (self.USBImport) {
        }
        else {
            [self showIndicator];
            [penController setChoiceFolder:(int)[self.selectedIndexPath section] setState:0];
            [penController setChoiceFile:(int)[self.selectedIndexPath item] fileDel:YES];
        }
    }
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if(tableView == listTableView) {
        int sum = 0;
        for (NSMutableArray* arr in self.fileItems) {
            sum += arr.count;
        }
        return sum;
    }
    else {
        return [[self.infoDic objectForKey:[NSNumber numberWithInt:(int)0]] count];
    }
    return 0;
}
-(NSView *)tableView:(NSTableView *)tv viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tv == infoTableView) {
        NSString* idStr = [NSString stringWithFormat:@"FuncCell%d", (int)row];
        FuncCell *result = [infoTableView makeViewWithIdentifier:idStr owner:self];
        if (result == nil) {
            NSNib* nib = [[[NSNib alloc] initWithNibNamed:@"FuncCell" bundle:nil] autorelease];
            NSArray *topLevelObjects;
            if ([nib instantiateWithOwner:self topLevelObjects:&topLevelObjects]) {
                for (id topLevelObject in topLevelObjects) {
                    if ([topLevelObject isKindOfClass:[FuncCell class]]) {
                        result = topLevelObject;
                        break;
                    }
                }
            }
            result.identifier = idStr;
            [result updateInfo:[[self.infoDic objectForKey:[NSNumber numberWithInt:(int)0]] objectAtIndex:row]];
        }
        return result;
    }
    NSString* idStr = [NSString stringWithFormat:@"ListCell%d", (int)row];
    ListCell *result = [listTableView makeViewWithIdentifier:idStr owner:self];
    if (result == nil) {
        NSNib* nib = [[[NSNib alloc] initWithNibNamed:@"ListCell" bundle:nil] autorelease];
        NSArray *topLevelObjects;
        if ([nib instantiateWithOwner:self topLevelObjects:&topLevelObjects]) {
            for (id topLevelObject in topLevelObjects) {
                if ([topLevelObject isKindOfClass:[ListCell class]]) {
                    result = topLevelObject;
                    break;
                }
            }
        }
        result.identifier = idStr;
        NSString* txt = @"";
        NSIndexPath* path = nil;
        NSString* folderName = @"";
        NSString* fileName = @"";
        BOOL find = NO;
        int sum = 0;
        for (int fileIdx = 0; fileIdx<self.fileItems.count; fileIdx++) {
            folderName = [self.folderItems objectAtIndex:fileIdx];
            NSMutableArray* arr = [self.fileItems objectAtIndex:fileIdx];
            sum += arr.count;
            if (sum > row) {
                int idx = (int)(arr.count-(sum-row));
                fileName = [arr objectAtIndex:idx];
                path = [NSIndexPath indexPathForItem:idx inSection:fileIdx];
                find = YES;
                break;
            }
        }
        if (find) {
            txt = [NSString stringWithFormat:@"%@ %@", folderName, fileName];
        }
        result.delegate = self;
        [result updateInfo:txt indexPath:path];
    }
    return result;
}
-(void) downClickedCell:(NSIndexPath *)indexPath {
    self.allDownMode = NO;
    if (indexPath != nil) {
        self.selectedIndexPath = indexPath;
        NSString* title = @"A Down?";
        NSAlert* alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:@""];
        [alert setInformativeText:title];
        [alert addButtonWithTitle:@"Cancel"];
        [alert addButtonWithTitle:@"Down"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:self.window
                          modalDelegate:self
                         didEndSelector:@selector(alertEndedForADown:returnCode:contextInfo:)
                            contextInfo:NULL];
    }
}
-(void) delClickedCell:(NSIndexPath *)indexPath {
    if (indexPath != nil) {
        self.selectedIndexPath = indexPath;
        NSString* title = @"A Remove?";
        NSAlert* alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:@""];
        [alert setInformativeText:title];
        [alert addButtonWithTitle:@"Cancel"];
        [alert addButtonWithTitle:@"Remove"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:self.window
                          modalDelegate:self
                         didEndSelector:@selector(alertEndedForARemove:returnCode:contextInfo:)
                            contextInfo:NULL];
    }
}
-(NSIndexPath*) findIndexPath:(int)idx {
    return [NSIndexPath indexPathForItem:idx inSection:0];
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView* tableView = (NSTableView*)notification.object;
    NSIndexPath* indexPath = [self findIndexPath:(int)tableView.selectedRow];
    [tableView deselectRow:indexPath.item];
    if (tableView == listTableView) {
    }
    else {
        if (indexPath.section == 0) {
            if (indexPath.item == 0) { // Refresh
                [self refresh];
            }
            else if (indexPath.item == 1) { // Down All
                NSString* title = @"Down All?";
                NSAlert* alert = [[[NSAlert alloc] init] autorelease];
                [alert setMessageText:@""];
                [alert setInformativeText:title];
                [alert addButtonWithTitle:@"Cancel"];
                [alert addButtonWithTitle:@"Down"];
                [alert setAlertStyle:NSInformationalAlertStyle];
                [alert beginSheetModalForWindow:self.window
                                  modalDelegate:self
                                 didEndSelector:@selector(alertEndedForDownAll:returnCode:contextInfo:)
                                    contextInfo:NULL];
            }
            else if (indexPath.item == 2) { // Remove All
                NSString* title = @"Remove All?";
                NSAlert* alert = [[[NSAlert alloc] init] autorelease];
                [alert setMessageText:@""];
                [alert setInformativeText:title];
                [alert addButtonWithTitle:@"Cancel"];
                [alert addButtonWithTitle:@"Remove"];
                [alert setAlertStyle:NSInformationalAlertStyle];
                [alert beginSheetModalForWindow:self.window
                                  modalDelegate:self
                                 didEndSelector:@selector(alertEndedForRemoveAll:returnCode:contextInfo:)
                                    contextInfo:NULL];
            }
            else if (indexPath.item == (self.USBImport?9999:3)) { // Free Space
                [self showIndicator];
                [penController setDIState:DI_ShowFreeSpace];
            }
            else if (indexPath.item == (self.USBImport?9999:4)) { // Show Date/Time
                [self showIndicator];
                [penController setDIState:DI_ShowDate];
            }
            else if (indexPath.item == (self.USBImport?9999:5)) { // Initialize
                NSString* title = @"Initialize?";
                NSAlert* alert = [[[NSAlert alloc] init] autorelease];
                [alert setMessageText:@""];
                [alert setInformativeText:title];
                [alert addButtonWithTitle:@"Cancel"];
                [alert addButtonWithTitle:@"Initialize"];
                [alert setAlertStyle:NSInformationalAlertStyle];
                [alert beginSheetModalForWindow:self.window
                                  modalDelegate:self
                                 didEndSelector:@selector(alertEndedForInitialize:returnCode:contextInfo:)
                                    contextInfo:NULL];
            }
            else if (indexPath.item == (self.USBImport?3:6)) { // Clear Log
                [debugTextView setString:@""];
            }
        }
    }
}

-(void) startConvertDataThread {
    NSLog(@"startConvertDataThread");
    [self stopConvertDataThread];
    self.convertDataThread = [[[NSThread alloc] initWithTarget:self selector:@selector(runConverData:) object:self] autorelease];
    [self.convertDataThread start];
}
-(void) stopConvertDataThread {
    NSLog(@"stopConvertDataThread..........1");
    if (self.convertDataThread) {
        NSLog(@"stopConvertDataThread..........2");
        [self.convertDataThread cancel];
        [NSThread sleepForTimeInterval:THREAD_DELAY];
        self.convertDataThread = nil;
    }
}
-(void) runConverData:(id)object {
    @autoreleasepool {
        while ([[NSThread currentThread] isCancelled] == NO) {
            NSMutableDictionary* dic = [self.convertDic objectForKey:[NSNumber numberWithInt:self.di_cur_convert_idx]];
            if (dic == nil) {
                [NSThread sleepForTimeInterval:THREAD_DELAY];
                continue;
            }
            NSString* name = [dic objectForKey:@"name"];
            BOOL valid = [[dic objectForKey:@"valid"] boolValue];
            if (!valid) {
                [self addDebugText:[NSString stringWithFormat:@"\nName = %@",name]];
                [self addDebugText:@"Invalid Data!!!"];
                self.di_cur_convert_idx++;
                if (self.di_cur_convert_idx == self.di_all_count) {
                    NSLog(@"ConvertDataThread Stop");
                    break;
                }
                [NSThread sleepForTimeInterval:THREAD_DELAY];
                continue;
            }
            NSMutableArray* dataArr = [dic objectForKey:@"data"];
            NSMutableArray* sizeArr = [dic objectForKey:@"size"];
            [self addDebugText:[NSString stringWithFormat:@"\nName = %@",name]];
            for (int i=0; i<sizeArr.count; i++) {
                CGPoint calResultPoint[4];
                calResultPoint[0] = CGPointZero;
                calResultPoint[1] = CGPointZero;
                calResultPoint[2] = CGPointZero;
                calResultPoint[3] = CGPointZero;
                
                NSDictionary* tDic = [sizeArr objectAtIndex:i];
                enum CalibrationSize di_calib = (enum CalibrationSize)[[tDic objectForKey:@"cali"] intValue];
                int position = [[tDic objectForKey:@"position"] intValue];
                [self addDebugText:[NSString stringWithFormat:@"Position: [%d]", position]];
                if (di_calib == Letter) { [self addDebugText:@"Calibration = Letter"]; LETTER() }
                else if (di_calib == A4) { [self addDebugText:@"Calibration = A4"]; A4() }
                else if (di_calib == A5) { [self addDebugText:@"Calibration = A5"]; A5() }
                else if (di_calib == B5) { [self addDebugText:@"Calibration = B5"]; B5() }
                else if (di_calib == B6) { [self addDebugText:@"Calibration = B6"]; B6() }
                else if (di_calib == FT6X4) { [self addDebugText:@"Calibration = FT_6X4"]; FT_6X4() }
                else if (di_calib == FT6X5) { [self addDebugText:@"Calibration = FT_6X5"]; FT_6X5() }
                else if (di_calib == FT8X4) { [self addDebugText:@"Calibration = FT_8X4"]; FT_8X4() }
                else if (di_calib == FT8X5) { [self addDebugText:@"Calibration = FT_8X5"]; FT_8X5() }
                else if (di_calib == FT3X5) { [self addDebugText:@"Calibration = FT_3X5"]; FT_3X5() }
                else if (di_calib == FT3X6) { [self addDebugText:@"Calibration = FT_3X6"]; FT_3X6() }
                else if (di_calib == FT4X6) { [self addDebugText:@"Calibration = FT_4X6"]; FT_4X6() }
                else if (di_calib == FT3X5_BOTTOM) { [self addDebugText:@"Calibration = FT_3X5_BOTTOM"]; FT_3X5_BOTTOM() }
                else if (di_calib == FT3X6_BOTTOM) { [self addDebugText:@"Calibration = FT_3X6_BOTTOM"]; FT_3X6_BOTTOM() }
                else if (di_calib == FT4X6_BOTTOM) { [self addDebugText:@"Calibration = FT_4X6_BOTTOM"]; FT_4X6_BOTTOM() }
                
                BOOL landscape = NO;
                switch (di_calib) {
                    case FT6X4:
                    case FT6X5:
                    case FT8X4:
                    case FT8X5:
                        landscape = YES;
                        break;
                    default:
                        landscape = NO;
                        break;
                }
                [penController setProjectiveLevel:4];
                
                float ww = calResultPoint[2].x-calResultPoint[0].x;
                float hh = calResultPoint[1].y-calResultPoint[0].y;
                CGRect calibrationRect = CGRectMake(0, 0, (int)self.window.frame.size.width, (hh*self.window.frame.size.width)/ww);
                
                CGPoint whiteSpaceOffset = CGPointZero;
                CGSize defaultSize = CGSizeZero;
                float calcW = 0.;
                float calcH = 0.;
                defaultSize = [self GetDefaultSizeByPaper:di_calib];
                float w = defaultSize.width;
                float h = defaultSize.height;
                calcW = self.window.frame.size.width;
                calcH = (int)((h*self.window.frame.size.width)/w);
                if (calcH > self.window.frame.size.height) {
                    calcH = self.window.frame.size.height;
                    calcW = (int)((w*self.window.frame.size.height)/h);
                }
                float ratio = calibrationRect.size.height/calibrationRect.size.width;
                whiteSpaceOffset = CGPointMake(0, calcH-(int)(calcW*ratio));
                calcH = calcH-whiteSpaceOffset.y;
                
                if (landscape) {
                    w = defaultSize.width;
                    h = defaultSize.height;
                    calcW = (int)((w*self.window.frame.size.height)/h);
                    calcH = self.window.frame.size.height;
                    
                    if (calcW > self.window.frame.size.width) {
                        calcW = self.window.frame.size.width;
                        calcH = (int)((h*self.window.frame.size.width)/w);
                    }
                    float ratio = calibrationRect.size.width/calibrationRect.size.height;
                    whiteSpaceOffset = CGPointMake(calcW-(int)(calcH*ratio), 0);
                    calcW = calcW-whiteSpaceOffset.x;
                }
                CGSize drawSize = CGSizeZero;
                if (landscape) {
                    drawSize = CGSizeMake(calcW+whiteSpaceOffset.x, calcH);
                    [penController setCalibrationData:(CGRectMake(0, 0, drawSize.width-whiteSpaceOffset.x, drawSize.height))
                                          GuideMargin:0
                                           CalibPoint:calResultPoint];
                }
                else {
                    drawSize = CGSizeMake(calcW, calcH+whiteSpaceOffset.y);
                    [penController setCalibrationData:(CGRectMake(0, 0, drawSize.width, drawSize.height-whiteSpaceOffset.y))
                                          GuideMargin:0
                                           CalibPoint:calResultPoint];
                }
                
                {
                    Page* page = [[[Page alloc] init] autorelease];
                    page.calibrationSize = di_calib;
                    page.drawSize = drawSize;
                    float w = calResultPoint[2].x-calResultPoint[0].x;
                    float h = calResultPoint[1].y-calResultPoint[0].y;
                    page.calibrationRect = CGRectMake(calResultPoint[0].x, calResultPoint[0].y, w, h);
                    
                    self.currentPage = page;
                    self.saveSMFlag = -1;
                    self.checkDualSide = NO;
                    [self.pageData addObject:page];
                }
                NSData* data = [dataArr objectAtIndex:i];
                [penController setRetObj:self];
                [penController changeScreenSize:CGRectMake(0, 0, drawSize.width, drawSize.height)];
                [penController convertData:data c:FALSE];
            }
            self.di_cur_convert_idx++;
            if (self.di_cur_convert_idx == self.di_all_count) {
                NSLog(@"ConvertDataThread Stop");
                [self performSelectorOnMainThread:@selector(showPage) withObject:nil waitUntilDone:NO];
                break;
            }
            [NSThread sleepForTimeInterval:THREAD_DELAY];
        }
    }
}
-(void) showPage {
    if ([self.diResultViewController isWindowLoaded]) {
        [self.diResultViewController close];
        self.diResultViewController = nil;
    }
    self.diResultViewController = [[[DIResultViewController alloc] initWithWindowNibName:@"DIResultViewController"] autorelease];
    self.diResultViewController.delegate = self;
    self.diResultViewController.pages = self.pageData;
    self.diResultViewController.penController = penController;
    [self.diResultViewController showWindow:self];
    [penController changeScreenSize:self.diResultViewController.drawView.bounds];
}

-(void) closeDIResultViewController {
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(closeDIResultViewControllerImpl)
                                   userInfo:nil
                                    repeats:NO];
}
-(void) closeDIResultViewControllerImpl {
    self.diResultViewController = nil;
}

#pragma mark Debug
-(void) addDebugText:(NSString*)text {
    [self performSelectorOnMainThread:@selector(addDebugTextOnMainThread:) withObject:text waitUntilDone:YES];
}
-(void) addDebugTextOnMainThread:(NSString*)text {
    NSString* t = [NSString stringWithFormat:@"%@\n%@", debugTextView.string, text];
    [debugTextView setString:t];
    [debugTextView scrollRangeToVisible:NSMakeRange([debugTextView.string length], 0)];
}
-(CGSize) GetDefaultSizeByPaper:(int) nPaper {
    CGSize defaultSize = CGSizeZero;
    switch (nPaper) {
        case  Letter:
        {
            defaultSize = CGSizeMake(216, 279);
        }
            break;
        case A4:
        {
            defaultSize = CGSizeMake(210, 297);
        }
            break;
        case  A5:
        {
            defaultSize = CGSizeMake(148, 210);
        }
            break;
        case B5:
        {
            defaultSize = CGSizeMake(176, 250);
        }
            break;
            
        case B6:
        {
            defaultSize = CGSizeMake(125, 175);
        }
            break;
            
        case FT6X4:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(1828, 1219);
        }
            break;
            
        case FT6X5:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(1828, 1524);
        }
            break;
        case FT8X4:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(2438, 1219);
        }
            break;
        case FT8X5:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(2438, 1524);
        }
            break;
        case FT3X5:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(914, 1524);
        }
            break;
        case FT3X6:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(914, 1828);
        }
            break;
        case FT4X6:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(1219, 1828);
        }
            break;
        case FT3X5_BOTTOM:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(914, 1524);
        }
            break;
        case FT3X6_BOTTOM:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(914, 1828);
        }
            break;
        case FT4X6_BOTTOM:
        {
            // TODO:: marker
            defaultSize = CGSizeMake(1219, 1828);
        }
            break;
        default:
            NSLog(@"%d is not define size",nPaper);
            break;
    }
    return defaultSize;
    
}
-(void) PenHandlerDI:(id)sender {
    [self DoPenProcessDI:penController.PenStatus SMPenState:penController.SMPenState];
}
-(void) DoPenProcessDI:(int) PenStatus SMPenState:(int) smPenState {
    if (isnan(penController.ptRaw.x) ||
        isnan(penController.ptRaw.y) ||
        isnan(penController.ptConv.x) ||
        isnan(penController.ptConv.y))
        return;
    
    if (self.currentPage) {
        Stroke* stroke = [[[Stroke alloc] init] autorelease];
        stroke.strokeType = PenStatus;
        stroke.point = penController.ptConv;
        if (penController.modelCode == EquilSmartMarker) {
            int smFlag = (penController.SMPenFlag & 0x01);
            if (self.saveSMFlag == -1) {
                self.saveSMFlag = smFlag;
            }
            else {
                if (self.saveSMFlag != smFlag) {
                    self.saveSMFlag = smFlag;
                    if (self.checkDualSide) {
                        if (smFlag) { // right
                            self.currentPage = [self.pageData objectAtIndex:self.pageData.count-1];
                        }
                        else { // left
                            self.currentPage = [self.pageData objectAtIndex:self.pageData.count-2];
                        }
                    }
                    else {
                        self.checkDualSide = YES;
                        Page* page = [[[Page alloc] init] autorelease];
                        page.calibrationSize = self.currentPage.calibrationSize;
                        page.drawSize = self.currentPage.drawSize;
                        page.calibrationRect = self.currentPage.calibrationRect;
                        
                        if (smFlag) { // right
                            [self.pageData addObject:page];
                        }
                        else { // left
                            [self.pageData insertObject:page atIndex:self.pageData.count-1];
                        }
                        self.currentPage = page;
                    }
                }
            }
            stroke.colorForSM = penController.SMPenState;
            BOOL eraseIsBig = NO;
            switch (penController.SMPenState) {
                case 0x59: { eraseIsBig = NO; break; }
                case 0x50: { eraseIsBig = YES; break; }
                case 0x5C: { eraseIsBig = YES; break; }
                default:
                    break;
            }
            stroke.eraseSize = [penController calcSmartMarkerEraseThick:eraseIsBig];
        }
        [self.currentPage.strokeData addObject:stroke];
    }
    
    switch (PenStatus) {
        case PEN_DOWN: {
            if (penController.modelCode == EquilSmartMarker) {
                NSString* color = @"";
                switch (penController.SMPenState) {
                    case 0x51:
                    case 0xf: { color = @"Red"; break; }
                    case 0x52: { color = @"Green"; break; }
                    case 0x53: { color = @"Yellow"; break; }
                    case 0x54: { color = @"Blue"; break; }
                    case 0x56: { color = @"Violet"; break; }
                    case 0x58: { color = @"Black"; break; }
                    case 0x59: { color = @"Erase Cap"; break; }
                    case 0x50: { color = @"Erase Big"; break; }
                    case 0x5C: { color = @"Erase Big"; break; }
                    default:
                        break;
                }
                //                [self addDebugText:[NSString stringWithFormat:@"Color = %@", color]];
                //                NSLog(@"Color = %@", color);
            }
            else {
                
            }
            //            [self addDebugText:[NSString stringWithFormat:@"Down %@", NSStringFromCGPoint(penController.ptConv)]];
            NSLog(@"%@", [NSString stringWithFormat:@"Down %f, %f", penController.ptConv.x, penController.ptConv.y]);
            break;
        }
        case PEN_MOVE:
            //            [self addDebugText:[NSString stringWithFormat:@"Move %@", NSStringFromCGPoint(penController.ptConv)]];
            NSLog(@"%@", [NSString stringWithFormat:@"Move %f, %f", penController.ptConv.x, penController.ptConv.y]);
            break;
        case PEN_UP:
            //            [self addDebugText:[NSString stringWithFormat:@"Up %@", NSStringFromCGPoint(penController.ptConv)]];
            NSLog(@"%@", [NSString stringWithFormat:@"Up %f, %f", penController.ptConv.x, penController.ptConv.y]);
            //            [self addDebugText:@" "];
            break;
        default:
            break;
    }
}
@end
