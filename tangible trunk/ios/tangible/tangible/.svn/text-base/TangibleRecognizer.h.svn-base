//
//  TangibleRecognizer.h
//  tangible
//
//  Created by standarduser on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

enum TangibleType {
    kTangibleTypeInvalid,
    kTangibleTypeRuler,
    kTangibleTypeProtractor,
    kTangibleTypeSetsquare,
};

typedef enum TangibleType TangibleType;

@interface TangibleRecognizer : UIGestureRecognizer {
    TangibleType _type;
    CGPoint _p1;
    CGPoint _p2;
    CGPoint _p3;
}

@property (nonatomic) TangibleType type;
@property (nonatomic) CGPoint p1;
@property (nonatomic) CGPoint p2;
@property (nonatomic) CGPoint p3;

@end
