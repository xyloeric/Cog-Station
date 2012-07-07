//
//  LabTableViewController.m
//  MimicIIDataBrowser
//
//  Created by Eric Li on 6/2/11.
//  Copyright 2011 UTH. All rights reserved.
//

#import "LabTableViewController.h"
#import "EventViewTableViewController.h"
#import "MainBrowserWindowController.h"
#import "Patient.h"
#import "LabConcept.h"

#import "TermEditorController.h"
@implementation LabTableViewController
@synthesize len;
@synthesize termEditorPopover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
    [((NSBrowser *)self.view) setDoubleAction:@selector(handleDoubleClick:)];
}


- (void)dealloc
{
    [len release];
    [termEditorPopover release];
   // [((NSBrowser *)self.view) removeObserver:self forKeyPath:@"selectedCell"];
    [super dealloc];
}


- (IBAction)tableViewSelected:(id)sender
{
    mbwc.evtvc.eventClass = @"LabEvent";
    mbwc.evtvc.eventIdentifier = [eventsNameArray objectAtIndex:[sender selectedRow]];
}

// This method is optional, but makes the code much easier to understand
- (id)rootItemForBrowser:(NSBrowser *)browser {
    return len.sampleTypes;
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item {
    return [len childrenCountWithItem:item];
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item {
    NSArray *children = [len childrenWithItem:item];
    return [children objectAtIndex:index];
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item {
    return ![len hasChildrenWithItem:item];
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item {
    
    return [item valueForKey:@"displayName"];
}


-(IBAction)clicked:(id)sender
{
    if ([(NSBrowser *)sender clickedColumn] == 2) {
        
        NSString *path = [(NSBrowser *)sender path];
        if ([[path pathComponents] count] > 3) {
            
            mbwc.evtvc.eventClass = @"LabEvent";
            mbwc.evtvc.eventIdentifier = path;
        }
        //[mbwc.objectPathLabel setStringValue:path];

    }
}

- (void)refreshTableViewWithPatient:(Patient *)_patient
{
    LabEventNode *labEventNode = [[LabEventNode alloc] initWithManagedObjectContext:self.managedObjectContext andPatient:_patient];
    self.len = labEventNode;
    [labEventNode release];
    
    [(NSBrowser *)self.view reloadColumn:0];
    [(NSBrowser *)self.view reloadColumn:1];
    [(NSBrowser *)self.view reloadColumn:2];
}

//- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column {
//    return [len childrenCountWithColNum:column];
//}
//
//- (void)browser:(NSBrowser *)sender willDisplayCell:(NSBrowserCell *)cell atRow:(NSInteger)row column:(NSInteger)column {
//    // Lazily setup the cell's properties in this method
//    
//}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentPatient"]) {
        Patient *newPatient = [change objectForKey:@"new"];
        
        LabEventNode *labEventNode = [[LabEventNode alloc] initWithManagedObjectContext:self.managedObjectContext andPatient:newPatient];
        self.len = labEventNode;
        [labEventNode release];
        
        [(NSBrowser *)self.view reloadColumn:0];
        [(NSBrowser *)self.view reloadColumn:1];
        [(NSBrowser *)self.view reloadColumn:2];
    }
    else
    {
      ///  NSLog(@"%@", keyPath);
    }
    
}

- (void) handleDoubleClick:(id)sender
{
    NSBrowser *browser = (NSBrowser *)sender;
    if ([browser clickedColumn] == 2) {
        NSString *path = [(NSBrowser *)sender path];
        NSLog(@"%@", path);
        
        if ([[path pathComponents] count] > 3) {
            
            LabConcept *clickedConcept = [self getLabConceptWithName:[[path pathComponents] objectAtIndex:3] andSampleType:[[path pathComponents] objectAtIndex:1]];
            
            if (clickedConcept) {
                NSLog(@"%@, %@", clickedConcept.mimiciiTerm, clickedConcept.sampleType);
                NSRect clickedRect = [browser frameOfRow:browser.clickedRow inColumn:browser.clickedColumn];
                [self showPopupDataRendererFromRect:clickedRect withConcept:clickedConcept];
            }
            
        }
        
       

    }
}

- (LabConcept *)getLabConceptWithName:(NSString *)_name andSampleType:(NSString *)_sampleType
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LabConcept" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mimiciiTerm == %@ && sampleType == %@", _name, _sampleType];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    
    LabConcept *result;
    
    if ([array count] > 0) {
        result = [array objectAtIndex:0];
    }
    else
    {
        result = nil;
    }
        
    return result;
}

#pragma mark - 
#pragma mark Term Editor

- (void)showPopupDataRendererFromRect:(NSRect)_rect withConcept:(LabConcept *)_concept
{
    if (termEditorPopover) {
        [termEditorPopover performClose:nil];
    }
    
    TermEditorController *termEditorController = [[[TermEditorController alloc] initWithNibName:@"TermEditorController" bundle:nil conceptObject:_concept andConceptType:kConceptTypeLab] autorelease];
    NSPopover *popover = [[[NSPopover alloc] init] autorelease];
    self.termEditorPopover = popover;
    
    termEditorPopover.delegate = self;
    [termEditorPopover setContentViewController:termEditorController];
    termEditorController.containerPopover = termEditorPopover;
    //[termEditorPopover release];
    
    [termEditorPopover showRelativeToRect:_rect ofView:self.view preferredEdge:NSMaxXEdge];
    
}

- (void)popoverDidClose:(NSNotification *)notification
{
    NSLog(@"%@", notification);
}

- (BOOL)popoverShouldClose:(NSPopover *)popover
{
    return YES;
}

@end
