//
//  BookCell.h
//  UltraNoteMac
//
//  Created by choi on 13. 8. 22..
//  Copyright (c) 2013년 choi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FuncCell : NSTableCellView
{
    IBOutlet NSTextField *titleField;
}
-(void) updateInfo:(NSString*)item;
@end
