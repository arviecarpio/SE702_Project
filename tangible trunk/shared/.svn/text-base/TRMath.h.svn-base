//
//  TRMath.h
//  TangibleLearning
//
//  Created by standarduser on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef TangibleLearning_TRMath_h
#define TangibleLearning_TRMath_h

#define _USE_MATH_DEFINES
#include <algorithm>
#include <math.h>

#include "TRTypes.h"

using namespace std;

static inline bool operator==(const TRPoint p1, const TRPoint p2) {
    return p1.x == p2.x && p1.y == p2.y;
}

static inline bool trIsAlmostEquals(float f1, float f2, float epsilon) {
    return fabs(f1 - f2) < epsilon;
}

static inline bool trIsAlmostEquals(TRPoint p1, TRPoint p2, float epsilon) {
    return trIsAlmostEquals(p1.x, p2.x, epsilon) && trIsAlmostEquals(p1.y, p2.y, epsilon);
}
static inline bool trIsAlmostEquals(vector<float> f1, vector<float> f2, float epsilon){
    if (f1.size() != f2.size())
        return false;
    for(int i = 0; i < f1.size(); i++){
        if (!trIsAlmostEquals(f1[i], f2[i], epsilon)){
            return false;
        }
    }
    return true;
}

static inline float trLength(TRPoint p1, TRPoint p2) {
    float x = p1.x - p2.x;
    float y = p1.y - p2.y;
    return sqrt(x * x + y * y);
}

#endif
