//
//  TangibleRecognizer.m
//  tangible
//
//  Created by standarduser on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TangibleRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>
#import "ViewController.h"
#import "TangibleObject.h"
#import "MyWindow.h"

#import "TRRecognizer.h"

@interface TangibleRecognizer ()

- (void)updateStateForTouches:(NSSet *)touches event:(UIEvent *)event;

@end

@implementation TangibleRecognizer
@synthesize tangibleArray = _tangibleArray;
@synthesize recognizedObject = _recognizedObject, transform = _transform;

- (id)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        _recognizer = new TRRecognizer();
        _beginLocation = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return self;
}

- (void)dealloc {
    delete _recognizer;
}

#pragma mark -

- (void)setTangibleArray:(NSArray *)tangibleArray {
    _tangibleArray = tangibleArray;
    _recognizer->removeAllTangibles();
    for (TangibleObject *obj in _tangibleArray) {
        _recognizer->addTangibleObject(TRTangibleObject(TRIdentifierFromObject(obj), TRGraph(obj.points)));
    }
    self.state = UIGestureRecognizerStateFailed;
}

#pragma mark -

- (void)reset {
    [super reset];
    NSLog(@"reset");
    _recognizedObject = nil;
    _recognizer->reset();
    [_beginLocation removeAllObjects];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if ([_tangibleArray count] == 0) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    // store the began location for later use
    for (UITouch *touch in touches) {
        [_beginLocation setObject:[NSValue valueWithCGPoint:[touch locationInView:self.view]] forKey:[NSValue valueWithNonretainedObject:touch]];
    }
    _recognizer->touchesBegan(touches, self.view);
    [self updateStateForTouches:touches event:event];
    if ([[event allTouches] count] > 1) {
        [self.view touchesCancelled:[event allTouches] withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    _recognizer->touchesMoved(touches, self.view);
    [self updateStateForTouches:touches event:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    _recognizer->touchesEnded(touches, self.view);
    [self updateStateForTouches:touches event:event];
    for (UITouch *touch in touches) {
        [_beginLocation removeObjectForKey:[NSValue valueWithNonretainedObject:touch]];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    _recognizer->touchesEnded(touches, self.view);
    [self updateStateForTouches:touches event:event];
    for (UITouch *touch in touches) {
        [_beginLocation removeObjectForKey:[NSValue valueWithNonretainedObject:touch]];
    }
}

//- (void)setState:(UIGestureRecognizerState)state {
//    [super setState:state];
//    switch (state) {
//        case UIGestureRecognizerStateBegan:
//            NSLog(@"began");
//            break;
//        case UIGestureRecognizerStateChanged:
//            NSLog(@"changed");
//            break;
//        case UIGestureRecognizerStateCancelled:
//            NSLog(@"cancelled");
//            break;
//        case UIGestureRecognizerStateFailed:
//            NSLog(@"failed");
//            break;
//        case UIGestureRecognizerStateEnded:
//            NSLog(@"ended");
//            break;
//        case UIGestureRecognizerStatePossible:
//            NSLog(@"possible");
//            break;
//        default:
//            break;
//    }
//}

- (void)updateStateForTouches:(NSSet *)touches event:(UIEvent *)event {
    if (_recognizer->getTouches().getTouches().size() == 0) {
        if (self.state == UIGestureRecognizerStatePossible)
            self.state = UIGestureRecognizerStateFailed;
        else
            self.state = UIGestureRecognizerStateEnded;
        return;
    }
    std::set<TRIdentifier> ignoredTouches = _recognizer->getIgnoredTouches();
    for (UITouch *touch in touches) {
        if (ignoredTouches.find(TRIdentifierFromObject(touch)) != ignoredTouches.end()) {
            [self ignoreTouch:touch forEvent:event];
            MyWindow *window = (id)touch.window;
            id key = [NSValue valueWithNonretainedObject:touch];
            NSValue *value = [_beginLocation objectForKey:key];
            [window forwardTouch:touch beginPoint:[value CGPointValue] event:event];    // MyWindow will dispatch touch event in the behave we want
            NSLog(@"ignore touch %p", touch);
            [_beginLocation removeObjectForKey:key];
        }
    }
    _recognizedObject = nil;
    std::vector<TRIdentifier> tid = _recognizer->getRecognizedObject();
    std::vector<TRIdentifier>::const_iterator it;
    for (it = tid.begin(); it != tid.end(); it++) {
        TRIdentifier objid = *it;
        TangibleObject *obj = (__bridge TangibleObject *)(void *)objid;
        const TRTangibleObject &trobj = _recognizer->getTangibleObjectForId(objid);
        [obj updateTransformation:&trobj];
        _transform = obj.trans;
        _recognizedObject = obj;
    }
    if (_recognizedObject) {
        if (self.state == UIGestureRecognizerStatePossible)
            self.state = UIGestureRecognizerStateBegan;
        else
            self.state = UIGestureRecognizerStateChanged;
    }
}

@end
