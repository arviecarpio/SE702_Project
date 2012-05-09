//
//  ViewController.m
//  tangible
//
//  Created by standarduser on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "TangibleRecognizer.h"
#import "TriangleView.h"

@interface ViewController () 

- (void)handleEvent:(TangibleRecognizer *)recognizer;

@end

@implementation ViewController
@synthesize label;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    TangibleRecognizer *recognizer = [[TangibleRecognizer alloc] initWithTarget:self action:@selector(handleEvent:)];
    [self.view addGestureRecognizer:recognizer];
}

- (void)viewDidUnload
{
    [self setLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)handleEvent:(TangibleRecognizer *)recognizer {
    TriangleView *view = (TriangleView *)self.view;
    view.p1 = recognizer.p1;
    view.p2 = recognizer.p2;
    view.p3 = recognizer.p3;
    
    switch (recognizer.type) {
        case kTangibleTypeRuler:
            label.text = @"ruler";
            [view setNeedsDisplay];
            break;
            
        case kTangibleTypeProtractor:
            label.text = @"protractor";
            [view setNeedsDisplay];
            break;
            
        case kTangibleTypeSetsquare:
            label.text = @"setsquare";
            [view setNeedsDisplay];
            break;
            
        case kTangibleTypeInvalid:
            label.text = @"not found";
            break;
    }
}

@end
