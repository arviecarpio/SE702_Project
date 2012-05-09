//
//  LearningView.m
//  TangibleLearning
//
//  Created by standarduser on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LearningView.h"

@implementation LearningView

@synthesize top = _top, bottom = _bottom, left = _left, right = _right, touchPointArray = _touchPointArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    
    CGFloat width, height;
    width = self.bounds.size.width;
    height = self.bounds.size.height;
    
    CGFloat points[] = {
        0, _top,
        width, _top,
        0, _bottom,
        width, _bottom,
        _left, 0,
        _left, height,
        _right, 0,
        _right, height,
    };
    
    int i = 0;
    CGContextMoveToPoint(context, points[i++], points[i++]);
    CGContextAddLineToPoint(context, points[i++], points[i++]);
    CGContextMoveToPoint(context, points[i++], points[i++]);
    CGContextAddLineToPoint(context, points[i++], points[i++]);
    CGContextMoveToPoint(context, points[i++], points[i++]);
    CGContextAddLineToPoint(context, points[i++], points[i++]);
    CGContextMoveToPoint(context, points[i++], points[i++]);
    CGContextAddLineToPoint(context, points[i++], points[i++]);
    
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 3);
    [[UIColor blackColor] setStroke];
    CGContextStrokePath(context);
}

#pragma mark - touch event handler

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([[event allTouches] count] < 1)
        return;
    CGPoint pt;
    if (!_touchPointArray)
        _touchPointArray = [NSMutableArray array];
    else
        [_touchPointArray removeAllObjects];
    for (UITouch *touchPt in [event allTouches]) {
        pt = [touchPt locationInView:self];
        NSValue *value = [NSValue valueWithCGPoint:pt];
        [_touchPointArray addObject:value];
    }
    NSLog(@"Number of touches %d", [_touchPointArray count]);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // handle pan gesture
    if ([touches count] == 1) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGPoint prevPoint = [touch previousLocationInView:self];
        
        const float diff = 10;
        if (abs(prevPoint.x - _left) < diff) {
            _left = point.x;
        } else if (abs(prevPoint.x - _right) < diff) {
            _right = point.x;
        } else if (abs(prevPoint.y - _top) < diff) {
            _top = point.y;
        } else if (abs(prevPoint.y - _bottom) < diff) {
            _bottom = point.y;
        } else {

        }
        
        [self setNeedsDisplay];
    }
    else if ([[event allTouches] count] > 1) {
        [_touchPointArray removeAllObjects];
        for (UITouch *touchPt in [event allTouches]) {
            CGPoint pt;
            pt = [touchPt locationInView:self];
            NSValue *value = [NSValue valueWithCGPoint:pt];
            [_touchPointArray addObject:value];
        }
    }
    NSLog(@"Number of touches moved %d", [_touchPointArray count]);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

@end
