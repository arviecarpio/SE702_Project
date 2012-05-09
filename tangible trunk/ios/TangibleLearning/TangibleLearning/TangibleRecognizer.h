//
//  TangibleRecognizer.h
//  tangible
//
//  Created by standarduser on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TRDeclare.h"

@class TangibleObject;

@interface TangibleRecognizer : UIGestureRecognizer {
@private
    NSArray * _tangibleArray;
    TangibleObject *_recognizedObject;
    CGAffineTransform _transform;
    TRRecognizer *_recognizer;
    NSMutableDictionary *_beginLocation;
}

@property (nonatomic, strong) NSArray * tangibleArray;
@property (nonatomic, strong, readonly) TangibleObject *recognizedObject;
@property (nonatomic, readonly) CGAffineTransform transform;

@end
