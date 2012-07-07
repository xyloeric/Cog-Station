//
//  Node.m
//  MimicIIDataBrowser
//
//  Created by zli on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Node.h"


@implementation Node
@synthesize managedObjectContext;
@synthesize patient;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)_managedObjectContext andPatient:(Patient *)_patient
{
    self = [super init];
    if (self) {
        self.managedObjectContext = _managedObjectContext;
        self.patient = _patient;
    }
    
    return self;
}

- (void)dealloc
{
    [managedObjectContext release];
    [patient release];
    [super dealloc];
}

- (void) initializeNode
{
    
}

- (BOOL) object1:(id)obj1 isEqualToString:(NSString *)_string
{
    if ([obj1 respondsToSelector:@selector(isEqualToString:)]) {
        return [obj1 isEqualToString:_string];
    }
    return NO;
}
@end
