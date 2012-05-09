//
//  TangibleView.m
//  TangibleLearning
//
//  Created by standarduser on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TangibleView.h"

#import "TangibleObject.h"

@implementation TangibleView

@synthesize trans = _trans, obj = _obj;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    NSArray *points = _obj.outlinePoints;
    if ([points count] < 2)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    [[UIColor clearColor] setFill];
    CGContextFillRect(context, rect);
    
    //    CGContextTranslateCTM(context, self.bounds.size.width/2, self.bounds.size.height/2);
    float angle = atan2(_trans.b, _trans.a);
    CGContextTranslateCTM(context, _trans.tx, _trans.ty);
    CGContextRotateCTM(context, angle);
    //    CGContextTranslateCTM(context, -self.bounds.size.width/2, -self.bounds.size.height/2);
    
    
    CGContextBeginPath(context);
    
    switch (_obj.type) {
        case kTangibleTypeRuler:
        case kTangibleTypeSetsquare:
        case kTangibleTypeTriangle:
        {
            NSEnumerator *enumerator = [points objectEnumerator];
            
            CGPoint point = [[enumerator nextObject] CGPointValue];
            CGContextMoveToPoint(context, point.x, point.y);
            NSValue *value = nil;
            while (value = [enumerator nextObject]) {
                point = [value CGPointValue];
                CGContextAddLineToPoint(context, point.x, point.y);
            }
        }
            break;
        case kTangibleTypeProtractor:
        {
            CGPoint p1, p2, p3, p4, p5;
            p1 = [[points objectAtIndex:0] CGPointValue];
            p2 = [[points objectAtIndex:1] CGPointValue];
            p3 = [[points objectAtIndex:2] CGPointValue];
            p4 = [[points objectAtIndex:3] CGPointValue];
            p5 = [[points objectAtIndex:4] CGPointValue];
            CGContextMoveToPoint(context, p1.x, p1.y);
            CGContextAddLineToPoint(context, p2.x, p2.y);
            float x = p1.x - p2.x;
            float y = p1.y - p2.y;
            float dis = sqrtf(x*x+y*y);
            CGContextAddArcToPoint(context, p5.x, p5.y, p3.x, p3.y, dis/2);
            CGContextAddArcToPoint(context, p4.x, p4.y, p1.x, p1.y, dis/2);
        }
            break;
        case kTangibleTypeCircle:
        {
            NSEnumerator *enumerator = [points objectEnumerator];
            CGPoint midPoint = [[enumerator nextObject] CGPointValue];
            CGPoint leftPoint = [[enumerator nextObject] CGPointValue];
            CGPoint rightPoint = [[enumerator nextObject] CGPointValue];
            CGFloat radius = midPoint.x - leftPoint.x;
            CGContextMoveToPoint(context, midPoint.x, midPoint.y);
            CGContextAddArc(context, midPoint.x, midPoint.y, radius, 0, 2 * M_PI, YES);
            CGContextAddArc(context, midPoint.x, midPoint.y, radius/4, 0, 2 * M_PI, YES);
            CGContextMoveToPoint(context, leftPoint.x, leftPoint.y);
            CGContextAddLineToPoint(context, rightPoint.x, rightPoint.y);
            
        }      
            break;
    }
    
    
    CGContextClosePath(context);
    
    [[UIColor blueColor] setStroke];
    CGContextSetLineWidth(context, 3);
    CGContextStrokePath(context);
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"began %d/%d", [touches count], [[event allTouches] count]);
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"moved %d/%d", [touches count], [[event allTouches] count]);    
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"ended %d/%d", [touches count], [[event allTouches] count]);
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"cancelled %d/%d", [touches count], [[event allTouches] count]);
//}

- (void)setObj:(TangibleObject *)obj {
    _obj = obj;
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
    
}

@end
