//
//  SearchWindowController.m
//  MimicIIDataBrowser
//
//  Created by zli on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchWindowController.h"
#import "Patient.h"

@implementation SearchWindowController
@synthesize searchField;
@synthesize labTableView;
@synthesize medTableView;
@synthesize ioTableView;
@synthesize miscTableView;
@synthesize medResultArray, labResultArray, miscResultArray, ioResultArray;
@synthesize managedObjectContext;
@synthesize mbwc;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(id)initWithWindowNibName:(NSString *)windowNibName andManagedObjectContext:(NSManagedObjectContext *)_managedObjectContext andMBWC:(MainBrowserWindowController *)_mbwc
{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        self.managedObjectContext = _managedObjectContext;
        self.mbwc = _mbwc;
        
        [self showWindow:nil];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [medResultArray release];
    [labResultArray release];
    [miscResultArray release];
    [ioResultArray release];
    [managedObjectContext release];
    [mbwc release];

}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == labTableView) {
        return [labResultArray count];
    }
    else if (tableView == medTableView) {
        return [medResultArray count];
    }
    else if (tableView == ioTableView) {
        return [ioResultArray count];
    }
    else if (tableView == miscTableView) {
        return [miscResultArray count];
    }
    
    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableView == labTableView) {
        return [labResultArray objectAtIndex:row];
    }
    else if (tableView == medTableView) {
        return [medResultArray objectAtIndex:row];
    }
    else if (tableView == ioTableView) {
        return [ioResultArray objectAtIndex:row];
    }
    else if (tableView == miscTableView) {
        return [miscResultArray objectAtIndex:row];
    }
    
    return nil;
}

#pragma mark - search


- (IBAction)updateFilter:sender
{
    Patient *currentPatient = mbwc.currentPatient;
    NSString *searchString = [searchField stringValue];
    
    if ((currentPatient != nil) && (searchString != nil) && (![searchString isEqualToString:@""]))
    {
        NSError *error;

        NSEntityDescription *labEntityDescription = [NSEntityDescription entityForName:@"LabEvent" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *labRequest = [[[NSFetchRequest alloc] init] autorelease];
        [labRequest setEntity:labEntityDescription];
        
        NSPredicate *labPredicate = [NSPredicate predicateWithFormat:@"patient = %@ && testName contains[cd] %@", currentPatient, searchString];
        [labRequest setPredicate:labPredicate];
        
        self.labResultArray = [[managedObjectContext executeFetchRequest:labRequest error:&error] valueForKeyPath:@"@distinctUnionOfObjects.testName"];
        
        [labTableView reloadData];
        
        //==============================================================
        NSEntityDescription *medEntityDescription = [NSEntityDescription entityForName:@"MedEvent" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *medRequest = [[[NSFetchRequest alloc] init] autorelease];
        [medRequest setEntity:medEntityDescription];
        
        NSPredicate *medPredicate = [NSPredicate predicateWithFormat:@"patient = %@ && category contains[cd] %@", currentPatient, searchString];
        [medRequest setPredicate:medPredicate];
        
        self.medResultArray = [[managedObjectContext executeFetchRequest:medRequest error:&error] valueForKeyPath:@"@distinctUnionOfObjects.category"];
        
        [medTableView reloadData];
        
        //==============================================================
        NSEntityDescription *ioEntityDescription = [NSEntityDescription entityForName:@"IOEvent" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *ioRequest = [[[NSFetchRequest alloc] init] autorelease];
        [ioRequest setEntity:ioEntityDescription];
        
        NSPredicate *ioPredicate = [NSPredicate predicateWithFormat:@"patient = %@ && label contains[cd] %@", currentPatient, searchString];
        [ioRequest setPredicate:ioPredicate];
        
        self.ioResultArray = [[managedObjectContext executeFetchRequest:ioRequest error:&error] valueForKeyPath:@"@distinctUnionOfObjects.label"];
        [ioTableView reloadData];
        
        //==============================================================
        NSEntityDescription *chartEntityDescription = [NSEntityDescription entityForName:@"ChartEvent" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *chartRequest = [[[NSFetchRequest alloc] init] autorelease];
        [chartRequest setEntity:chartEntityDescription];
        
        NSPredicate *chartPredicate = [NSPredicate predicateWithFormat:@"patient = %@ && itemName contains[cd] %@", currentPatient, searchString];
        [chartRequest setPredicate:chartPredicate];
        
        self.miscResultArray = [[managedObjectContext executeFetchRequest:chartRequest error:&error] valueForKeyPath:@"@distinctUnionOfObjects.itemName"];
        
        [miscTableView reloadData];
        
    }
}

- (IBAction)labTableViewSelected:(id)sender
{
    mbwc.evtvc.eventClass = @"LabEvent";
    if ([sender selectedRow] < [labResultArray count]) {
        mbwc.evtvc.eventIdentifier = [labResultArray objectAtIndex:[sender selectedRow]];
    }
    
}

- (IBAction)ioTableViewSelected:(id)sender
{
    mbwc.evtvc.eventClass = @"IOEvent";
    if ([sender selectedRow] < [ioResultArray count]) {
        mbwc.evtvc.eventIdentifier = [ioResultArray objectAtIndex:[sender selectedRow]];
    }
}

- (IBAction)medTableViewSelected:(id)sender
{
    mbwc.evtvc.eventClass = @"MedEvent";
    if ([sender selectedRow] < [medResultArray count]) {
        mbwc.evtvc.eventIdentifier = [medResultArray objectAtIndex:[sender selectedRow]];
    }
}

- (IBAction)miscTableViewSelected:(id)sender
{
    mbwc.evtvc.eventClass = @"ChartEvent";
    if ([sender selectedRow] < [miscResultArray count]) {
        mbwc.evtvc.eventIdentifier = [miscResultArray objectAtIndex:[sender selectedRow]];
    }
}

//// -------------------------------------------------------------------------------
////	allKeywords:
////
////	This method builds our keyword array for use in type completion (dropdown list
////	in NSSearchField).
//// -------------------------------------------------------------------------------
//- (NSArray *)allKeywords
//{
//    NSArray *array = [[[NSArray alloc] init] autorelease];
//    unsigned int i,count;
//    
//    if (allKeywords == nil)
//	{
//        allKeywords = [builtInKeywords mutableCopy];
//        
//        if (array != nil)
//		{
//            count = [array count];
//            for (i=0; i<count; i++)
//			{
//                if ([allKeywords indexOfObject:[array objectAtIndex:i]] == NSNotFound)
//                    [allKeywords addObject:[array objectAtIndex:i]];
//            }
//        }
//        [allKeywords sortUsingSelector:@selector(compare:)];
//    }
//    return allKeywords;
//}
//
//// -------------------------------------------------------------------------------
////	control:textView:completions:forPartialWordRange:indexOfSelectedItem:
////
////	Use this method to override NSFieldEditor's default matches (which is a much bigger
////	list of keywords).  By not implementing this method, you will then get back
////	NSSearchField's default feature.
//// -------------------------------------------------------------------------------
//- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words
// forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(int*)index
//{
//    NSMutableArray*	matches = NULL;
//    NSString*		partialString;
//    NSArray*		keywords;
//    unsigned int	i,count;
//    NSString*		string;
//    
//    partialString = [[textView string] substringWithRange:charRange];
//    
//    
//    
//    
//	return matches;
//}
//
//// -------------------------------------------------------------------------------
////	controlTextDidChange:
////
////	The text in NSSearchField has changed, try to attempt type completion.
//// -------------------------------------------------------------------------------
//- (void)controlTextDidChange:(NSNotification *)obj
//{
//	NSTextView* textView = [[obj userInfo] objectForKey:@"NSFieldEditor"];
//    
//    if (!completePosting && !commandHandling)	// prevent calling "complete" too often
//	{
//        completePosting = YES;
//        [textView complete:nil];
//        completePosting = NO;
//    }
//}
//
//// -------------------------------------------------------------------------------
////	control:textView:commandSelector
////
////	Handle all commend selectors that we can handle here
//// -------------------------------------------------------------------------------
//- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
//{
//    BOOL result = NO;
//	
//	if ([textView respondsToSelector:commandSelector])
//	{
//        commandHandling = YES;
//        [textView performSelector:commandSelector withObject:nil];
//        NSLog(@"enter");
//        commandHandling = NO;
//		
//		result = YES;
//    }
//	
//    return result;
//}




@end
