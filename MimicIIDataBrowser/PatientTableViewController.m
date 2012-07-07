//
//  PatientTableViewController.m
//  MimicIIDataBrowser
//
//  Created by zli on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PatientTableViewController.h"
#import "Patient.h"
#import "MainBrowserWindowController.h"
#import "IOConcept.h"
#import "DDLog.h"

@implementation PatientTableViewController
@synthesize patientBrowserTable;
@synthesize mbwc;
@synthesize managedObjectContext;
@synthesize patientArray;

static const int ddLogLevel = LOG_LEVEL_VERBOSE;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [managedObjectContext release];
    [patientArray release];
    [mbwc release];
    [super dealloc];
}

- (void)awakeFromNib
{
    
}

- (void)testQuery
{
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Patient" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    self.patientArray = array;
    
    [(NSTableView *)self.view reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [patientArray count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [(Patient *)[patientArray objectAtIndex:row] patientID];
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}

- (IBAction)tableViewSelected:(id)sender
{
    NSInteger row = [sender selectedRow];
    Patient *selectedPatient = [patientArray objectAtIndex:row];
    NSUInteger sum = [selectedPatient.ioConcepts count] + [selectedPatient.medConcepts count] + [selectedPatient.labConcepts count] + [selectedPatient.chartConcepts count];
    DDLogVerbose(@"%ld", sum);
    mbwc.currentPatient = selectedPatient;
}
@end
