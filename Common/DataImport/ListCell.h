//
//  BookCell.h
//  UltraNoteMac
//
//  Created by choi on 13. 8. 22..
//  Copyright (c) 2013년 choi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ListCellDelegate
-(void) downClickedCell:(NSIndexPath*)path;
-(void) delClickedCell:(NSIndexPath*)path;
@end

@interface ListCell : NSTableCellView
{
    id<ListCellDelegate> delegate;
    IBOutlet NSTextField *titleField;
    NSIndexPath* indexPath;
}
@property (nonatomic, assign) id delegate;
@property (retain) NSIndexPath* indexPath;

-(void) updateInfo:(NSString*)item indexPath:(NSIndexPath*)path;
@end
