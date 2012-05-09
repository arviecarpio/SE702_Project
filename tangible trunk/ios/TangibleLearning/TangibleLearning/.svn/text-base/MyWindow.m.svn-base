//
//  MyWindow.m
//  TangibleLearning
//
//  Created by standarduser on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyWindow.h"
#import "SketchPaper.h"

@implementation MyWindow

- (void)sendEvent:(UIEvent *)event {
    if (event.type == UIEventTypeTouches) {
        NSSet *touches = [event touchesForWindow:self];
//        NSMutableString *str = [NSMutableString stringWithFormat:@"%d ", [touches count]];
        for (UITouch *touch in touches) {
            UIView *view = [self hitTest:[touch locationInView:self] withEvent:event];
//            [str appendFormat:@"%@ ", [view class]];
            if ([forwardTouches containsObject:touch]) {     // manual handle touch event send for forward touch
                NSSet *set = [NSSet setWithObject:touch];
                switch (touch.phase) {
                    case UITouchPhaseBegan:
                        [view touchesBegan:set withEvent:event];
                        break;
                    case UITouchPhaseMoved:
                        [view touchesMoved:set withEvent:event];
                        break;
                    case UITouchPhaseCancelled:
                        [view touchesCancelled:set withEvent:event];
                        [forwardTouches removeObject:touch];
                        break;
                    case UITouchPhaseEnded:
                        [view touchesEnded:set withEvent:event];
                        [forwardTouches removeObject:touch];
                        break;
                    default:
                        break;
                }
            }
        }
//        NSLog(@"%@", str);
    }
    [super sendEvent:event];
}

- (void)forwardTouch:(UITouch *)touch beginPoint:(CGPoint)point event:(UIEvent *)event {
    if (!forwardTouches) {
        forwardTouches = [NSMutableSet set];
    }
    [forwardTouches addObject:touch];
    UIView *view = [self viewWithTag:20];
    [(SketchPaper *)view touchBegan:touch beganPoint:point event:nil];
//    [view touchesBegan:[NSSet setWithObject:touch] withEvent:nil];
}

@end
