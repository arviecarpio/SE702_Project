//
//  ViewController.m
//  TangibleLearning
//
//  Created by standarduser on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "LearningView.h"
#import "TangibleObject.h"
#import "TangibleView.h"
#import "TangibleRecognizer.h"
#import "SketchPaper.h"
#import "RecordViewController.h"

static ViewController *sharedController;
static NSMutableArray *tangibles;

@interface ViewController ()

- (NSArray *)touchesArray;

@end

@implementation ViewController
@synthesize labels;
@synthesize positionButton;
@synthesize instructionLabel;
@synthesize measurementLabel;
@synthesize _measurement;
@synthesize _arrowButton;

+ (void)initialize {
    tangibles = [[NSMutableArray alloc] init];
    
}

+ (ViewController *)sharedController {
    return sharedController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    const int gap = 80;
    LearningView *view = (id)self.view;
    view.top = gap;
    view.bottom = gap * 5;
    view.left = gap;
    view.right = gap * 5;
    sharedController = self;
    
    // create tangible view
    _tangibleView = [[TangibleView alloc] initWithFrame:self.view.bounds];
    _tangibleView.backgroundColor = [UIColor clearColor];
    [view addSubview:_tangibleView];
    _tangibleView.userInteractionEnabled = NO;
    _tangibleView.tag = kTangibleViewTag;
    _tangibleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // create tangible recognzier 
    _recognizer = [[TangibleRecognizer alloc] initWithTarget:self action:@selector(handleTangible:)];
    [view addGestureRecognizer:_recognizer];
    _recognizer.tangibleArray = tangibles;
    _recognizer.delegate = self;
}

- (void)viewDidUnload
{
    [self setLabels:nil];
    [self setPositionButton:nil];
    [self setInstructionLabel:nil];
    [self setMeasurementLabel:nil];
    [self set_arrowButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    sharedController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _tangibleView.frame = self.view.bounds;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (NSArray *)touchesArray {
    LearningView *view = (id)self.view;
    NSArray *pointArr = [view.touchPointArray copy];
    NSLog(@"%@", pointArr);
    self.instructionLabel.text = [NSString stringWithFormat:@"%@ [touches: %u]", self.instructionLabel.text, [pointArr count]];
    self.measurementLabel.text = [NSString stringWithFormat:@"%@ [measurement: %u]", self.measurementLabel.text, _measurement];
    return pointArr;
}

- (void)addTangibleObject:(TangibleObject *)tobj {
    [tangibles addObject:tobj];
    _recognizer.tangibleArray = tangibles;
}

#pragma mark - IBAction

- (IBAction)rulerPressed {
    _mode = kRulerMode;
    
    LearningView *view = (id)self.view;
    CGPoint points[] = {
        view.left, view.top,
        view.right, view.top,
        view.right, view.bottom,
        view.left, view.bottom,
    };
    NSMutableArray *outlines = [NSMutableArray arrayWithCapacity:4];
    NSValue *value;
    for (int i = 0; i < 4; i++) {
        value = [NSValue valueWithCGPoint:points[i]];
        [outlines addObject:value];
    }
    NSArray *pointArr = [self touchesArray];
    TangibleObject *obj = [[TangibleObject alloc] initWithType:kTangibleTypeRuler points:pointArr outlinePoints:outlines];
    [self addTangibleObject:obj];
    
}
- (IBAction)positionButtonPressed:(id)sender {
    _posButtonIndex = [self.positionButton indexOfObject:sender];
    LearningView *view = (id)self.view;
    NSMutableArray *outlines = [NSMutableArray arrayWithCapacity:4];
    TangibleType type = kTangibleTypeRuler;
    if (_mode == kSetSquareMode) {
        type = kTangibleTypeSetsquare;
        CGPoint points[] = {  //TopLeft, TopRight, BottomRight, BottomLeft
            view.left, view.top,
            view.right, view.top,
            view.right, view.bottom,
            view.left, view.bottom,
        };
        NSValue *value;
        for (int i = 0; i < 4; i++) {
            value = [NSValue valueWithCGPoint:points[i]];
            [outlines addObject:value];
            
        }
        [outlines removeObjectAtIndex:(_posButtonIndex+2)%4];   // remove opposite corner to form a triangle
    } else if (_mode == kProtractorMode) {
        type = kTangibleTypeProtractor;
        NSValue *value;
        switch (_posButtonIndex) {
            case 0: // top
                value = [NSValue valueWithCGPoint:CGPointMake(view.left, view.top)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake(view.right, view.top)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake((view.left+view.right)/2, view.bottom)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake(view.left, view.bottom)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake(view.right, view.bottom)];
                [outlines addObject:value];
                break;
            case 1: // left
                value = [NSValue valueWithCGPoint:CGPointMake(view.left, view.top)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake(view.left, view.bottom)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake(view.right, (view.top+view.bottom)/2)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake(view.right, view.top)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake(view.right, view.bottom)];
                [outlines addObject:value];
                break;
            case 2: // bottom
                value = [NSValue valueWithCGPoint:CGPointMake(view.left, view.bottom)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake(view.right, view.bottom)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake((view.left+view.right)/2, view.top)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake(view.left, view.top)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake(view.right, view.top)];
                [outlines addObject:value];
                break;
            case 3: // right
                value = [NSValue valueWithCGPoint:CGPointMake(view.right, view.top)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake(view.right, view.bottom)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake(view.left, (view.top+view.bottom)/2)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake(view.left, view.top)];
                [outlines addObject:value];
                value = [NSValue valueWithCGPoint:CGPointMake(view.left, view.bottom)];
                [outlines addObject:value];
                break;
            default:
                break;
        }
    }
    
    // hide all position buttons
    for (UIButton *button in self.positionButton) {
        button.hidden = YES;
    }
    instructionLabel.text = @"";
    measurementLabel.text = @"";
    
    // create and add tangible object
    TangibleObject *obj = [[TangibleObject alloc] initWithType:type points:_touchesArray outlinePoints:outlines];
    [self addTangibleObject:obj];
}

- (IBAction)setSquarePressed{
    _mode = kSetSquareMode;
    
    LearningView *view = (id)self.view;
    CGPoint points[] = {  //TopLeft, TopRight, BottomRight, BottomLeft
        view.left, view.top,
        view.right, view.top,
        view.right, view.bottom,
        view.left, view.bottom,
    };
    [instructionLabel setText:@"Select the corner with the right angle."];
    [measurementLabel setText:@"Set square pressed."];
    
    // set up position buttons
    for (int i = 0; i <4; i++)
    {
        UIButton *posButton = [self.positionButton objectAtIndex:i];
        posButton.center = points[i];
        [posButton setTitle:@"*" forState:UIControlStateNormal];
        posButton.hidden = NO;
    }         
    _touchesArray = [self touchesArray];    // save touch array
}

- (IBAction)protractorPressed{
    _mode = kProtractorMode;
    
    LearningView *view = (id)self.view;
    float midx = (view.left + view.right) / 2;
    float midy = (view.top + view.bottom) / 2;
    CGPoint points[] = {  // top, left, bottom, right
        midx, view.top,
        view.left, midy,
        midx, view.bottom,
        view.right, midy,
    };
    [instructionLabel setText:@"Select the base of the protractor."];
    [measurementLabel setText:@"Protractor pressed."];
    
    // set up position buttons
    for (int i = 0; i <4; i++)
    {
        UIButton *posButton = [self.positionButton objectAtIndex:i];
        posButton.center = points[i];
        [posButton setTitle:@"*" forState:UIControlStateNormal];
        posButton.hidden = NO;
    }
    _touchesArray = [self touchesArray];
    [measurementLabel setText:@"Protractor pressed."];
}

- (IBAction)circlePressed {
    _mode = kCircleMode;
    NSMutableArray *outlines = [NSMutableArray arrayWithCapacity:3];
    NSValue *value;
    LearningView *view = (id)self.view;
    float midx = (view.left +view.right) /2;
    float midy = (view.top + view.bottom) /2;
    CGPoint midPoint = CGPointMake(midx, midy);
    value = [NSValue valueWithCGPoint:midPoint];
    [outlines addObject:value];
    CGPoint leftPoint = CGPointMake(view.left, midy);
    value = [NSValue valueWithCGPoint:leftPoint];
    [outlines addObject:value];
    CGPoint rightPoint = CGPointMake(view.right, midy);
    value = [NSValue valueWithCGPoint:rightPoint];
    [outlines addObject:value];
    
    
    
    NSArray *pointArr = [self touchesArray];
    TangibleObject *obj = [[TangibleObject alloc] initWithType:kTangibleTypeCircle points:pointArr outlinePoints:outlines];
    [self addTangibleObject:obj];
    
}

- (IBAction)trianglePressed {
    _mode = kTriangleMode;
    // TODO
}

- (IBAction)arrowKeyPressed {
    if (!_sketchView) {
        _recognizer.tangibleArray = tangibles;
        
        _sketchView = [[SketchPaper alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_sketchView];
        
        [self.view bringSubviewToFront:_tangibleView];
        [self.view bringSubviewToFront:_arrowButton];
        [self.view bringSubviewToFront:[self.view viewWithTag:kRecordButtonTag]]; // record button
        UIView *clear = [self.view viewWithTag:kClearButtonTag]; // clear button
        [self.view bringSubviewToFront:clear];
        // move clear button to top
        CGPoint c = clear.center;
        c.y = self.view.frame.size.height - c.y - 320;
        clear.center = c;
    } else {
        if (!_sketchView.enableButtons) {
            return;
        }
        [_sketchView removeFromSuperview];
        _sketchView = nil;
        // move clear button down
        UIView *clear = [self.view viewWithTag:kClearButtonTag];
        CGPoint c = clear.center;
        c.y = self.view.frame.size.height - c.y - 320;
        clear.center = c;
    }
}

- (IBAction)clearPressed {
    if (_sketchView) {  // clear sketch view
        [_sketchView clear];
    } else {    // clear tangible objects
        [tangibles removeAllObjects];
        _tangibleView.obj = nil;
        [_recognizer performSelector:@selector(reset)];
        _recognizer.tangibleArray = tangibles;
    }
}

- (IBAction)showRecord:(id)sender {
    RecordViewController *controller = [[RecordViewController alloc] initWithNibName:nil bundle:nil];
    controller.sketchPaper = _sketchView;
    controller.tangibleObj = [tangibles lastObject];
    [self presentModalViewController:controller animated:YES];
}

- (void)handleTangible:(TangibleRecognizer *)recognizer {
    TangibleView *view = (id)_tangibleView;
    TangibleObject *obj = recognizer.recognizedObject;
    if (!obj)   // do not clear tangible object
        return;
    if (!_sketchView.drawLine || view.obj != obj) { // update tangible object when is not in draw line mode
        view.obj = obj;
        view.trans = recognizer.transform;
        [view setNeedsDisplay];
    }    
    [(SketchPaper *)_sketchView setTangibleObject:obj];
    //    for (UILabel *label in self.labels) {
    //        label.hidden = NO;
    //        [self.view bringSubviewToFront:label];
    //    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint p = [touch locationInView:self.view];
    UIView *view = [self.view hitTest:p withEvent:nil];
    if ([view isKindOfClass:[UIButton class]]) {    // ignore touch that on top of button
        return NO;
    }
    return YES;
}

@end
