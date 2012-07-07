//
//  MedTableViewController.m
//  MimicIIDataBrowser
//
//  Created by zli on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MedTableViewController.h"
#import "MainBrowserWindowController.h"
#import "EventViewTableViewController.h"
#import "MedConcept.h"
#import "TermEditorController.h"

@implementation MedTableViewController
@synthesize men;
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
    [men release];
    [termEditorPopover release];
    [super dealloc];
}

- (void)viewDidLoad
{
    
}

- (IBAction)tableViewSelected:(id)sender
{
    mbwc.evtvc.eventClass = @"MedEvent";
    mbwc.evtvc.eventIdentifier = [eventsNameArray objectAtIndex:[sender selectedRow]];
}

// This method is optional, but makes the code much easier to understand
//- (id)rootItemForBrowser:(NSBrowser *)browser {
//    //return men.routes;
//}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item {
    return [men childrenCountWithItem:item];
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item {
    NSArray *children = [men childrenWithItem:item];
    return [children objectAtIndex:index];
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item {
    return ![men hasChildrenWithItem:item];
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item {
    return [item valueForKey:@"displayName"];
}


-(IBAction)clicked:(id)sender
{
    if ([(NSBrowser *)sender clickedColumn] == 1) {
        NSString *path = [(NSBrowser *)sender path];
        
        if ([[path pathComponents] count] > 2) {
            
            mbwc.evtvc.eventClass = @"MedEvent";
            mbwc.evtvc.eventIdentifier = path;
        }
        //[mbwc.objectPathLabel setStringValue:path];

     //   NSLog(@"%@", [path lastPathComponent]);
    }
}

- (void)refreshTableViewWithPatient:(Patient *)_patient
{
    MedEventNode *medEventNode = [[MedEventNode alloc] initWithManagedObjectContext:self.managedObjectContext andPatient:_patient];
    self.men = medEventNode;
    [medEventNode release];
    
    [(NSBrowser *)self.view reloadColumn:0];
    [(NSBrowser *)self.view reloadColumn:1];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentPatient"]) {
        Patient *newPatient = [change objectForKey:@"new"];
        
        MedEventNode *medEventNode = [[MedEventNode alloc] initWithManagedObjectContext:self.managedObjectContext andPatient:newPatient];
        self.men = medEventNode;
        [medEventNode release];
        
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
        
        if ([[path pathComponents] count] > 2) {
            MedConcept *result = [self getMedConceptWithName:[[path pathComponents] objectAtIndex:2] andRoute:[[path pathComponents] objectAtIndex:1]];
            
            if (result) {
                NSLog(@"%@, %@", result.mimiciiTerm, result.route);
                NSRect clickedRect = [browser frameOfRow:browser.clickedRow inColumn:browser.clickedColumn];
                [self showPopupDataRendererFromRect:clickedRect withConcept:result];
                
            }
        }
       
        
       
    }
}

- (MedConcept *)getMedConceptWithName:(NSString *)_name andRoute:(NSString *)_route
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MedConcept" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mimiciiTerm == %@ && route == %@", _name, _route];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    
    MedConcept *result;
    
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

- (void)showPopupDataRendererFromRect:(NSRect)_rect withConcept:(MedConcept *)_concept
{
    if (termEditorPopover) {
        [termEditorPopover performClose:nil];
    }
    
    TermEditorController *termEditorController = [[[TermEditorController alloc] initWithNibName:@"TermEditorController" bundle:nil conceptObject:_concept andConceptType:kConceptTypeMed] autorelease];
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
