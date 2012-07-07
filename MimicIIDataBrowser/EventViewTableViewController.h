//
//  EventViewTableViewController.h
//  MimicIIDataBrowser
//
//  Created by Eric Li on 6/2/11.
//  Copyright 2011 UTH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Patient.h"
#import "StudyEventLogger.h"
@class MainBrowserWindowController;

@interface EventViewTableViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> {
    
    NSManagedObjectContext *managedObjectContext;
    MainBrowserWindowController *mbwc;
    
    Patient *patient;
    NSString *eventClass;
    NSString *eventIdentifier;
    
    NSInteger numCol;
    
    NSArray *events, *allEvents;
    
    NSDate *startDate, *endDate;
    
    NSButton *selectionCheckBox;
    
    NSUInteger selectionCount, eventCount, allEventCount;
    
    IBOutlet StudyEventLogger *studyEventLogger;
    
    BOOL isSelected;
}
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) MainBrowserWindowController *mbwc;
@property (nonatomic, retain) Patient *patient;
@property (nonatomic, retain) NSString *eventClass;
@property (nonatomic, retain) NSString *eventIdentifier;
@property (nonatomic, retain) NSArray *events, *allEvents;
@property (nonatomic, retain) NSDate *startDate, *endDate;
@property (assign) IBOutlet NSButton *selectionCheckBox;

- (void)refreshEventsArrayWithNewCSV:(BOOL)_newCSV;
- (void) renderDataWithGraphRenderer:(NSArray *)_array;
- (void) decideOverallSelectionCheckboxState:(NSArray *)_events;
- (IBAction)checkboxClicked:(id)sender;
@end
