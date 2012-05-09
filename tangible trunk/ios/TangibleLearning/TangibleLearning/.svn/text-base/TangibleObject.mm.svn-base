//
//  TangibleObject.m
//  TangibleLearning
//
//  Created by standarduser on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TangibleObject.h"
#import "ViewController.h"

#include "TRRecognizer.h"

struct TangibleObjectImpl {
    TRGraph *graph;
};

@interface TangibleObject ()


@end

@implementation TangibleObject

@synthesize outlinePoints = _outlinePoints, type = _type, trans = _trans, points = _points;

- (id)initWithType:(TangibleType)type points:(NSArray *)points outlinePoints:(NSArray *)outlinePoints {
    self = [super init];
    if (self) {
        _type = type;
        _outlinePoints = outlinePoints;
        _trans = CGAffineTransformIdentity;
        _points = points;
    }
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _outlinePoints = [aDecoder decodeObjectForKey:@"outlinePoints"];
        _points = [aDecoder decodeObjectForKey:@"points"];
        _type = (TangibleType)[aDecoder decodeIntForKey:@"type"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_outlinePoints forKey:@"outlinePoints"];
    [aCoder encodeObject:_points forKey:@"points"];
    [aCoder encodeInt:_type forKey:@"type"];
}

#pragma mark -

- (void)updateTransformation:(const TRTangibleObject *)obj {
    _trans = CGAffineTransformRotate(CGAffineTransformIdentity, obj->getRotation());
    CGPoint trans = obj->getTranslation();
    _trans.tx = trans.x;
    _trans.ty = trans.y;
//    NSLog(@"rotate %f tx %f ty %f", obj->getRotation(), trans.x, trans.y);
}

@end
