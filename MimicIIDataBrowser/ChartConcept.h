//
//  ChartConcept.h
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright (c) 2011 UTHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Concept.h"

@class ChartEvent, Patient;

@interface ChartConcept : Concept

@property (nonatomic, retain) NSSet *hasChartEvents;
@property (nonatomic, retain) NSSet *patient;
@end

@interface ChartConcept (CoreDataGeneratedAccessors)

- (void)addHasChartEventsObject:(ChartEvent *)value;
- (void)removeHasChartEventsObject:(ChartEvent *)value;
- (void)addHasChartEvents:(NSSet *)values;
- (void)removeHasChartEvents:(NSSet *)values;

- (void)addPatientObject:(Patient *)value;
- (void)removePatientObject:(Patient *)value;
- (void)addPatient:(NSSet *)values;
- (void)removePatient:(NSSet *)values;

@end
