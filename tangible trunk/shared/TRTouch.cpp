//
//  TRTouch.cpp
//  TangibleLearning
//
//  Created by standarduser on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include "TRTouch.h"

#include "TRGraph.h"

using namespace std;

void TRTouchSet::addPoint(TRIdentifier identifier, TRPoint p) {
    map<TRIdentifier, TRTouch>::iterator it = touches.find(identifier);
    if (it == touches.end()) {
        touches[identifier] = TRTouch(identifier, p);
    } else {
        touches[identifier].addPoint(p);
    }
}

bool TRTouchSet::removeTouch(TRIdentifier identifier) {
    map<TRIdentifier, TRTouch>::iterator it = touches.find(identifier);
    if (it != touches.end()) {
        touches.erase(it);
        return true;
    }
    return false;
}

TRIdentifier TRTouchSet::getIdentifier(TRPoint p) const {
    map<TRIdentifier, TRTouch>::const_iterator it;
    for (it = touches.begin(); it != touches.end(); it++) {
        if (it->second.lastPoint() == p) {
            return it->first;
        }
    }
    return 0;
}