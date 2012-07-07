//
//  TermBrowserController.m
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright 2011 UTHealth. All rights reserved.
//

#import "TermBrowserController.h"
#import "Concept.h"

@implementation TermBrowserController
@synthesize managedObjectContext;
@synthesize conceptArray;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [managedObjectContext release];
    [conceptArray release];
    [super dealloc];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)_managedObjectContext
{
    if (_managedObjectContext != managedObjectContext) {
        [managedObjectContext release];
        managedObjectContext = nil;
        managedObjectContext = [_managedObjectContext retain];
        
        [self setUpContent];
    }
}

- (void) setUpContent
{
    @autoreleasepool {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Concept" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entityDescription];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"mimiciiTerm" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [request setSortDescriptors:sortDescriptors];
        
        NSError *error;
        NSArray *_array = [managedObjectContext executeFetchRequest:request error:&error];
        self.conceptArray = _array;
        
        [tableView reloadData];
    }
}

- (IBAction)refresh:(id)sender
{
    [tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    [conceptCount setStringValue:[NSString stringWithFormat:@"%lu", [conceptArray count]]];
    return [conceptArray count];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn *)column row:(NSInteger)row {
    if ([column.identifier isEqualToString:@"2"]) {
        Concept *_concept = [conceptArray objectAtIndex:row];
        [_concept setValue:value forKey:@"preferredTerm"];
    }
    
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Concept *_concept = [conceptArray objectAtIndex:row];
    if ([tableColumn.identifier isEqualToString:@"1"]) {
        if ([_concept respondsToSelector:@selector(route)]) {
            return [NSString stringWithFormat:@"%@, %@", [_concept valueForKey:@"mimiciiTerm"],[_concept valueForKey:@"route"]];
        }
        if ([_concept respondsToSelector:@selector(sampleType)]) {
            return [NSString stringWithFormat:@"%@, %@", [_concept valueForKey:@"mimiciiTerm"],[_concept valueForKey:@"sampleType"]];
        }
        return [_concept valueForKey:@"mimiciiTerm"];
    }
    else {
        return [_concept valueForKey:@"preferredTerm"];
    }
    return nil;
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableColumn.identifier isEqualToString:@"2"]) {
        return YES;
    }
    return NO;
}

-(void)tableView:(NSTableView *)_tableView sortDescriptorsDidChange: (NSArray *)oldDescriptors 
{       
    NSArray *newDescriptors = [_tableView sortDescriptors];
    self.conceptArray = [conceptArray sortedArrayUsingDescriptors:newDescriptors]; 
    //"results" is my NSMutableArray which is set to be the data source for the NSTableView object.
    [_tableView reloadData]; 
}


@end
