//
//  PNFStrokePoint.h
//  MINTInteractive
//
//  Created by Jootae Kim on 10. 11. 30..
//  Copyright 2010 PNF/RnD Ceneter. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <Cocoa/Cocoa.h>

@interface PNFStrokePoint:NSObject {

	CGPoint		pt;
	float		press;
}

@property(readwrite) CGPoint pt;
@property(readwrite) float press;
@end
