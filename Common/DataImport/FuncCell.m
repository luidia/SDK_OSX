//
//  BookCell.m
//  UltraNoteMac
//
//  Created by choi on 13. 8. 22..
//  Copyright (c) 2013년 choi. All rights reserved.
//

#import "FuncCell.h"

@interface FuncCell ()
{

}
@end

@implementation FuncCell

-(void) updateInfo:(NSString*)_item {
    [titleField setStringValue:_item];
}
@end
