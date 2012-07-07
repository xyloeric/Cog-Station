//
//  MainBrowserWindowController.h
//  MimicIIDataBrowser
//
//  Created by zli on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PatientTableViewController.h"
#import "MedTableViewController.h"
#import "IOTableViewController.h"
#import "LabTableViewController.h"
#import "EventViewTableViewController.h"
#import "ChartEventTableViewController.h"
#import "Patient.h"
#import "Session.h"
#import "HighStockCSVRenderView.h"
#import "StudyEventLogger.h"
#import "TermBrowserController.h"

@interface MainBrowserWindowController : NSWindowController <NSTabViewDelegate, NSTableViewDelegate, NSTableViewDataSource, NSTextViewDelegate> {

    
    NSManagedObjectContext *managedObjectContext;
    IBOutlet NSManagedObjectContext *arrayControllerMOCHandle;
    
    Patient *currentPatient;
    Session *currentSession;
    NSIndexSet *currentSessions;
    NSMutableArray *currentSessionObjects;
    
    PatientTableViewController *ptvc;
    MedTableViewController *mtvc;
    IOTableViewController *itvc;
    LabTableViewController *ltvc;
    ChartEventTableViewController *cetvc;
    
    TermBrowserController *tbc;
    
    EventViewTableViewController *evtvc;
    HighStockCSVRenderView *hscrv;
    
    NSTabView *browserTab;
    
    NSMutableString *commentString;
    NSTextView *commentEditorTextView;
    NSTextField *dobLabel;
    NSTextField *sexLabel;
    NSTextField *ageLabel;
    NSTextField *objectPathLabel;
    
    
    NSTextField *dateRangeText;
    NSSlider *dateRangeSlider;
    
    NSDate *eventStartDate, *eventEndDate;
    NSNumber * eventStartDateTI, *eventEndDateTI;
    NSNumber * eventDateRangeUpperPercentile, *eventDateRangeUpper;
    StudyEventLogger *studyEventLogger;
    
    IBOutlet NSTableView *drawerTableView;
    IBOutlet NSButton *recordingButton;
    IBOutlet NSButton *serverStartButton;
    
    IBOutlet NSDrawer *recordingDrawer;
    IBOutlet NSDrawer *serverDrawer;
    IBOutlet NSButton *recordingDrawerButton;
    IBOutlet NSButton *serverDrawerButton;
    
    IBOutlet NSArrayController *sessionArrayController;
        
}
@property (nonatomic, retain)  NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Patient *currentPatient;
@property (nonatomic, retain) Session *currentSession;
@property (nonatomic, retain) NSIndexSet *currentSessions;
@property (nonatomic, retain) NSMutableArray *currentSessionObjects;
@property (nonatomic, retain) IBOutlet PatientTableViewController *ptvc;
@property (nonatomic, retain) IBOutlet MedTableViewController *mtvc;
@property (nonatomic, retain) IBOutlet LabTableViewController *ltvc;
@property (nonatomic, retain) IBOutlet IOTableViewController *itvc;
@property (nonatomic, retain) IBOutlet TermBrowserController *tbc;
@property (nonatomic, retain) IBOutlet EventViewTableViewController *evtvc;
@property (nonatomic, retain) IBOutlet ChartEventTableViewController *cetvc;
@property (nonatomic, retain) IBOutlet HighStockCSVRenderView *hscrv;
@property (assign) IBOutlet NSTabView *browserTab;
@property (nonatomic, retain) NSMutableString *commentString;
@property (assign) IBOutlet NSTextView *commentEditorTextView;
@property (assign) IBOutlet NSTextField *dobLabel;
@property (assign) IBOutlet NSTextField *sexLabel;
@property (assign) IBOutlet NSTextField *ageLabel;
@property (assign) IBOutlet NSTextField *objectPathLabel;
@property (assign) IBOutlet NSTextField *dateRangeText;
@property (assign) IBOutlet NSSlider *dateRangeSlider;
@property (nonatomic, retain) NSDate *eventStartDate, *eventEndDate;
@property (nonatomic, retain) NSNumber * eventStartDateTI, *eventEndDateTI, *eventDateRangeUpperPercentile, *eventDateRangeUpper;
@property (assign) IBOutlet StudyEventLogger *studyEventLogger;
@property (assign) NSArrayController *sessionArrayController;

- (id)initWithWindowNibName:(NSString *)windowNibName andManagedObjectContext:(NSManagedObjectContext *)_managedObjectContext;
- (NSInteger)age:(NSDate *)dateOfBirth;

- (IBAction)dateRangeChanged:(id)sender;
- (IBAction)toggleDrawer:(id)sender;
- (IBAction)toggleRecordingStatus:(id)sender;

- (IBAction)viewSession:(id)sender;

- (IBAction)tableViewSelected:(id)sender;
- (IBAction)deleteSession:(id)sender;

- (IBAction)startServer:(id)sender;
@end
