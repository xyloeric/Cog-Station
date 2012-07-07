//
//  Patient.m
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright (c) 2011 UTHealth. All rights reserved.
//

#import "Patient.h"
#import "ChartConcept.h"
#import "ChartEvent.h"
#import "IOConcept.h"
#import "IOEvent.h"
#import "LabConcept.h"
#import "LabEvent.h"
#import "MedConcept.h"
#import "MedEvent.h"


@implementation Patient

@dynamic eventEnd;
@dynamic patientID;
@dynamic comment;
@dynamic patientSex;
@dynamic eventStart;
@dynamic patientDOB;
@dynamic patientDOD;
@dynamic ioConcepts;
@dynamic labConcepts;
@dynamic chartConcepts;
@dynamic ioEvents;
@dynamic medEvents;
@dynamic labEvents;
@dynamic chartEvents;
@dynamic medConcepts;

@end
