//
//  RRRecognizerView.m
//  RulerRecognizer
//
//  Created by standarduser on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TriangleView.h"

//const CGFloat LENGTH[] = {615, 93, 622};

@implementation TriangleView

@synthesize p1 = _p1, p2 = _p2, p3 = _p3;

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, _p1.x, _p1.y);
    CGContextAddLineToPoint(context, _p2.x, _p2.y);
    CGContextAddLineToPoint(context, _p3.x, _p3.y);
    CGContextClosePath(context);
    
    [[UIColor blackColor] setStroke];
    CGContextSetLineWidth(context, 10);
    CGContextStrokePath(context);
    
}

@end
