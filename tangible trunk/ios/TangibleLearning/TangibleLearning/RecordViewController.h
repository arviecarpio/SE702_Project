//
//  RecordViewController.h
//  TangibleLearning
//
//  Created by standarduser on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SketchPaper, TangibleObject;

@interface RecordViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
@private
    NSMutableArray *_names;
    SketchPaper *_sketchPaper;
    TangibleObject *_tangibleObj;
}

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) SketchPaper *sketchPaper;
@property (nonatomic, strong) TangibleObject *tangibleObj;

- (IBAction)save:(id)sender;
- (IBAction)back:(id)sender;

@end
