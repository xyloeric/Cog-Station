//
//  ChartEventTableViewController.m
//  MimicIIDataBrowser
//
//  Created by Eric on 6/16/11.
//  Copyright 2011 UT. All rights reserved.
//

#import "ChartEventTableViewController.h"
#import "MainBrowserWindowController.h"
#import "EventViewTableViewController.h"

#import "ChartConcept.h"

#import "TermEditorController.h"

@implementation ChartEventTableViewController
@synthesize cen;
@synthesize previousPath;
@synthesize termEditorPopover;

-(void)awakeFromNib
{
    [((NSBrowser *)self.view) setDoubleAction:@selector(handleDoubleClick:)];
}

-(void)dealloc
{
    [cen release];
    [previousPath release];
    [termEditorPopover release];
    [super dealloc];
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item {
    return [cen childrenCountWithItem:item];
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item {
    NSArray *children = [cen childrenWithItem:item];
    return [children objectAtIndex:index];
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item {
    return ![cen hasChildrenWithItem:item];
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item {
    return [item valueForKey:@"displayName"];
}


-(IBAction)clicked:(id)sender
{
    if ([(NSBrowser *)sender clickedColumn] == 1) {
        NSString *path = [(NSBrowser *)sender path];
        mbwc.evtvc.eventClass = @"ChartEvent";
        //NSLog(@"%@", previousPath);
        if ([path length] > [self.previousPath length]) {
            mbwc.evtvc.eventIdentifier = [path substringFromIndex:[self.previousPath length]+1];
        }
        //        if ([[path pathComponents] count] == 3) {
        //            mbwc.evtvc.eventIdentifier = [path lastPathComponent];
        //        }
        //        else if([[path pathComponents] count] == 4) {
        //            mbwc.evtvc.eventIdentifier = [NSString stringWithFormat:@"%@/%@", [[path pathComponents] objectAtIndex:2], [[path pathComponents] objectAtIndex:3]]; 
        //        }
    }
    else if([(NSBrowser *)sender clickedColumn] == 0) {
        self.previousPath = [(NSBrowser *)sender path];
    }
}

- (void)refreshTableViewWithPatient:(Patient *)_patient
{
    ChartEventNode *chartEventNode = [[ChartEventNode alloc] initWithManagedObjectContext:self.managedObjectContext andPatient:_patient];
    self.cen = chartEventNode;
    [chartEventNode release];
    
    [(NSBrowser *)self.view reloadColumn:0];
    [(NSBrowser *)self.view reloadColumn:1];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentPatient"]) {
        Patient *newPatient = [change objectForKey:@"new"];
        
        ChartEventNode *chartEventNode = [[ChartEventNode alloc] initWithManagedObjectContext:self.managedObjectContext andPatient:newPatient];
        self.cen = chartEventNode;
        [chartEventNode release];
        
        [(NSBrowser *)self.view reloadColumn:0];
        [(NSBrowser *)self.view reloadColumn:1];
    }
    else
    {
        
    }
    
}

- (void) handleDoubleClick:(id)sender
{
    @autoreleasepool {
        ChartConcept *result;
        NSBrowser *browser = sender;
        if ([browser clickedColumn] == 1) {
            NSString *path = [(NSBrowser *)sender path];
            if ([path length] > [self.previousPath length]) {
                result = [self getChartConceptWithName:[path substringFromIndex:[self.previousPath length]+1]];
                if (result) {
                    NSLog(@"%@", result.mimiciiTerm);
                    NSRect clickedRect = [browser frameOfRow:browser.clickedRow inColumn:browser.clickedColumn];
                    [self showPopupDataRendererFromRect:clickedRect withConcept:result];
                }
            }
            
        }

    }
   
}

- (ChartConcept *)getChartConceptWithName:(NSString *)_name
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChartConcept" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mimiciiTerm == %@", _name];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    
    ChartConcept *result;
    
    if ([array count] > 0) {
        result = [array objectAtIndex:0];
    }
    else {
        result = nil;
    }
    
    return result;
}

#pragma mark - 
#pragma mark Term Editor

- (void)showPopupDataRendererFromRect:(NSRect)_rect withConcept:(ChartConcept *)_concept
{
    if (termEditorPopover) {
        [termEditorPopover performClose:nil];
    }
    
    TermEditorController *termEditorController = [[[TermEditorController alloc] initWithNibName:@"TermEditorController" bundle:nil conceptObject:_concept andConceptType:kConceptTypeChart] autorelease];
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
