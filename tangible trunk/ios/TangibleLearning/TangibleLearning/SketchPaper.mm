//
//  SketchPaper.m
//  DraftTools705
//
//  Created by EC\dlin051 on 18/04/11.
//  Copyright 2011 University of Auckland. All rights reserved.
//

#import "SketchPaper.h"
#import <QuartzCore/QuartzCore.h>
#import "TangibleObject.h"
#import "TangibleView.h"
#import "TRTouch.h"
#import "ViewController.h"

static inline CGFloat distanceBetweenPoints(CGPoint pt1, CGPoint pt2) {
    CGFloat dx = pt2.x - pt1.x;
    CGFloat dy = pt2.y - pt1.y;
    return sqrtf(dx*dx + dy*dy );
}

static CGFloat colors[][3] = {
    1, 1, 1,
    
#if 0 // change to 1 to make multi touch drawing colorful
    
    1, 0, 0,
    0, 1, 0,
    0, 0, 1,
    1, 1, 0,
    1, 0, 1,
    0, 1, 1,
#endif
};

const int colorCount = sizeof(colors)/sizeof(CGFloat[3]);

struct SketchPaperImpl {
    TRTouchSet set;
    std::map<TRIdentifier, TRIdentifier> map;
};

@interface SketchPaper ()

- (NSUInteger)identifierForTouch:(UITouch *)touch;
- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end forTouch:(UITouch *)touch;
- (void)redraw;

@end

@implementation SketchPaper

@synthesize penWidth,enterPoint,leavePoint, tangibleObject, drawUsingTagPoint, drawLine, enableButtons;
@synthesize measurementLabel;
@synthesize _measurement;

-(id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
        self.tag = 20;
        
        enterPoint=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"d.png"]];
        leavePoint=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"b.png"]];
        enterPoint.alpha=0.5;
        leavePoint.alpha=0.5;
        
        [self addSubview:enterPoint];
        [self addSubview:leavePoint];
        enterPoint.hidden=YES;
        leavePoint.hidden=YES;
        
        penWidth=5.0;
        self.multipleTouchEnabled = YES;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        drawUsingTagPoint = NO;
        freeSketch = NO;
        enableButtons = NO;
        
        _impl = new SketchPaperImpl;
        _count = 0;
        _enableButtonCount = 0;
        
        [self setUp];
        
        // add undo button
        UIButton *undo = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [undo setTitle:@"undo" forState:UIControlStateNormal];
        undo.frame = CGRectMake(frame.size.width - 80, 0, 80, 40);
        undo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [undo addTarget:self action:@selector(undo) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:undo];
        
        // add measurement label
        measurementLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        measurementLabel.text = [NSString stringWithFormat:@"%u cm", _measurement];
        measurementLabel.textAlignment =  UITextAlignmentCenter;
        [self addSubview:measurementLabel];
        
    }
    return self;
}

- (void)dealloc {
    delete _impl;
}

#pragma mark -

- (NSUInteger)identifierForTouch:(UITouch *)touch {
    TRIdentifier tid = _impl->map[TRIdentifierFromObject(touch)];
    if (tid == 0) {
        _impl->map[TRIdentifierFromObject(touch)] = ++_count;
        return _count;
    }
    return tid;
}

#pragma mark - touches

- (void)touchBegan:(UITouch *)touch beganPoint:(CGPoint)point event:(UIEvent *)event {
    self._measurement = 0;
    if (_trackedTouch == touch) {
        return;
    }
    drawLine = NO;
    if (_trackedTouch != nil) {
        [self touchesCancelled:[NSSet setWithObject:_trackedTouch] withEvent:event];
        return;
    }
    if (self.tangibleObject) {
        CGPoint currentPoint = point;
        CGPoint point[5];
        CGPoint pointOnLine;
        CGFloat dis, minDis = CGFLOAT_MAX;
        _trans = self.tangibleObject.trans;
        for (int i = 0; i < [self.tangibleObject.outlinePoints count]; i++) {
            point[i] = [[self.tangibleObject.outlinePoints objectAtIndex:i] CGPointValue];
            point[i] = CGPointApplyAffineTransform(point[i], _trans); 
        }
        
        if (self.tangibleObject.type == kTangibleTypeRuler) {    
            int start = 0;
            if (distanceBetweenPoints(point[0], point[1]) < distanceBetweenPoints(point[1], point[2]))
                start = 1;
            for (int i = start  ; i < 4; i+=2) {
                BOOL b;
                CGPoint p = [self closestPointOnEdge:point[i] Withedge:point[(i+1)%4] touchPoint:currentPoint onBounds:&b];
                if (!b)
                    continue;
                dis = distanceBetweenPoints(p, currentPoint);
                if (dis < minDis) {
                    minDis = dis;
                    pointOnLine = p; 
                    line = i;
                }
            }
            if (minDis < 45) { 
                if (drawUsingTagPoint) {
                    enterPoint.hidden = NO;
                    enterPoint.center = pointOnLine; 
                } else {
                    self.previousLocation = pointOnLine; 
                }
                drawLine = YES;
            }
        } else if (self.tangibleObject.type == kTangibleTypeSetsquare) {
            for (int i = 0; i < 3; i++) {
                BOOL b;
                CGPoint p = [self closestPointOnEdge:point[i] Withedge:point[(i+1)%3] touchPoint:currentPoint onBounds:&b];
                if (!b)
                    continue;
                dis = distanceBetweenPoints(p, currentPoint);
                if (dis < minDis) {
                    minDis = dis;
                    pointOnLine = p;
                    line = i;
                }
            }
            if (minDis < 45) { 
                if (drawUsingTagPoint) {
                    enterPoint.hidden = NO;
                    enterPoint.center = pointOnLine;
                } else {
                    self.previousLocation = pointOnLine;
                }
                drawLine = YES;
            }
        } else if (self.tangibleObject.type == kTangibleTypeProtractor){
            BOOL b;
            CGPoint p = [self closestPointOnSemicircle:point point:currentPoint onBounds:&b];
            if (b && distanceBetweenPoints(p, currentPoint) < 100) {
                drawLine = YES;
                self.previousLocation = p; 
            }
        }
        
        if (drawLine) {
            _trackedTouch = touch;
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    drawLine = NO;
    if (_trackedTouch != nil) {
        [self touchesCancelled:[event allTouches] withEvent:event];
        return;
    }
    UITouch *touch = [touches anyObject];
    if ([touches count] == 1)
        [self touchBegan:touch beganPoint:[touch locationInView:self] event:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (drawLine && self.tangibleObject && [touches containsObject:_trackedTouch]) {
        UITouch *touch = _trackedTouch;	
        CGPoint currentPoint = [touch locationInView:self];
        CGPoint point[5];
        CGPoint p;
        for (int i = 0; i < [self.tangibleObject.outlinePoints count]; i++) {
            point[i] = [[self.tangibleObject.outlinePoints objectAtIndex:i] CGPointValue];
            point[i] = CGPointApplyAffineTransform(point[i], _trans);
        }
        if (self.tangibleObject.type == kTangibleTypeRuler) {
            p = [self closestPointOnEdge:point[line] Withedge:point[(line+1)%4] touchPoint:currentPoint onBounds:NULL];
            if (drawUsingTagPoint) {
                leavePoint.hidden = NO;
                leavePoint.center = p;
            } else {
                [self renderLineFromPoint:self.previousLocation toPoint:p forTouch:touch];
                self.previousLocation = p; 
            }
        } else if (self.tangibleObject.type == kTangibleTypeSetsquare) {
            if (drawUsingTagPoint) {
                p = [self closestPointOnTriangle:point point:currentPoint];
            } else {
                BOOL onbounds = NO;
                CGPoint p1 = [self closestPointOnEdge:point[line] Withedge:point[(line+1)%3] touchPoint:currentPoint onBounds:&onbounds];
                if (onbounds) {
                    p = p1;
                    [self renderLineFromPoint:self.previousLocation toPoint:p forTouch:touch];
                    self.previousLocation = p; 
                } else {
                    CGFloat dis = distanceBetweenPoints(p1, point[line]);
                    CGFloat dis2 = distanceBetweenPoints(p1, point[(line+1)%3]);
                    if (dis > dis2) {
                        p = point[(line+1)%3];
                        line = (line+1)%3;
                    } else {
                        p = point[line];
                        line = (line+2)%3;
                    }
                    self.previousLocation = p;
                }
            }
        } else if (self.tangibleObject.type == kTangibleTypeProtractor) {
            BOOL b;
            p = [self closestPointOnSemicircle:point point:currentPoint onBounds:&b];
            if (!b) {
                return;
            }
            if (distanceBetweenPoints(self.previousLocation, p) < 50) {
                [self renderLineFromPoint:self.previousLocation toPoint:p forTouch:touch];  // TODO render arc
            }
            self.previousLocation = p;
        }
        
        
    }
    
    if (freeSketch) {
        int i = 0;
        for (UITouch *touch in touches) {
            if (touch == _trackedTouch)
                continue;
            CGPoint currentPoint = [touch locationInView:self];
            CGPoint prevPoint = [touch previousLocationInView:self];
            int idx = i++ % colorCount;
            [self setBrushColorWithRed:colors[idx][0] green:colors[idx][1] blue:colors[idx][2]];
            [self renderLineFromPoint:prevPoint toPoint:currentPoint forTouch:touch];
        }
    }
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"sketch cancelled");
    for (UITouch *touch in touches) {
        _impl->set.removeTouch([self identifierForTouch:touch]);
        _impl->map[TRIdentifierFromObject(touch)] = 0;
    }
    [self redraw];
    if ([touches containsObject:_trackedTouch]) {
        _trackedTouch = nil;
        drawLine = NO;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([touches count] == 2) {
        UITouch *touch = [touches anyObject];
        if (touch.tapCount == 5) {
            freeSketch = !freeSketch;
        }
    }
    
    if (drawLine && self.tangibleObject && [touches containsObject:_trackedTouch]) {
        if (drawUsingTagPoint && !self.leavePoint.hidden) {
            if (self.tangibleObject.type == kTangibleTypeRuler) {
                [self renderLineFromPoint:self.enterPoint.center toPoint:self.leavePoint.center forTouch:_trackedTouch]; 
            } else if (self.tangibleObject.type == kTangibleTypeSetsquare) {
                if (line == endLine) {
                    [self renderLineFromPoint:self.enterPoint.center toPoint:self.leavePoint.center forTouch:_trackedTouch]; 
                }
                else {
                    CGPoint point[3];
                    for (int i = 0; i < [self.tangibleObject.outlinePoints count]; i++) {
                        point[i] = [[self.tangibleObject.outlinePoints objectAtIndex:i] CGPointValue];
                        point[i] = CGPointApplyAffineTransform(point[i], _trans);
                    }
                    CGPoint midPoint;
                    if ((line+1)%3==endLine) {
                        midPoint = point[endLine];
                    } else {
                        midPoint = point[line];
                    }
                    [self renderLineFromPoint:self.enterPoint.center toPoint:midPoint forTouch:_trackedTouch]; 
                    [self renderLineFromPoint:midPoint toPoint:self.leavePoint.center forTouch:_trackedTouch]; 
                }
                
            }
        }
        self.enterPoint.hidden = YES;
        self.leavePoint.hidden = YES;
    } else if (freeSketch) {
        int i = 0;
        for (UITouch *touch in touches) {
            CGPoint currentPoint = [touch locationInView:self];
            CGPoint prevPoint = [touch previousLocationInView:self];
            int idx = i++ % colorCount;
            [self setBrushColorWithRed:colors[idx][0] green:colors[idx][1] blue:colors[idx][2]];
            [self renderLineFromPoint:prevPoint toPoint:currentPoint forTouch:touch]; 
        }
    }
    
    for (UITouch *touch in touches) {
        _impl->map[TRIdentifierFromObject(touch)] = 0;
    }
    if (_trackedTouch && [touches containsObject:_trackedTouch]) {
        _trackedTouch = nil;
        drawLine = NO;
    }
}

- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end forTouch:(UITouch *)touch {
    CGRect bounds = self.bounds;
    start.y = bounds.size.height - start.y;
    end.y = bounds.size.height - end.y;
    double diffx = end.x - start.x;
    double diffy = end.y - start.y;
    [self renderLineFromPoint:start toPoint:end];
    if (touch) {
        NSUInteger oldcount = _count;
        TRIdentifier tid = [self identifierForTouch:touch];
        if (tid == _count && tid != oldcount)
            _impl->set.addPoint(tid, start);
        _impl->set.addPoint(tid, end);
        // added measurement feature
        _measurement += sqrt(pow(diffx, 2) + pow(diffy, 2))*0.1924*0.1; //measurement is in cm
        self.measurementLabel.text = [NSString stringWithFormat:@"%4f cm", _measurement];
    }
}

- (void)redraw {
    [self eraseNoUpdate];
    const std::map<TRIdentifier, TRTouch> &touches = _impl->set.getTouches();
    std::map<TRIdentifier, TRTouch>::const_iterator it;
    for (it = touches.begin(); it != touches.end(); it++) {
        const std::vector<TRPoint> &path = it->second.getHistory();
        std::vector<TRPoint>::const_iterator it2;
        it2 = path.begin();
        CGPoint p1 = *it2;
        CGPoint p2;
        for (it2++; it2 != path.end(); it2++) {
            p2 = *it2;
            [self renderLineFromPointNoUpdate:p1 toPoint:p2];
            p1 = p2;
        }
    }
    [self updateView];
}

- (void)undo {
    while (_count != 0 && !_impl->set.removeTouch(_count--));
    [self redraw];
    if (_count == 0) {
        _enableButtonCount++;
        if (_enableButtonCount > 5) {
            enableButtons = YES;
        }
    }
    
}

- (void)clear {
    _impl->set = TRTouchSet();
    [self erase];
    [(TangibleView *)[[self superview] viewWithTag:kTangibleViewTag] setObj:nil];
    self.tangibleObject = nil;
}

- (void)saveToFile:(NSString *)filename {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:filename];
    
    NSMutableArray *array = [NSMutableArray array];
    const std::map<TRIdentifier, TRTouch> &touches = _impl->set.getTouches();
    std::map<TRIdentifier, TRTouch>::const_iterator it;
    for (it = touches.begin(); it != touches.end(); it++) {
        NSMutableArray *pathArray = [NSMutableArray arrayWithCapacity:20];
        const std::vector<TRPoint> &path = it->second.getHistory();
        std::vector<TRPoint>::const_iterator it2;
        it2 = path.begin();
        CGPoint p2;
        for (it2 = path.begin(); it2 != path.end(); it2++) {
            p2 = *it2; 
            [pathArray addObject:NSStringFromCGPoint(p2)];
        }
        [array addObject:pathArray];
    }
    BOOL done = [array writeToFile:plistPath atomically:YES];   
    if (!done)
        [[[UIAlertView alloc] initWithTitle:@"fail" message:@"to save" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
}

- (void)loadFromFile:(NSString *)filename {
    _impl->set = TRTouchSet();
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:filename];
    NSArray *array = [NSArray arrayWithContentsOfFile:plistPath];
    for (NSArray *pathArray in array) {
        for (NSString *value in pathArray) {
            CGPoint p = CGPointFromString(value);
            _impl->set.addPoint(_count, p);
        }
        _count++;
    }
    [self erase];
    const std::map<TRIdentifier, TRTouch> &touches = _impl->set.getTouches();
    std::map<TRIdentifier, TRTouch>::const_iterator it;
    for (it = touches.begin(); it != touches.end(); it++) {
        const std::vector<TRPoint> &path = it->second.getHistory();
        std::vector<TRPoint>::const_iterator it2;
        it2 = path.begin();
        CGPoint p1 = *it2;
        CGPoint p2;
        for (it2++; it2 != path.end(); it2++) {
            p2 = *it2;
            [self renderLineFromPoint:p1 toPoint:p2];
            p1 = p2;
        }
    }
}

#pragma mark - MATH calculation behind


-(CGPoint) closestPointOnEdge:(CGPoint)edge_1 Withedge:(CGPoint)edge_2 touchPoint:(CGPoint)touch onBounds:(BOOL *)b {
    
    CGFloat dx = edge_2.x - edge_1.x;
    CGFloat dy = edge_2.y - edge_1.y;
    CGFloat u =((touch.x-edge_1.x)*dx+(touch.y-edge_1.y)*dy)/(dx*dx+dy*dy);
    
    CGPoint closestPoint;
    
    closestPoint.x=edge_1.x+u*dx;
    closestPoint.y=edge_1.y+u*dy;
    if (b) {
        *b = u > 0 && u < 1;
    }
    return closestPoint;
}

- (CGPoint)closestPointOnTriangle:(CGPoint[3])triangle point:(CGPoint)point {
    CGPoint ret = point;
    CGFloat minDis = CGFLOAT_MAX;
    for (int i = 0; i < 3; i++) {
        BOOL online = NO;
        CGPoint p = [self closestPointOnEdge:triangle[i] Withedge:triangle[(i+1)%3] touchPoint:point onBounds:&online];
        if (online) {
            CGFloat dis = distanceBetweenPoints(point, p);
            if (dis < minDis) {
                minDis = dis;
                ret = p;
                endLine = i;
            }
        }
    }
    return ret;
}

- (CGPoint)closestPointOnSemicircle:(CGPoint[3])semicircle point:(CGPoint)point onBounds:(BOOL *)b {
    CGPoint ret;
    //    BOOL online;
    BOOL onside = YES;
    CGFloat dx, dy;
    CGPoint center;
    center.x = (semicircle[0].x + semicircle[1].x) / 2;
    center.y = (semicircle[0].y + semicircle[1].y) / 2;
    
    CGFloat r = distanceBetweenPoints(semicircle[0], semicircle[1]) / 2;
    CGFloat d1 = distanceBetweenPoints(center, semicircle[2]);
    
    if (d1 != r) {
        dx = center.x - semicircle[2].x;
        dy = center.y - semicircle[2].y;
        dx *= r/d1 - 1;
        dy *= r/d1 - 1;
        center.x += dx;
        center.y += dy;
        semicircle[0].x += dx;
        semicircle[0].y += dy;
        semicircle[1].x += dx;
        semicircle[1].y += dy;
    }
    
    dx = semicircle[2].x - center.x;
    dy = semicircle[2].y - center.y;
    CGFloat angle = atan2f(dy, dx);
    dx = point.x - center.x;
    dy = point.y - center.y;
    CGFloat angle2 = atan2f(dy, dx);
    CGFloat angleDiff = angle2 - angle;
    
    while (angleDiff > 2 * M_PI) {
        angleDiff -= 2 * M_PI;
    }
    while (angleDiff < 0) {
        angleDiff += 2 * M_PI;
    }
//    NSLog(@"angle: %f, angle2: %f, angle diff: %f", angle, angle2, angleDiff);
    if (angleDiff > M_PI_2 && angleDiff < M_PI+M_PI_2) {
        onside = NO;
    }
    
    CGFloat dis = distanceBetweenPoints(center, point);
    
    if (b)
        *b = onside;
    
    dx *= r/dis;
    dy *= r/dis;
    
    ret.x = center.x + dx;
    ret.y = center.y + dy;
    
    return ret;
}

@end
















