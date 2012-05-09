//
//  TangibleObject.h
//  TangibleLearning
//
//  Created by standarduser on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TRDeclare.h"

typedef enum TangibleType {
    kTangibleTypeRuler,
    kTangibleTypeSetsquare,
    kTangibleTypeProtractor,
    kTangibleTypeCircle,
    kTangibleTypeTriangle,
} TangibleType;

struct TangibleObjectImpl;

@interface TangibleObject : NSObject <NSCoding> {
@private
    NSArray *_outlinePoints;    // array of NSValue of CGPoint
    NSArray *_points;
    TangibleType _type;
    CGAffineTransform _trans;
}

@property (nonatomic, strong, readonly) NSArray *points;
@property (nonatomic, strong, readonly) NSArray *outlinePoints;
@property (nonatomic, readonly) TangibleType type;
@property (nonatomic, readonly) CGAffineTransform trans;

- (id)initWithType:(TangibleType ) type points:(NSArray *)points outlinePoints:(NSArray *)outlinePoints;

- (void)updateTransformation:(const TRTangibleObject *)obj;

@end
