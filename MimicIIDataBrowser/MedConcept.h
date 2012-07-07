//
//  MedConcept.h
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright (c) 2011 UTHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Concept.h"

@class MedEvent, Patient;

@interface MedConcept : Concept

@property (nonatomic, retain) NSString * route;
@property (nonatomic, retain) NSSet *hasMedEvents;
@property (nonatomic, retain) NSSet *patient;
@end

@interface MedConcept (CoreDataGeneratedAccessors)

- (void)addHasMedEventsObject:(MedEvent *)value;
- (void)removeHasMedEventsObject:(MedEvent *)value;
- (void)addHasMedEvents:(NSSet *)values;
- (void)removeHasMedEvents:(NSSet *)values;

- (void)addPatientObject:(Patient *)value;
- (void)removePatientObject:(Patient *)value;
- (void)addPatient:(NSSet *)values;
- (void)removePatient:(NSSet *)values;

@end
