//
//  TimeTestWindowController.m
//  PenTestOSX
//
//  Created by choi on 14. 3. 21..
//  Copyright (c) 2014년 choi. All rights reserved.
//

#import "TimeTestWindowController.h"

@interface TimeTestWindowController ()
{
    IBOutlet NSTextField *startTimeField;
    IBOutlet NSTextField *endTimeField;
    IBOutlet NSTextField *durTimeField;
}
@end

@implementation TimeTestWindowController
@synthesize delegate;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        delegate = nil;
    }
    return self;
}
- (BOOL)windowShouldClose:(NSWindow *)sender {
    if (delegate) {
        if (delegate)
        {
            if ([self.delegate respondsToSelector:@selector(closeTimeTestWindowController)])
                [delegate closeTimeTestWindowController];
        }
    }
    return YES;
}
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
-(void) PenHandlerEnv:(NSArray*)info {
    //    NSLog(@"-(void) PenHandlerEnv:(NSArray*)info");
    //    [self calcTime];
}
-(void) PenHandler:(id) sender {
    //    NSLog(@"-(void) PenHandler:(id) sender");
    [self calcTime];
}
-(void) calcTime {
    if ([startTimeField.stringValue isEqualToString:@""]) {
        endTimeField.stringValue = @"";
        durTimeField.stringValue = @"";
        return;
    }
    NSDateFormatter* today = [[[NSDateFormatter alloc] init] autorelease];
    [today setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    [endTimeField setStringValue:[today stringFromDate:[NSDate date]]];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSDate *date1 = [dateFormatter dateFromString:startTimeField.stringValue];
    NSDate *date2 = [dateFormatter dateFromString:[today stringFromDate:[NSDate date]]];
    
    NSTimeInterval diff = [date2 timeIntervalSinceDate:date1];
    NSInteger ti = (NSInteger)diff;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    [durTimeField setStringValue:[NSString stringWithFormat:@"%02i:%02i:%02i", (int)hours, (int)minutes, (int)seconds]];
}
-(void) SetPenController:(PNFPenController *) pController
{
    penController = pController;
}

- (IBAction)startClicked:(id)sender {
    [startTimeField setStringValue:@""];
    [endTimeField setStringValue:@""];
    [durTimeField setStringValue:@""];
    
    NSDateFormatter* startTime = [[[NSDateFormatter alloc] init] autorelease];
    [startTime setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    [startTimeField setStringValue:[startTime stringFromDate:[NSDate date]]];
}

@end
