//
//  TRTypes.h
//  TangibleLearning
//
//  Created by standarduser on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef TangibleLearning_TRTypes_h
#define TangibleLearning_TRTypes_h

#ifdef __APPLE__

#import <CoreGraphics/CoreGraphics.h>
typedef CGPoint TRPoint;

#else   // windows

typedef struct {
    float x, y;
} TRPoint;

#endif /* __APPLE__ */

#ifdef __LP64__
typedef long long TRIdentifier;
#else
typedef int TRIdentifier;
#endif  /* __LP64__ */

#ifdef __OBJC__

static inline TRIdentifier TRIdentifierFromObject(id obj) {
    return (TRIdentifier)((__bridge void *)obj);
}

#endif /* __OBJC__ */

#endif

