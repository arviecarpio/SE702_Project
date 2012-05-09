//
//  PointInfo.h
//  TangibleLearning
//
//  Created by standarduser on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef TangibleLearning_PointInfo_h
#define TangibleLearning_PointInfo_h

#include <vector>

#include "TRMath.h"

class TRTouchSet;

using namespace std;

class TRPointInfo {
    vector<float> lengths;
    TRPoint point;

public:
    TRPointInfo (TRPoint p, int n) :lengths(n) { point = p; }
    
    bool contains(TRPointInfo &other, vector<int> &idx);
    
    TRPoint getPoint() const { return point; }
    const vector<float> & getLengths() const { return lengths; }
    vector<float> & getLengths() { return lengths; }
};

class TRGraph {
    static float variance;
    
    vector<TRPointInfo> points;
    float rotation;
    TRPoint translation;
    vector<int> index;
    
    void init(vector<TRPoint> point);
    
public:
    static float getVariance() { return variance; }
    static void setVariance(float v) { variance = v; }
    
    TRGraph(vector<TRPoint> point) { init(point); }
    TRGraph(const TRTouchSet &touches);
    //void addPoint(TRPoint p);
    bool contains(TRGraph &other);
    bool equals(TRGraph &other);
    
    const vector<int> & getIndex() const { return index; }
    float getRotation() const { return rotation; }
    TRPoint getTranslation() const { return translation; }
    const vector<TRPointInfo> & getPoints() const { return points; }
    
#if defined (__APPLE__) && defined (__OBJC__)
    TRGraph(NSArray *points) {
        vector<CGPoint> pointArr;
        for (NSValue *value in points) {
            CGPoint p = [value CGPointValue];
            pointArr.push_back(p);
        }
        init(pointArr);
    }
#endif
};

#endif
