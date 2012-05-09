//
//  MyWindow.h
//  TangibleLearning
//
//  Created by standarduser on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// this class is used to fix a bug where view will not recive touch event while gesture recognizer it in change state
@interface MyWindow : UIWindow {
    NSMutableSet *forwardTouches;
}

- (void)forwardTouch:(UITouch *)touch beginPoint:(CGPoint)point event:(UIEvent *)event;

@end
