//
//  Patient.h
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright (c) 2011 UTHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChartConcept, ChartEvent, IOConcept, IOEvent, LabConcept, LabEvent, MedConcept, MedEvent;

@interface Patient : NSManagedObject

@property (nonatomic, retain) NSDate * eventEnd;
@property (nonatomic, retain) NSString * patientID;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * patientSex;
@property (nonatomic, retain) NSDate * eventStart;
@property (nonatomic, retain) NSString * patientDOB;
@property (nonatomic, retain) NSString * patientDOD;
@property (nonatomic, retain) NSSet *ioConcepts;
@property (nonatomic, retain) NSSet *labConcepts;
@property (nonatomic, retain) NSSet *chartConcepts;
@property (nonatomic, retain) NSSet *ioEvents;
@property (nonatomic, retain) NSSet *medEvents;
@property (nonatomic, retain) NSSet *labEvents;
@property (nonatomic, retain) NSSet *chartEvents;
@property (nonatomic, retain) NSSet *medConcepts;
@end

@interface Patient (CoreDataGeneratedAccessors)

- (void)addIoConceptsObject:(IOConcept *)value;
- (void)removeIoConceptsObject:(IOConcept *)value;
- (void)addIoConcepts:(NSSet *)values;
- (void)removeIoConcepts:(NSSet *)values;

- (void)addLabConceptsObject:(LabConcept *)value;
- (void)removeLabConceptsObject:(LabConcept *)value;
- (void)addLabConcepts:(NSSet *)values;
- (void)removeLabConcepts:(NSSet *)values;

- (void)addChartConceptsObject:(ChartConcept *)value;
- (void)removeChartConceptsObject:(ChartConcept *)value;
- (void)addChartConcepts:(NSSet *)values;
- (void)removeChartConcepts:(NSSet *)values;

- (void)addIoEventsObject:(IOEvent *)value;
- (void)removeIoEventsObject:(IOEvent *)value;
- (void)addIoEvents:(NSSet *)values;
- (void)removeIoEvents:(NSSet *)values;

- (void)addMedEventsObject:(MedEvent *)value;
- (void)removeMedEventsObject:(MedEvent *)value;
- (void)addMedEvents:(NSSet *)values;
- (void)removeMedEvents:(NSSet *)values;

- (void)addLabEventsObject:(LabEvent *)value;
- (void)removeLabEventsObject:(LabEvent *)value;
- (void)addLabEvents:(NSSet *)values;
- (void)removeLabEvents:(NSSet *)values;

- (void)addChartEventsObject:(ChartEvent *)value;
- (void)removeChartEventsObject:(ChartEvent *)value;
- (void)addChartEvents:(NSSet *)values;
- (void)removeChartEvents:(NSSet *)values;

- (void)addMedConceptsObject:(MedConcept *)value;
- (void)removeMedConceptsObject:(MedConcept *)value;
- (void)addMedConcepts:(NSSet *)values;
- (void)removeMedConcepts:(NSSet *)values;

@end
