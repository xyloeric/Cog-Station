//
//  IOConcept.h
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright (c) 2011 UTHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Concept.h"

@class IOEvent, Patient;

@interface IOConcept : Concept

@property (nonatomic, retain) NSSet *hasIOEvents;
@property (nonatomic, retain) NSSet *patient;
@end

@interface IOConcept (CoreDataGeneratedAccessors)

- (void)addHasIOEventsObject:(IOEvent *)value;
- (void)removeHasIOEventsObject:(IOEvent *)value;
- (void)addHasIOEvents:(NSSet *)values;
- (void)removeHasIOEvents:(NSSet *)values;

- (void)addPatientObject:(Patient *)value;
- (void)removePatientObject:(Patient *)value;
- (void)addPatient:(NSSet *)values;
- (void)removePatient:(NSSet *)values;

@end
