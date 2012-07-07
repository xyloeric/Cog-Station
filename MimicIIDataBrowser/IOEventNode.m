//
//  IOEventNode.m
//  MimicIIDataBrowser
//
//  Created by zli on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IOEventNode.h"


@implementation IOEventNode
@synthesize IOCategories, individualIOItems;
@synthesize currentIOCategory;

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
    [IOCategories release];
    [individualIOItems release];
    [currentIOCategory release];
    [super dealloc];
}

- (void) initializeNode
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IOEvent" inManagedObjectContext:managedObjectContext];
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
    
    self.IOCategories = sortedUniqueNames;
    [keyedUniqueNames release];
}

- (NSArray *)childrenWithItem:(NSString *)_item
{
    if ([self object1:[_item valueForKey:@"type"] isEqualToString:@"category"]) {
        return individualIOItems;
    }
    else
    {
        return IOCategories;
    }
    
    return nil;
    
}

- (NSInteger)childrenCountWithItem:(NSString *)_item
{
    if ([self object1:[_item valueForKey:@"type"] isEqualToString:@"category"]) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IOEvent" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patient == %@ && category == %@", patient, [_item valueForKey:@"displayName"]];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
        
        NSArray *uniqueNames;
        uniqueNames = [array valueForKeyPath:@"@distinctUnionOfObjects.label"];
        //uniqueNames = [uniqueNamesUnsorted sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        
        NSMutableArray *keyedUniqueNames = [[NSMutableArray alloc] init];
        
        for (id obj in uniqueNames) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:obj, @"displayName", @"individualIOItem", @"type", nil];
            [keyedUniqueNames addObject:dict];
        }
        
        NSArray *sortedUniqueNames = [keyedUniqueNames sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 valueForKey:@"displayName"] compare:[obj2 valueForKey:@"displayName"] options:NSCaseInsensitiveSearch];
        }];

        
        self.individualIOItems = sortedUniqueNames;
        
        [keyedUniqueNames release];
        
        self.currentIOCategory = [_item valueForKey:@"displayName"];
        
        return [individualIOItems count];
    }
    
    else {
        return [IOCategories count];
    }
    
    return 0;
}

- (BOOL) hasChildrenWithItem:(NSString *)_item
{
    if([self object1:[_item valueForKey:@"type"] isEqualToString:@"individualIOItem"]) {
        return NO;
    }
    
    return YES;
}


@end
