/* File : TangibleRecognizer.i C:\Users\rtan052\Desktop\swigwin-2.0.4\swig.exe -c++ -csharp -outdir "C:\Users\rtan052\Desktop\tangible\windows\Tangible Learning\Tangible Learning\Generated" "C:\Users\rtan052\Desktop\tangible\shared\TangibleRecognizer.i"  */
%module TangibleRecognizer

%{

#include "TRGraph.h"
#include "TRRecognizer.h"
#include "TRTouch.h"
#include "TRTypes.h"

%}

//
//  TRRecognizer.h
//  TangibleLearning
//
//  Created by standarduser on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef TangibleLearning_TRRecognizer_h
#define TangibleLearning_TRRecognizer_h

class TRTangibleObject {
    TRGraph graph;
    TRIdentifier identifier;
    std::map<TRIdentifier, int> recognizedIndex;
    bool recognized;
    float rotation;
    TRPoint translation;
    
public:
    TRTangibleObject() :graph(vector<TRPoint>()) { }
    TRTangibleObject(TRIdentifier i, TRGraph g) :graph(g), identifier(i) {}
    
    bool isRecognized() const { return recognized; }
    bool isFullyRecognized() const { return recognized && recognizedIndex.size() == graph.getPoints().size(); }
    float getRotation() const { return rotation; }
    TRPoint getTranslation() const { return translation; }
    TRIdentifier getIdentifier() const { return identifier; }
    std::map<TRIdentifier, int> getRecognizedIndex() const { return recognizedIndex; }
    
    bool recognize(TRTouchSet &touches);
    bool update(TRTouchSet &touches);
    void touchRemoved(TRIdentifier i);
    void reset();
};

class TRRecognizer {
    std::map<TRIdentifier, TRTangibleObject> tangibles;
    std::set<TRTangibleObject *> recognizedObjects;
    TRTouchSet touchSet;
    set<TRIdentifier> ignoredTouches;
    
    void ignoreTouch(TRIdentifier identifier);
    
public:
    TRRecognizer() {}
    
    void addTangibleObject(const TRTangibleObject &obj) { tangibles[obj.getIdentifier()] = obj; }
    const std::map<TRIdentifier, TRTangibleObject> & getTangibles() { return tangibles; }
    std::vector<TRIdentifier> getRecognizedObject();
    std::set<TRIdentifier> & getIgnoredTouches() { return ignoredTouches; }
    const TRTouchSet & getTouches() const { return touchSet; }
    const TRTangibleObject & getTangibleObjectForId(TRIdentifier identifier) const;
    
    void reset();
    
    void touchBegan(TRIdentifier identifier, TRPoint p);
    void touchMoved(TRIdentifier identifier, TRPoint p);
    void touchEnded(TRIdentifier identifier, TRPoint p);
    
    void touchesBegan(std::map<TRIdentifier, TRPoint> &touches);
    void touchesMoved(std::map<TRIdentifier, TRPoint> &touches);
    void touchesEnded(std::map<TRIdentifier, TRPoint> &touches);
    
#if defined (__APPLE__) && defined (__OBJC__)
    void touchesBegan(NSSet *touches) {
        std::map<TRIdentifier, TRPoint> map;
        for (UITouch *touch in touches) {
            map[TRIdentifierFromObject(touch)] = [touch locationInView:touch.window];
        }
        touchesBegan(map);
    }
    void touchesMoved(NSSet *touches) {
        std::map<TRIdentifier, TRPoint> map;
        for (UITouch *touch in touches) {
            map[TRIdentifierFromObject(touch)] = [touch locationInView:touch.window];
        }
        touchesMoved(map);
    }
    void touchesEnded(NSSet *touches) {
        std::map<TRIdentifier, TRPoint> map;
        for (UITouch *touch in touches) {
            map[TRIdentifierFromObject(touch)] = [touch locationInView:touch.window];
        }
        touchesEnded(map);
    }
#endif
};

#endif



/* Let's just grab the original header file here */
//
//  PointInfo.h
//  TangibleLearning
//
//  Created by standarduser on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef TangibleLearning_PointInfo_h
#define TangibleLearning_PointInfo_h

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
    vector<TRPointInfo> points;
    float rotation;
    TRPoint translation;
    vector<int> index;
    
    void init(vector<TRPoint> point);
    
public:
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


//
//  TRTouch.h
//  TangibleLearning
//
//  Created by standarduser on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef TangibleLearning_TRTouch_h
#define TangibleLearning_TRTouch_h

class TRGraph;

class TRTouch {
    TRIdentifier identifier;
    std::vector<TRPoint> history;
    
public:
    TRTouch() { }
    TRTouch(TRIdentifier i, TRPoint p) :identifier(i) { history.push_back(p); }
    
    TRPoint lastPoint() const { return history.back(); }
    TRPoint startPoint() const { return history[0]; }
    const std::vector<TRPoint> & getHistory() const { return history; }
    TRIdentifier getIdentifier() const { return identifier; }
    void addPoint(TRPoint p) { history.push_back(p); }
};

class TRTouchSet {
    std::map<TRIdentifier, TRTouch> touches;
    
public:
    TRTouchSet() {}
    
    const std::map<TRIdentifier, TRTouch> getTouches() const { return touches; }
    TRIdentifier getIdentifier(TRPoint p) const;
    void addPoint(TRIdentifier identifier, TRPoint p);
    void removeTouch(TRIdentifier identifier);
};

#endif

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

%include "std_vector.i"

%template(VectorTRPoint) std::vector<TRPoint>;
%template(VectorInt) std::vector<int>;
%template(VectorFloat) std::vector<float>;
%template(VectorTRPointInfo) std::vector<TRPointInfo>;