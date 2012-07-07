//
//  ChartEventNode.m
//  MimicIIDataBrowser
//
//  Created by Eric on 6/14/11.
//  Copyright 2011 UT. All rights reserved.
//

#import "ChartEventNode.h"


@implementation ChartEventNode
@synthesize ChartEventCategories, individualChartEventItems, currentChartEventCategory;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)_managedObjectContext andPatient:(Patient *)_patient
{
    self = [super init];
    if (self) {
        self.managedObjectContext = _managedObjectContext;
        self.patient = _patient;
        
        [self initializeNode];
    }
    
    return self;
}

- (void)dealloc
{
    [ChartEventCategories release];
    [individualChartEventItems release];
    [currentChartEventCategory release];
    [super dealloc];
}

- (void) initializeNode
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChartEvent" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patient == %@", patient];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSArray *uniqueNames;
    uniqueNames = [array valueForKeyPath:@"@distinctUnionOfObjects.category"];
    //uniqueNames = [uniqueNamesUnsorted sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSMutableArray *keyedUniqueNames = [[NSMutableArray alloc] init];
    
    for (id obj in uniqueNames) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:obj, @"displayName", @"category", @"type", nil];
        [keyedUniqueNames addObject:dict];
    }
    
    NSArray *sortedUniqueNames = [keyedUniqueNames sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 valueForKey:@"displayName"] compare:[obj2 valueForKey:@"displayName"] options:NSCaseInsensitiveSearch];
    }];
    
    self.ChartEventCategories = sortedUniqueNames;
    [keyedUniqueNames release];
}

- (NSArray *)childrenWithItem:(NSString *)_item
{
    if ([self object1:[_item valueForKey:@"type"] isEqualToString:@"category"]) {
        return individualChartEventItems;
    }
    else
    {
        return ChartEventCategories;
    }
    
    return nil;
    
}

- (NSInteger)childrenCountWithItem:(NSString *)_item
{
    if ([self object1:[_item valueForKey:@"type"] isEqualToString:@"category"]) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChartEvent" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patient == %@ && category == %@", patient, [_item valueForKey:@"displayName"]];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
        
        NSArray *uniqueNames;
        uniqueNames = [array valueForKeyPath:@"@distinctUnionOfObjects.itemName"];
        //uniqueNames = [uniqueNamesUnsorted sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        
        NSMutableArray *keyedUniqueNames = [[NSMutableArray alloc] init];
        
        for (id obj in uniqueNames) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:obj, @"displayName", @"individualChartEventItem", @"type", nil];
            [keyedUniqueNames addObject:dict];
        }
        
        NSArray *sortedUniqueNames = [keyedUniqueNames sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 valueForKey:@"displayName"] compare:[obj2 valueForKey:@"displayName"] options:NSCaseInsensitiveSearch];
        }];
        
        
        self.individualChartEventItems = sortedUniqueNames;
        
        [keyedUniqueNames release];
        
        self.currentChartEventCategory = [_item valueForKey:@"displayName"];
        
        return [individualChartEventItems count];
    }
    
    else {
        return [ChartEventCategories count];
    }
    
    return 0;
}

- (BOOL) hasChildrenWithItem:(NSString *)_item
{
    if([self object1:[_item valueForKey:@"type"] isEqualToString:@"individualChartEventItem"]) {
        return NO;
    }
    
    return YES;
}


@end
