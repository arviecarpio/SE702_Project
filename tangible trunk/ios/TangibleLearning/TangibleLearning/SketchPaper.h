//
//  SketchPaper.h
//  DraftTools705
//
//  Created by EC\dlin051 on 18/04/11.
//  Copyright 2011 University of Auckland. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PaintingView.h"

@class TangibleObject;

struct SketchPaperImpl;

@interface SketchPaper : PaintingView {
    int line;
    BOOL drawLine;
    int endLine;
    BOOL drawUsingTagPoint;
    BOOL freeSketch;
    struct SketchPaperImpl *_impl;
    NSUInteger _count;
    __unsafe_unretained UITouch *_trackedTouch;
    CGAffineTransform _trans;
    NSUInteger _enableButtonCount;
    NSInteger _measurement;
}

@property CGFloat penWidth;

@property (nonatomic, retain) UIImageView* enterPoint;
@property (nonatomic, retain) UIImageView* leavePoint;
@property (nonatomic, strong) TangibleObject *tangibleObject;
@property (nonatomic) BOOL drawUsingTagPoint;
@property (readonly) BOOL drawLine;
@property (readonly) BOOL enableButtons;
@property (strong, nonatomic) IBOutlet UILabel *measurementLabel;
@property (nonatomic) NSInteger _measurement;
@property (strong, nonatomic) IBOutlet UILabel *startLabel;
@property (strong, nonatomic) IBOutlet UILabel *endLabel;

-(CGPoint) closestPointOnEdge:(CGPoint)edge_1 Withedge:(CGPoint)edge_2 touchPoint:(CGPoint)touch onBounds:(BOOL *)b;
- (CGPoint)closestPointOnTriangle:(CGPoint[3])triangle point:(CGPoint)point;
- (CGPoint)closestPointOnSemicircle:(CGPoint[3])semicircle point:(CGPoint)point onBounds:(BOOL *)b;

- (void)undo;
- (void)clear;

- (void)saveToFile:(NSString *)filename;
- (void)loadFromFile:(NSString *)filename;

- (void)touchBegan:(UITouch *)touch beganPoint:(CGPoint)point event:(UIEvent *)event;

@end
