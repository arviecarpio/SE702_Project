//
//  ViewController.h
//  TangibleLearning
//
//  Created by standarduser on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
enum {
    kRulerMode,
    kSetSquareMode,
    kProtractorMode,
    kCircleMode,
    kTriangleMode
};

enum {
    kTangibleViewTag = 10,
    kRecordButtonTag = 11,
    kClearButtonTag = 12,
};

@class TangibleView, TangibleRecognizer, SketchPaper, TangibleObject;

@interface ViewController : UIViewController <UIGestureRecognizerDelegate> {
    NSInteger _mode;
    BOOL showArrowKeys;
    NSInteger _posButtonIndex;
    NSArray *_touchesArray;
    TangibleView *_tangibleView;
    SketchPaper *_sketchView;
    TangibleRecognizer *_recognizer;
}

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *positionButton;
@property (strong, nonatomic) IBOutlet UILabel *instructionLabel;
@property (strong, nonatomic) IBOutlet UILabel *measurementLabel;
@property (strong, nonatomic) IBOutlet UIButton *_arrowButton;
@property (nonatomic) NSInteger _measurement;


+ (ViewController *)sharedController;

- (IBAction)rulerPressed;
- (IBAction)setSquarePressed;
- (IBAction)protractorPressed;
- (IBAction)circlePressed;
- (IBAction)trianglePressed;
- (IBAction)arrowKeyPressed;
- (IBAction)clearPressed;
- (IBAction)showRecord:(id)sender;

- (void)addTangibleObject:(TangibleObject *)tobj;

@end
