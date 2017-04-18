//
//  BookCell.m
//  UltraNoteMac
//
//  Created by choi on 13. 8. 22..
//  Copyright (c) 2013년 choi. All rights reserved.
//

#import "ListCell.h"

@interface ListCell ()
{
    
}
@end

@implementation ListCell
@synthesize indexPath;
@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        delegate = nil;
    }
    return self;
}

-(void) updateInfo:(NSString*)item indexPath:(NSIndexPath*)path {
    self.indexPath = path;
    [titleField setStringValue:item];
}
- (IBAction)downClicked:(id)sender {
    if (delegate) {
        if ([self.delegate respondsToSelector:@selector(downClickedCell:)]) {
            [self.delegate downClickedCell:self.indexPath];
        }
    }
}
- (IBAction)delClicked:(id)sender {
    if (delegate) {
        if ([self.delegate respondsToSelector:@selector(delClickedCell:)]) {
            [self.delegate delClickedCell:self.indexPath];
        }
    }
}
@end
