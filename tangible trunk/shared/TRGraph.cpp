//
//  Graph.cpp
//  TangibleLearning
//
//  Created by  on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include "TRGraph.h"

#include <iostream>
#include <math.h>

#include "TRTouch.h"

#ifdef __APPLE__
float TRGraph::variance = 10;
#else
float TRGraph::variance = 500;
#endif

bool TRPointInfo::contains(TRPointInfo &other, vector<int> &idx){
    idx.clear();
    for(int j = 0; j < other.lengths.size(); j++){
        for(int i = 0; i < this->lengths.size(); i++){
            if(trIsAlmostEquals(this->lengths[i],other.lengths[j], TRGraph::getVariance())){
                idx.push_back(i);
                this->lengths[i] = -1;
            }
        }
        
    }
    return other.lengths.size() == idx.size();
}

TRGraph::TRGraph(const TRTouchSet &touchSet) {
    const map<TRIdentifier, TRTouch> & touches = touchSet.getTouches();
    vector<TRPoint> points;
    map<TRIdentifier, TRTouch>::const_iterator it;
    for (it = touches.begin(); it != touches.end(); it++) {
        points.push_back(it->second.lastPoint());
    }
    init(points);
}

void TRGraph::init(vector<TRPoint> point)
{
    int count = point.size();
    for (int i = 0; i < count; i++){
        TRPoint p1 = point.at(i);
        TRPointInfo pInfo = TRPointInfo(p1, count);
        for(int j = 0; j < count; j++){
            TRPoint p2 = point.at(j);
            float x, y;
            x = p1.x - p2.x;
            y = p1.y - p2.y;
            pInfo.getLengths()[j] = sqrtf(x * x + y * y);
        }
        points.push_back(pInfo);
    }
    rotation = 0.0;
    translation.x = 0;
    translation.y = 0;
}

bool TRGraph::contains(TRGraph &other)
{
    //Create copies
    vector<TRPointInfo> thisGraph = this->points;
    vector<TRPointInfo> otherGraph = other.points;
    TRPointInfo pInfo = otherGraph[0];
    index.clear();
    for(int i = 0; i < thisGraph.size(); i++){
        TRPointInfo compInfo = thisGraph[i];
        if (compInfo.contains(pInfo, index)) {
            vector<TRPoint> pts;
            for(int j = 0; j < index.size(); j++){
                pts.push_back(this->points[index[j]].getPoint());
            }
            TRGraph compGraph = TRGraph(pts);
            if(other.equals(compGraph)){
                rotation = other.rotation;
                translation = other.translation;
                return true;
            }
        }
    }
    return false;
}
bool TRGraph::equals(TRGraph &other)
{
    
    if(this->points.size() == other.points.size()){
        //Create sorted arrays for comparison
        vector<vector<float> > thisGraph;
        vector<vector<float> > otherGraph;
        for(int i = 0; i < this->points.size(); i++){
            vector<float> lengths = this->points[i].getLengths();
            std::sort(lengths.begin(), lengths.end());
            thisGraph.push_back(lengths);
            lengths = other.points[i].getLengths();
            std::sort(lengths.begin(), lengths.end());
            otherGraph.push_back(lengths);
        }
        
        //        for (int i = 0; i < points.size(); i++) {
        //            for (int j = 0; j < points.size(); j++) {
        //                printf("%f\t", thisGraph[i][j]);
        //            }
        //            printf("\n");
        //        }
        //        printf("\n");
        //        for (int i = 0; i < points.size(); i++) {
        //            for (int j = 0; j < points.size(); j++) {
        //                printf("%f\t", otherGraph[i][j]);
        //            }
        //            printf("\n");
        //        }
        
        index = vector<int>(points.size(), -1);
        for(int i = 0; i < this->points.size(); i++){
            bool matched = false;
            for(int j = 0; j < this->points.size(); j++){
                if(trIsAlmostEquals(thisGraph[i], otherGraph[j], getVariance())){
                    matched = true;
                    index[j] = i;
                    break;
                }
            }
            if (!matched) {           
                return false;
            } else {
                otherGraph[index[i]] = vector<float>();
            }
        }
        TRPoint p1,p2;
        for(int i = 0; i < other.points.size(); i++){
            TRPoint p = other.points[i].getPoint();
            if(index[i] == 0){
                p1 = p;
            }else if(index[i] ==1){
                p2 = p;
            }
        }
        TRPoint p3 = this->points[0].getPoint();
        TRPoint p4 = this->points[1].getPoint();
        float x, y;
        x = p1.x - p2.x;
        y = p1.y - p2.y;
        
        float angle = atan2f(y, x);
        float length = trLength(p1, p2);
        float length2 = trLength(p3, p4);
        if(!trIsAlmostEquals(length, length2, getVariance())){
//            printf("old p4 %.0f %.0f\n", p4.x, p4.y);
            p4 = this->points.back().getPoint();
        }
        x = p3.x - p4.x;
        y = p3.y - p4.y;
        float angle2 = atan2f(y, x);
        
//        printf("angle: %.2f angle2: %.2f\n", angle/M_PI*180, angle2/M_PI*180);
//        printf("p1p2 %.0f %.0f, %.0f %.0f\n", p1.x, p1.y, p2.x, p2.y);
//        printf("p3p4 %.0f %.0f, %.0f %.0f\n", p3.x, p3.y, p4.x, p4.y);
        
        rotation = angle - angle2;
        while (rotation > M_PI) {
            rotation -= M_PI * 2;
        }
        while (rotation < -M_PI) {
            rotation += M_PI * 2;
        }
        other.rotation = rotation;
        
        
        translation.x = p1.x - p3.x * cosf(rotation) + p3.y * sinf(rotation);
        translation.y = p1.y - p3.y * cosf(rotation) - p3.x * sinf(rotation);
        other.translation = translation;
        
        return true;
    }
    return false;
}