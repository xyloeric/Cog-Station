//
//  IOTableViewController.m
//  MimicIIDataBrowser
//
//  Created by Eric Li on 6/2/11.
//  Copyright 2011 UTH. All rights reserved.
//

#import "IOTableViewController.h"
#import "MainBrowserWindowController.h"
#import "EventViewTableViewController.h"
#import "IOConcept.h"

#import "TermEditorController.h"

@implementation IOTableViewController
@synthesize ien;
@synthesize previousPath;
@synthesize termEditorPopover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)awakeFromNib
{
    [((NSBrowser *)self.view) setDoubleAction:@selector(handleDoubleClick:)];

}

- (void)dealloc
{
    [previousPath release];
    [termEditorPopover release];
    [ien release];
    [super dealloc];
}

- (IBAction)tableViewSelected:(id)sender
{
    mbwc.evtvc.eventClass = @"IOEvent";
    mbwc.evtvc.eventIdentifier = [eventsNameArray objectAtIndex:[sender selectedRow]];
}

// This method is optional, but makes the code much easier to understand
//- (id)rootItemForBrowser:(NSBrowser *)browser {
//    return ien.IOCategories;
//}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item {
    return [ien childrenCountWithItem:item];
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item {
    NSArray *children = [ien childrenWithItem:item];
    return [children objectAtIndex:index];
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item {
    return ![ien hasChildrenWithItem:item];
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item {
    return [item valueForKey:@"displayName"];
}


-(IBAction)clicked:(id)sender
{
    if ([(NSBrowser *)sender clickedColumn] == 1) {
        NSString *path = [(NSBrowser *)sender path];
        mbwc.evtvc.eventClass = @"IOEvent";
      //  NSLog(@"%@", previousPath);
        if([path length] > [self.previousPath length])
        {
            mbwc.evtvc.eventIdentifier = [path substringFromIndex:[self.previousPath length]+1];
        }
        //[mbwc.objectPathLabel setStringValue:path];

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
    IOEventNode *ioEventNode = [[IOEventNode alloc] initWithManagedObjectContext:self.managedObjectContext andPatient:_patient];
    self.ien = ioEventNode;
    [ioEventNode release];
    
    [(NSBrowser *)self.view reloadColumn:0];
    [(NSBrowser *)self.view reloadColumn:1];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentPatient"]) {
        Patient *newPatient = [change objectForKey:@"new"];
        
        IOEventNode *ioEventNode = [[IOEventNode alloc] initWithManagedObjectContext:self.managedObjectContext andPatient:newPatient];
        self.ien = ioEventNode;
        [ioEventNode release];
        
        [(NSBrowser *)self.view reloadColumn:0];
        [(NSBrowser *)self.view reloadColumn:1];
    }
    else
    {
        
    }
    
}


- (void) handleDoubleClick:(id)sender
{
    NSBrowser *browser = (NSBrowser *)sender;
    if ([browser clickedColumn] == 1) {
        NSString *path = [(NSBrowser *)sender path];
        if([path length] > [self.previousPath length])
        {
            IOConcept *result = [self getIOConceptWithName:[path substringFromIndex:[self.previousPath length]+1]];
            
            if (result) {
                NSLog(@"%@", result.mimiciiTerm);
                
                NSRect clickedRect = [browser frameOfRow:browser.clickedRow inColumn:browser.clickedColumn];
                [self showPopupDataRendererFromRect:clickedRect withConcept:result];
            }
            

        }
    }

}

- (IOConcept *)getIOConceptWithName:(NSString *)_name
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IOConcept" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mimiciiTerm == %@", _name];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    
    IOConcept *result;
    
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

- (void)showPopupDataRendererFromRect:(NSRect)_rect withConcept:(IOConcept *)_concept
{
    if (termEditorPopover) {
        [termEditorPopover performClose:nil];
    }
    
    TermEditorController *termEditorController = [[[TermEditorController alloc] initWithNibName:@"TermEditorController" bundle:nil conceptObject:_concept andConceptType:kConceptTypeIO] autorelease];
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
