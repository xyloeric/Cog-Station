//
//  LabEventNode.m
//  MimicIIDataBrowser
//
//  Created by zli on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LabEventNode.h"
#import "LabEvent.h"


@implementation LabEventNode
@synthesize sampleTypes, categories, individualTestNames;
@synthesize currentCategory, currentSampleType;
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
    [sampleTypes release];
    [categories release];
    [individualTestNames release];
    [currentCategory release];
    [currentSampleType release];
    [super dealloc];
}

- (void) initializeNode
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LabEvent" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patient == %@", patient];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSArray *uniqueNames;
    uniqueNames = [array valueForKeyPath:@"@distinctUnionOfObjects.sampleType"];
    //uniqueNames = [uniqueNamesUnsorted sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSMutableSet *keyedUniqueNames = [NSMutableSet set];
    
    [uniqueNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:obj, @"displayName", @"sampleType", @"type", nil];
        [keyedUniqueNames addObject:dict];
        
    }];
    
    NSArray *sortedUniqueNames = [[keyedUniqueNames allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 valueForKey:@"displayName"] compare:[obj2 valueForKey:@"displayName"] options:NSCaseInsensitiveSearch];
    }];
    
    self.sampleTypes = sortedUniqueNames;
   
}

- (NSArray *)childrenWithItem:(NSString *)_item
{
    if ([self object1:[_item valueForKey:@"type"] isEqualToString:@"sampleType"]) {
        return categories;
    }
    
    else if([self object1:[_item valueForKey:@"type"] isEqualToString:@"category"]) {
        return individualTestNames;
    }
    
    else
    {
        return sampleTypes;
    }
    
    return nil;
    
}

- (NSInteger)childrenCountWithColNum:(NSInteger)_column
{
    if (_column == 0) {
        return [sampleTypes count];
    }
    if (_column == 1) {
        return [categories count];
    }
    else if(_column == 2) {
        return [individualTestNames count];
    }
    
    return 0;
}

- (NSInteger)childrenCountWithItem:(NSString *)_item
{
    
    if ([self object1:[_item valueForKey:@"type"] isEqualToString:@"sampleType"]) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LabEvent" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patient == %@ && sampleType == %@", patient, [_item valueForKey:@"displayName"]];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
        
        NSArray *uniqueNames;
        uniqueNames = [array valueForKeyPath:@"@distinctUnionOfObjects.category"];
        //uniqueNames = [uniqueNamesUnsorted sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSMutableSet *keyedUniqueNames = [NSMutableSet set];
        
        [uniqueNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:obj, @"displayName", @"category", @"type", nil];
            [keyedUniqueNames addObject:dict];
            
        }];
        
        NSArray *sortedUniqueNames = [[keyedUniqueNames allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 valueForKey:@"displayName"] compare:[obj2 valueForKey:@"displayName"] options:NSCaseInsensitiveSearch];
        }];
        
        self.categories = sortedUniqueNames;
                
        self.currentSampleType = [_item valueForKey:@"displayName"];
        
        return [categories count];
    }
    
    else if([self object1:[_item valueForKey:@"type"] isEqualToString:@"category"]) {
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LabEvent" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patient == %@ && sampleType == %@ && category == %@", patient, currentSampleType, [_item valueForKey:@"displayName"]];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
        
        NSArray *uniqueNames;
        uniqueNames = [array valueForKeyPath:@"@distinctUnionOfObjects.testName"];
        //uniqueNames = [uniqueNamesUnsorted sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        __block NSMutableSet *keyedUniqueNames = [NSMutableSet set];
        
        [uniqueNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:obj, @"displayName", @"individualTestName", @"type", nil];
            [keyedUniqueNames addObject:dict];
            
        }];
        
        NSArray *sortedUniqueNames = [[keyedUniqueNames allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 valueForKey:@"displayName"] compare:[obj2 valueForKey:@"displayName"] options:NSCaseInsensitiveSearch];
        }];
        
        self.individualTestNames = sortedUniqueNames;
        
        
        
        self.currentCategory = [_item valueForKey:@"displayName"];
        
        return [individualTestNames count];
    }
    
    else {
        return [sampleTypes count];
    }
    return 0;
}

- (BOOL) hasChildrenWithItem:(NSString *)_item
{
    if([self object1:[_item valueForKey:@"type"] isEqualToString:@"individualTestName"]) {
        return NO;
    }
    
    return YES;
}





@end
