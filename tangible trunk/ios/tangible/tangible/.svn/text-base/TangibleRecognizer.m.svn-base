//
//  TangibleRecognizer.m
//  tangible
//
//  Created by standarduser on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TangibleRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

static inline CGFloat length(CGPoint p1, CGPoint p2) {
    CGFloat x = p1.x - p2.x;
    CGFloat y = p1.y - p2.y;
    return sqrtf(x * x + y * y);
}

static inline BOOL isSame(CGFloat f1, CGFloat f2) {
    CGFloat dif = f1 - f2;
    return (dif < 10 && dif > -10);
}

@interface TangibleRecognizer ()

- (BOOL)isRuler:(CGFloat[3])lens;
- (BOOL)isProtractor:(CGFloat[3])lens;
- (BOOL)isSetsquare:(CGFloat[3])lens;

@end

@implementation TangibleRecognizer

@synthesize type = _type, p1 = _p1, p2 = _p2, p3 = _p3;

- (void)reset {
    [super reset];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.state != UIGestureRecognizerStatePossible)
        return;
    if ([[event allTouches] count] >= 3) {
        NSEnumerator *enumerator = [[event allTouches] objectEnumerator];
        UITouch *touch1 = [enumerator nextObject];
        UITouch *touch2 = [enumerator nextObject];
        UITouch *touch3 = [enumerator nextObject];
        //        for (UITouch *touch1 in touches) {
        //            for (UITouch *touch2 in touches) {
        //                for (UITouch *touch3 in touches) {
        //                    if (touch1 == touch2 || touch2 == touch3 || touch3 == touch1)
        //                        continue;
        CGPoint p1 = [touch1 locationInView:self.view];
        CGPoint p2 = [touch2 locationInView:self.view];
        CGPoint p3 = [touch3 locationInView:self.view];
        CGFloat len1 = length(p1, p2);
        CGFloat len2 = length(p2, p3);
        CGFloat len3 = length(p3, p1);
        CGFloat lens[] = {len1, len2, len3};
        qsort_b(lens, 3, sizeof(CGFloat), ^int(const void *l1, const void *l2) {
            float f1 = *(float *)l1;
            float f2 = *(float *)l2;
            return f1 < f2;
        });
        _p1 = p1;
        _p2 = p2;
        _p3 = p3;
        if ([self isRuler:lens]) {
            _type = kTangibleTypeRuler;
            NSLog(@"ruler");
        } else if ([self isProtractor:lens]) {
            _type = kTangibleTypeProtractor;
            NSLog(@"protractor");
        } else if ([self isSetsquare:lens]) {
            _type = kTangibleTypeSetsquare;
            NSLog(@"setsquare");
        } else {
            _type = kTangibleTypeInvalid;
        }
        self.state = UIGestureRecognizerStateRecognized;
        NSLog(@"%f %f %f", len1, len2, len3);
        //                }
        //            }
        //        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

- (BOOL)isRuler:(CGFloat[3])lens {
    if (isSame(lens[1], lens[2])|| isSame(lens[2], lens[0]) || isSame(lens[0], lens[1])) {
        if (lens[2] * 2 < lens[0])
            return YES;
    }
    return NO;
}

- (BOOL)isProtractor:(CGFloat[3])lens {
    return isSame(lens[1], lens[2]) && isSame(lens[2], lens[0]) && isSame(lens[0], lens[1]);
}

- (BOOL)isSetsquare:(CGFloat[3])lens {
    float angle = (lens[1] * lens[1] + lens[2] * lens[2] - lens[0] * lens[0]) / (2 * lens[1] * lens[2]);
    angle = acosf(angle);
    angle = angle / M_PI * 180;
    NSLog(@"angle: %f", angle);
    return (angle > 87 && angle < 93);
}   

@end
