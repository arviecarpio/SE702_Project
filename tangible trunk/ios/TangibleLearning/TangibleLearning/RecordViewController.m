//
//  RecordViewController.m
//  TangibleLearning
//
//  Created by standarduser on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecordViewController.h"

#import "SketchPaper.h"
#import "ViewController.h"

@implementation RecordViewController
@synthesize tableView = _tableView;
@synthesize nameField = _nameField, sketchPaper = _sketchPaper, tangibleObj = _tangibleObj;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalInPopover = YES;
        self.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *name = _sketchPaper ? @"name.plist" : @"tangible.plist";
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:name];
    _names = [NSMutableArray arrayWithContentsOfFile:plistPath];
    if (!_names)
        _names = [NSMutableArray array];
    
}

- (void)viewDidUnload
{
    [self setNameField:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -

- (IBAction)save:(id)sender {
    if (_sketchPaper) {
        [_sketchPaper saveToFile:_nameField.text];
    } else if (_tangibleObj) {
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *plistPath = [rootPath stringByAppendingPathComponent:[_nameField.text stringByAppendingPathExtension:@"tangible"]];
        BOOL b = [NSKeyedArchiver archiveRootObject:_tangibleObj toFile:plistPath];
        if (!b)
            NSLog(@"failed!!!!");
    } else {
        return;
    }
    
    if (![_names containsObject:_nameField.text])
        [_names addObject:_nameField.text];
    [_tableView reloadData];
    
    NSString *name = _sketchPaper ? @"name.plist" : @"tangible.plist";
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:name];
    [_names writeToFile:plistPath atomically:YES];
}

- (IBAction)back:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_names count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [_names objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissModalViewControllerAnimated:YES];
    if (_sketchPaper) {
        [_sketchPaper performSelector:@selector(loadFromFile:) withObject:[_names objectAtIndex:indexPath.row] afterDelay:1];
    } else {
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *plistPath = [rootPath stringByAppendingPathComponent:[[_names objectAtIndex:indexPath.row] stringByAppendingPathExtension:@"tangible"]];
        [[ViewController sharedController] addTangibleObject:[NSKeyedUnarchiver unarchiveObjectWithFile:plistPath]];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *name = [_names objectAtIndex:indexPath.row];
        [_names removeObject:name];
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *plistPath;
        if (_sketchPaper) {
            plistPath = [rootPath stringByAppendingPathComponent:name];
        } else {
            plistPath = [rootPath stringByAppendingPathComponent:[[_names objectAtIndex:indexPath.row] stringByAppendingPathExtension:@"tangible"]];
        }
        [[NSFileManager defaultManager] removeItemAtPath:plistPath error:NULL];
        
        name = _sketchPaper ? @"name.plist" : @"tangible.plist";
        plistPath = [rootPath stringByAppendingPathComponent:name];
        [_names writeToFile:plistPath atomically:YES];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}

@end
