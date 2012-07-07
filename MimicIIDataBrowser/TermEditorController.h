//
//  TermEditorController.h
//  Cog Station
//
//  Created by Zhe Li on 10/13/11.
//  Copyright 2011 UTHealth. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>
enum GCDAsyncSocketFlags
{
    kConceptTypeIO = 0,
    kConceptTypeMed,
    kConceptTypeLab,
    kConceptTypeChart,
};

@interface TermEditorController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>
{
    NSManagedObject *conceptObject;
    NSUInteger conceptType;
    
    NSPopover *containerPopover;
    IBOutlet NSTableView *tableView;
}

@property (nonatomic, retain) NSManagedObject *conceptObject;
@property (assign) NSPopover *containerPopover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil conceptObject:(NSManagedObject *)_conceptObject andConceptType:(NSUInteger)_conceptType;
- (IBAction)closePopover:(id)sender;
@end
