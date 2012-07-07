//
//  MainBrowserWindowController.m
//  MimicIIDataBrowser
//
//  Created by zli on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainBrowserWindowController.h"
#import "MimicIIDataBrowserAppDelegate.h"
#import "PlayerWindowController.h"

@interface MainBrowserWindowController (hidden)
- (void)setupDrawers;
@end

@implementation MainBrowserWindowController
@synthesize studyEventLogger;
@synthesize managedObjectContext;
@synthesize currentPatient;
@synthesize currentSessions;
@synthesize currentSession;
@synthesize currentSessionObjects;
@synthesize ptvc;
@synthesize mtvc;
@synthesize ltvc;
@synthesize itvc;
@synthesize tbc;
@synthesize evtvc;
@synthesize cetvc;
@synthesize hscrv;
@synthesize browserTab;
@synthesize commentString;
@synthesize commentEditorTextView;
@synthesize dobLabel;
@synthesize sexLabel;
@synthesize ageLabel;
@synthesize objectPathLabel;
@synthesize dateRangeText;
@synthesize dateRangeSlider;
@synthesize eventStartDate, eventEndDate;
@synthesize eventStartDateTI, eventEndDateTI, eventDateRangeUpperPercentile, eventDateRangeUpper;
@synthesize sessionArrayController;

- (id)initWithWindow:(NSWindow *)_window
{
    self = [super initWithWindow:_window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithWindowNibName:(NSString *)windowNibName andManagedObjectContext:(NSManagedObjectContext *)_managedObjectContext
{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        self.managedObjectContext = _managedObjectContext;
        
        NSError *error = nil;
        //sessionArrayController.managedObjectContext = managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Session"];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"flag" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptor release];
        [sortDescriptors release];

        currentSessionObjects = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
        
        [self showWindow:nil];
    }
    
    return self;
}


- (void)dealloc
{
    [managedObjectContext release];
    [currentSessions release];
    [currentSession release];
    [currentSessionObjects release];
    [currentPatient release];
    [ltvc release];
    [mtvc release];
    [itvc release];
    [ptvc release];
    [tbc release];
    [evtvc release];
    [cetvc release];
    [hscrv release];
    [commentString release];
    [eventEndDate release];
    [eventStartDate release];
    [eventStartDateTI release];
    [eventEndDateTI release];
    [eventDateRangeUpperPercentile release];
    [eventDateRangeUpper release];
    [super dealloc];
}

- (void)awakeFromNib
{
    
    [recordingButton setImage:[NSImage imageNamed:@"recordingButton.png"]];
    [recordingButton setImagePosition:NSImageOnly];
    ptvc.managedObjectContext = self.managedObjectContext;
    ptvc.mbwc = self;
    [ptvc testQuery];
    
    ltvc.managedObjectContext = self.managedObjectContext;
    ltvc.mbwc = self;
    
    itvc.managedObjectContext = self.managedObjectContext;
    itvc.mbwc = self;
    
    mtvc.managedObjectContext = self.managedObjectContext;
    mtvc.mbwc = self;
    
    tbc.managedObjectContext = self.managedObjectContext;
    
    evtvc.managedObjectContext = self.managedObjectContext;
    evtvc.mbwc = self;
    
    cetvc.managedObjectContext = self.managedObjectContext;
    cetvc.mbwc = self;
    self.eventDateRangeUpperPercentile = [NSNumber numberWithDouble:100];
    NSLog(@"%f",[dateRangeSlider maxValue]);
    [dateRangeSlider bind:@"value" toObject:self withKeyPath:@"eventDateRangeUpperPercentile" options:nil];
        
    studyEventLogger.managedObjectContext = self.managedObjectContext;
    studyEventLogger.mbwc = self;
    
    [self setupDrawers];
}

- (void) setCurrentSessions:(NSIndexSet *)_currentSessions
{
    if (_currentSessions != currentSessions) {
        [currentSessions release];
        currentSessions = [_currentSessions retain];
        
//        if (studyEventLogger.isRecording) {
//            [studyEventLogger setIsRecording:NO];
//            [recordingButton setState:NSOffState];
//        }
        
        if (!studyEventLogger.isRecording) {
            currentSession = [[sessionArrayController arrangedObjects] objectAtIndex:[currentSessions firstIndex]];
            //studyEventLogger.currentSession = currentSession;
            NSLog(@"here %@", studyEventLogger.currentSession);
        }
        
        
        //set up author
        self.commentString = [NSMutableString string];
        if (currentSession.comment) {
            [commentString appendString:currentSession.comment];
        }
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:commentString];
        [[commentEditorTextView textStorage] setAttributedString:string];
        
    }
}

- (void) setCurrentSession:(Session *)_currentSession
{
    if (currentSession != _currentSession) {
        [currentSession release];
        currentSession = [_currentSession retain];
        
        //[((NSTableView *)[[[recordingDrawer contentView] subviews] objectAtIndex:0]) reloadData];
        [drawerTableView reloadData];
        if (currentSession != nil) {
            [drawerTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[currentSessionObjects indexOfObject:currentSession]] byExtendingSelection:NO];
        }
        
        //[sessionArrayController setSelectionIndex:[arrangedObjects indexOfObject:currentSession]];
        
        NSLog(@"here %@", _currentSession);
    }
}

- (void) setCurrentSessionObjects:(NSMutableArray *)_currentSessionObjects
{
    if (currentSessionObjects != _currentSessionObjects) {
        [currentSessionObjects release];
        currentSessionObjects = [_currentSessionObjects retain];
        NSLog(@"%@", currentSessionObjects);
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)setupDrawers {
    [recordingDrawer setMinContentSize:NSMakeSize(100, 100)];
    [recordingDrawer setMaxContentSize:NSMakeSize(400, 400)];
    [serverDrawer setMinContentSize:NSMakeSize(300, 100)];
    [serverDrawer setMaxContentSize:NSMakeSize(400, 400)];
}

- (void)setCurrentPatient:(Patient *)_currentPatient
{
    @autoreleasepool {
        if (currentPatient != _currentPatient) {
            
            if (studyEventLogger.isRecording) {
                [studyEventLogger setIsRecording:NO];
                [recordingButton setState:NSOffState];
            }
            
            [currentPatient release];
            currentPatient = [_currentPatient retain];
            
            self.eventStartDate = currentPatient.eventStart;
            self.eventEndDate = currentPatient.eventEnd;
            
            evtvc.startDate = eventStartDate;
            evtvc.endDate = eventEndDate;
            
            [dateRangeText setStringValue:[NSString stringWithFormat:@"%@ to %@", eventStartDate, eventEndDate]];
            
            self.eventStartDateTI = [NSNumber numberWithFloat:[eventStartDate timeIntervalSince1970]];
            self.eventEndDateTI = [NSNumber numberWithFloat:[eventEndDate timeIntervalSince1970]];
            
            //        [dateRangeSlider setMaxValue:[eventEndDateTI doubleValue]];
            //        [dateRangeSlider setMinValue:[eventStartDateTI doubleValue]];
            self.eventDateRangeUpperPercentile = [NSNumber numberWithDouble:100];
            
            NSDate *ptDOB = [NSDate dateWithNaturalLanguageString:currentPatient.patientDOB];
            NSString *age = [NSString stringWithFormat:@"%i", [self age:ptDOB]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            NSString *dobString = [dateFormatter stringFromDate:ptDOB];
            
            self.dobLabel.stringValue = dobString;
            self.ageLabel.stringValue = age;
            self.sexLabel.stringValue = currentPatient.patientSex;
            
        }

    }
}

//- (ExperimentComment *)getCurrentCommentObjectWithSession:(Session *)_session
//{
////    @autoreleasepool {
////        if (_session != nil && _patient != nil) {
////            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:managedObjectContext];
////            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
////            [fetchRequest setEntity:entityDescription];
////            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patient = %@ && session = %@", _session, _patient];
////            [fetchRequest setPredicate:predicate];
////            
////            NSError *error = nil;
////            ExperimentComment *comment = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] lastObject];
////            
////            if (comment == nil) {
////                comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:managedObjectContext];
////                comment.patient = _patient;
////                comment.session = _session;
////            }
////            
////            [fetchRequest release];
////            
////            return comment;
////        }
////        else {
////            return nil;
////        }
////
////    }
//}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{

    [commentString replaceCharactersInRange:affectedCharRange withString:replacementString];
    currentSession.comment = commentString;
    
    
    return YES;
}

- (NSInteger)age:(NSDate *)dateOfBirth {
    @autoreleasepool {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
        NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
        
        if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
            (([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day]))) {
            return [dateComponentsNow year] - [dateComponentsBirth year] - 1;
        } else {
            return [dateComponentsNow year] - [dateComponentsBirth year];
        }
    }
}

- (IBAction)dateRangeChanged:(id)sender {
    @autoreleasepool {
        NSLog(@"%@", eventDateRangeUpperPercentile);
        NSTimeInterval rangeUpperTI = ([eventEndDateTI doubleValue] - [eventStartDateTI doubleValue]) * ([eventDateRangeUpperPercentile doubleValue]/100.0) + [eventStartDateTI doubleValue];
        NSDate *rangeUpper = [NSDate dateWithTimeIntervalSince1970:rangeUpperTI];
        self.eventDateRangeUpper = [NSNumber numberWithDouble:rangeUpperTI];
        [dateRangeText setStringValue:[NSString stringWithFormat:@"%@ to %@", eventStartDate, rangeUpper]];
        
        evtvc.startDate = eventStartDate;
        evtvc.endDate = rangeUpper;
        
        [evtvc refreshEventsArrayWithNewCSV:NO];
    }
    

}

- (IBAction)toggleDrawer:(id)sender
{
    if (sender == recordingDrawerButton) {
        NSDrawerState state = [recordingDrawer state];
        if (NSDrawerOpeningState == state || NSDrawerOpenState == state) {
            [recordingDrawer close];
            [sender setState:NSOnState];
        } else {
            [recordingDrawer openOnEdge:NSMinXEdge];
            [sender setState:NSOffState];
        }
    }
    
    if (sender == serverDrawerButton) {
        NSDrawerState state = [serverDrawer state];
        if (NSDrawerOpeningState == state || NSDrawerOpenState == state) {
            [serverDrawer close];
            [sender setState:NSOnState];
        } else {
            [serverDrawer openOnEdge:NSMaxXEdge];
            [sender setState:NSOffState];
        }
    }
}

- (IBAction)toggleRecordingStatus:(id)sender
{
    if (currentPatient) {
        if ([sender state] == NSOnState) {
            [studyEventLogger setIsRecording:YES];
            [sender setState:NSOnState];
        }
        else
        {
            [studyEventLogger setIsRecording:NO];
            [sender setState:NSOffState];
        }

    }
    else {
        [sender setState:NSOffState];
    }
}

- (IBAction)viewSession:(id)sender
{
    if (currentSession) {
        //Session *_currentSession = [[sessionArrayController arrangedObjects] objectAtIndex:[currentSessions firstIndex]];
        [[PlayerWindowController alloc] initWithWindowNibName:@"PlayerWindow" andSession:currentSession];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [currentSessionObjects count];
}

//- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    if ([tableColumn.identifier isEqualToString:@"1"]) {
//        NSButtonCell *cell=[[NSButtonCell alloc] init];
//        //    NSString *strDisplayPlaylistName;
//        //    strDisplayPlaylistName=[playListNameArray objectAtIndex:row];
//        //    [cell setTitle:strDisplayPlaylistName];
//        [cell setAllowsMixedState:YES];
//        [cell setButtonType:NSSwitchButton];
//        [cell setTitle:@""];
//        [cell setEnabled:NO];
//        return cell;
//    }
//    return nil;
//    
//}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn *)column row:(NSInteger)row { 
        Session *_theSession = [currentSessionObjects objectAtIndex:row];

        if ([column.identifier isEqualToString:@"1"]) {
            _theSession.patientSN = value;
        }
        else if ([column.identifier isEqualToString:@"2"]) {
            _theSession.participant = value;
        }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Session *_theSession = [currentSessionObjects objectAtIndex:row];
    if ([tableColumn.identifier isEqualToString:@"1"]) {
        return _theSession.patientSN;
    }
    else if ([tableColumn.identifier isEqualToString:@"2"]) {
        return _theSession.participant;
    }
    
    return nil;
}

- (IBAction)tableViewSelected:(id)sender
{
    NSInteger row = [sender selectedRow];

    if (row < [currentSessionObjects count] && row >= 0) {
        Session *theSession = [currentSessionObjects objectAtIndex:row];
        self.currentSession = theSession;
    }
    
}

- (IBAction)deleteSession:(id)sender
{
    if (currentSession) {
        [currentSessionObjects removeObject:currentSession];
        [managedObjectContext deleteObject:currentSession];
        if ([currentSessionObjects count] > 0) {
            self.currentSession = [currentSessionObjects lastObject];
        }
        else 
            self.currentSession = nil;
    }
}

#pragma mark -
#pragma mark Server

- (IBAction)startServer:(id)sender
{
    
}



@end
