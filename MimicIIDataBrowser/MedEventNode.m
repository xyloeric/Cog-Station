//
//  MedEventNode.m
//  MimicIIDataBrowser
//
//  Created by zli on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MedEventNode.h"


@implementation MedEventNode
@synthesize routes, individualMedNames;
@synthesize currentRoute;

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
    [routes release];
    [individualMedNames release];
    [currentRoute release];
    [super dealloc];
}

- (void) initializeNode
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MedEvent" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patient == %@", patient];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSArray *uniqueNames;
    uniqueNames = [array valueForKeyPath:@"@distinctUnionOfObjects.route"];
    //uniqueNames = [uniqueNamesUnsorted sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSMutableSet *keyedUniqueNames = [NSMutableSet set];
    
    [uniqueNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:obj, @"displayName", @"route", @"type", nil];
        [keyedUniqueNames addObject:dict];
        
    }];
    
    NSArray *sortedUniqueNames = [[keyedUniqueNames allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 valueForKey:@"displayName"] compare:[obj2 valueForKey:@"displayName"] options:NSCaseInsensitiveSearch];
    }];
    
    self.routes = sortedUniqueNames;
}

- (NSArray *)childrenWithItem:(NSString *)_item
{
    if ([self object1:[_item valueForKey:@"type"] isEqualToString:@"route"]) {
        return individualMedNames;
    }
    else
    {
        return routes;
    }
    
    return nil;

}

- (NSInteger)childrenCountWithItem:(NSString *)_item
{
    if ([self object1:[_item valueForKey:@"type"] isEqualToString:@"route"]) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MedEvent" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patient == %@ && route == %@", patient, [_item valueForKey:@"displayName"]];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
        
        NSArray *uniqueNames;
        uniqueNames = [array valueForKeyPath:@"@distinctUnionOfObjects.category"];
        //uniqueNames = [uniqueNamesUnsorted sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSMutableSet *keyedUniqueNames = [NSMutableSet set];
        
        [uniqueNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:obj, @"displayName", @"individualMedName", @"type", nil];
            [keyedUniqueNames addObject:dict];
            
        }];
        
        NSArray *sortedUniqueNames = [[keyedUniqueNames allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 valueForKey:@"displayName"] compare:[obj2 valueForKey:@"displayName"] options:NSCaseInsensitiveSearch];
        }];
        
        self.individualMedNames = sortedUniqueNames;
        
        self.currentRoute = [_item valueForKey:@"displayName"];
        
        return [individualMedNames count];
    }
    
    else {
        return [routes count];
    }
    
    return 0;
}

- (BOOL) hasChildrenWithItem:(NSString *)_item
{
    if([self object1:[_item valueForKey:@"type"] isEqualToString:@"individualMedName"]) {
        return NO;
    }
    
    return YES;
}

@end
