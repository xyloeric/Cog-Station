//
//  LabConcept.h
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright (c) 2011 UTHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Concept.h"

@class LabEvent, Patient;

@interface LabConcept : Concept

@property (nonatomic, retain) NSString * sampleType;
@property (nonatomic, retain) NSSet *hasLabEvents;
@property (nonatomic, retain) NSSet *patient;
@end

@interface LabConcept (CoreDataGeneratedAccessors)

- (void)addHasLabEventsObject:(LabEvent *)value;
- (void)removeHasLabEventsObject:(LabEvent *)value;
- (void)addHasLabEvents:(NSSet *)values;
- (void)removeHasLabEvents:(NSSet *)values;

- (void)addPatientObject:(Patient *)value;
- (void)removePatientObject:(Patient *)value;
- (void)addPatient:(NSSet *)values;
- (void)removePatient:(NSSet *)values;

@end
