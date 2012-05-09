//
//  TRTouch.h
//  TangibleLearning
//
//  Created by standarduser on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef TangibleLearning_TRTouch_h
#define TangibleLearning_TRTouch_h

#include <vector>
#include <map>

#include "TRTypes.h"

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
    
    const std::map<TRIdentifier, TRTouch> & getTouches() const { return touches; }
    TRIdentifier getIdentifier(TRPoint p) const;
    void addPoint(TRIdentifier identifier, TRPoint p);
    bool removeTouch(TRIdentifier identifier);
};

#endif
