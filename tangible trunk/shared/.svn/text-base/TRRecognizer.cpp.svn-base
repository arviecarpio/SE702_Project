//
//  TRRecognizer.cpp
//  TangibleLearning
//
//  Created by standarduser on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include "TRRecognizer.h"

#include <iostream>
#include <math.h>

bool TRTangibleObject::recognize(TRTouchSet &touches) {
    if (touches.getTouches().size() <= 1) {
        reset();
        return false;
    }
    TRGraph g(touches);
    if (g.contains(graph)) {
        const vector<int> &idx = g.getIndex();
        if (!recognized) {
            recognized = idx.size() == graph.getPoints().size();
        }
        if (recognized) {
            recognizedIndex.clear();
            for (int i = 0; i < idx.size(); i++) {
                int j = idx[i];
                TRIdentifier touchID = touches.getIdentifier(g.getPoints().at(j).getPoint());
                recognizedIndex[touchID] = i;
                touches.removeTouch(touchID);
            }
        }
        rotation = g.getRotation();
        translation = g.getTranslation();
    } else {
//        recognized = false;
    }
    return recognized;
}

bool TRTangibleObject::update(TRTouchSet &touches) {
    
    TRPoint points[4];
    int idx[2];
    int i = 0;
    const map<TRIdentifier, TRTouch> & touchMap = touches.getTouches();
    map<TRIdentifier, TRTouch>::const_iterator it;
    for (it = touchMap.begin(); it != touchMap.end();) {
        map<TRIdentifier, TRTouch>::const_iterator it3 = it++;
        map<TRIdentifier, int>::iterator it2 = recognizedIndex.find(it3->first);
        if (it2 != recognizedIndex.end()) {
            if (i < 2) {
                idx[i] = it2->second;
                points[i] = touches.getTouches().at(it2->first).lastPoint();
                i++;
            }
            touches.removeTouch(it3->first);
        }
    }
    if (i != 2) {
#ifdef __APPLE__
	reset();
	return false;
#else
        return true;
#endif
    }
    
    points[2] = graph.getPoints().at(idx[0]).getPoint();
    points[3] = graph.getPoints().at(idx[1]).getPoint();
    
#ifdef __APPLE__
    // TODO currently assumed if one touch moved away than the shape is destroyed
    float dis = trLength(points[2], points[3]);
    float dis2 = trLength(points[0], points[1]);
    if (!trIsAlmostEquals(dis, dis2, 10)) {
        reset();
        return false;
    }
#endif 
    float x, y;
    
    x = points[0].x - points[1].x;
    y = points[0].y - points[1].y;
    float angle = atan2f(y, x);
    
    x = points[2].x - points[3].x;
    y = points[2].y - points[3].y;
    float angle2 = atan2f(y, x);
    
    rotation = angle - angle2;
    while (rotation > M_PI) {
        rotation -= M_PI * 2;
    }
    while (rotation < -M_PI) {
        rotation += M_PI * 2;
    }
    translation.x = points[0].x - points[2].x * cosf(rotation) + points[2].y * sinf(rotation);
    translation.y = points[0].y - points[2].y * cosf(rotation) - points[2].x * sinf(rotation);
    
    return true;
}

void TRTangibleObject::touchRemoved(TRIdentifier i) {
    recognizedIndex.erase(i);
    if (recognizedIndex.size() == 0)
        recognized = false;
}

void TRTangibleObject::reset() {
    recognized = false;
    recognizedIndex.clear();
}

std::vector<TRIdentifier> TRRecognizer::getRecognizedObject() {
    vector<TRIdentifier> v(recognizedObjects.size());
    set<TRTangibleObject *>::iterator it;
    for (it = recognizedObjects.begin(); it != recognizedObjects.end(); it++) {
        v.push_back((*it)->getIdentifier());
    }
    return v;
}

const TRTangibleObject & TRRecognizer::getTangibleObjectForId(TRIdentifier identifier) const {
    return tangibles.find(identifier)->second;
}

void TRRecognizer::reset() {
    touchSet = TRTouchSet();    // TODO should have a clear method
    ignoredTouches.clear();
    map<TRIdentifier, TRTangibleObject>::iterator it;
    for (it = tangibles.begin(); it != tangibles.end(); it++) {
        it->second.reset();
    }
}

void TRRecognizer::touchBegan(TRIdentifier identifier, TRPoint p) {
    map<TRIdentifier, TRPoint> map;
    map[identifier] = p;
    touchesBegan(map);
}

void TRRecognizer::touchMoved(TRIdentifier identifier, TRPoint p) {
    map<TRIdentifier, TRPoint> map;
    map[identifier] = p;
    touchesMoved(map);
}

void TRRecognizer::touchEnded(TRIdentifier identifier, TRPoint p) {
    map<TRIdentifier, TRPoint> map;
    map[identifier] = p;
    touchesEnded(map);
}

void TRRecognizer::touchesBegan(std::map<TRIdentifier, TRPoint> &touches) {
//    int before = touchSet.getTouches().size();
    for (map<TRIdentifier, TRPoint>::iterator it = touches.begin(); it != touches.end(); it++) {
        touchSet.addPoint(it->first, it->second);
        ignoredTouches.erase(it->first);
    }
   // printf("began %d -> %lu\n", before, touchSet.getTouches().size());
    
    TRTouchSet set = touchSet;
    recognizedObjects.clear();
    map<TRIdentifier, TRTangibleObject>::iterator it;
    for (it = tangibles.begin(); it != tangibles.end(); it++) {
        TRTangibleObject &obj = it->second;
        if (obj.isFullyRecognized() || obj.recognize(set))
            recognizedObjects.insert(&obj);
    }
}
void TRRecognizer::touchesMoved(std::map<TRIdentifier, TRPoint> &touches) {
//    int before = touchSet.getTouches().size();
    for (map<TRIdentifier, TRPoint>::iterator it = touches.begin(); it != touches.end(); ) {
        if (ignoredTouches.find(it->first) != ignoredTouches.end()) {
            touches.erase(it++);
        } else {
            touchSet.addPoint(it->first, it->second);
            ++it;
        }
    }
//printf("move %d -> %lu\n", before, touchSet.getTouches().size());
    if (touches.size() == 0)
        return;
    
    TRTouchSet set = touchSet;
    map<TRIdentifier, TRTangibleObject>::iterator it;
    for (it = tangibles.begin(); it != tangibles.end(); it++) {
        TRTangibleObject &obj = it->second;
        map<TRIdentifier, int> recognizedIndex = obj.getRecognizedIndex();
        map<TRIdentifier, TRPoint>::iterator it2;
        for (it2 = touches.begin(); it2 != touches.end(); it2++) {
            // if one of the points for this tangible moved than need to recognize again
            // this also calculates the new rotation and translation
            if (recognizedIndex.find(it2->first) != recognizedIndex.end()) {
                if (!obj.update(set)) {
                    recognizedObjects.erase(&obj);
                }
                break;
            }
        }
    }
    
    const map<TRIdentifier, TRTouch> remainTouches = set.getTouches();
    map<TRIdentifier, TRPoint>::const_iterator it3;
    for (it3 = touches.begin(); it3 != touches.end(); it3++) {
        if (remainTouches.find(it3->first) != remainTouches.end()) {
            float dis = trLength(remainTouches.at(it3->first).startPoint(), remainTouches.at(it3->first).lastPoint());
#ifdef __APPLE__
            if (dis > 40)
#else
            if (dis > 1500)
#endif
                ignoreTouch(it3->first);
        }
    }
}
void TRRecognizer::touchesEnded(std::map<TRIdentifier, TRPoint> &touches) {
//    int before = touchSet.getTouches().size();
    for (map<TRIdentifier, TRPoint>::iterator it = touches.begin(); it != touches.end();) {
        set<TRIdentifier>::iterator it2 = ignoredTouches.find(it->first);
        if (it2 != ignoredTouches.end()) {
            touches.erase(it++);
            ignoredTouches.erase(it2);
        } else {
            touchSet.addPoint(it->first, it->second);
            ++it;
        }
    }
    if (touches.size() == 0)
        return;
    
    map<TRIdentifier, TRTangibleObject>::iterator it;
    for (it = tangibles.begin(); it != tangibles.end(); it++) {
        TRTangibleObject &obj = it->second;
        map<TRIdentifier, int> recognizedIndex = obj.getRecognizedIndex();
        map<TRIdentifier, TRPoint>::iterator it2;
        for (it2 = touches.begin(); it2 != touches.end();) {
            if (recognizedIndex.find(it2->first) != recognizedIndex.end()) {
                // this touch is part of this object and it ended
                obj.touchRemoved(it2->first);
                touchSet.removeTouch(it2->first);
                touches.erase(it2++);
                if (!obj.isRecognized()) {  // because all of its touch are ended
                    recognizedObjects.erase(&obj);
                }
            } else {
                ++it2;
            }
        }
    }
    
    for (map<TRIdentifier, TRPoint>::iterator it = touches.begin(); it != touches.end(); it++) {
        touchSet.removeTouch(it->first);
    }
   // printf("ended %d -> %lu\n", before, touchSet.getTouches().size());
}

void TRRecognizer::ignoreTouch(TRIdentifier identifier) {
#ifdef __APPLE__
    touchSet.removeTouch(identifier);
    ignoredTouches.insert(identifier);
    std::cout << "touch ignored" << (void *)identifier << endl;
#endif
}