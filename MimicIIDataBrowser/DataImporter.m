//
//  DataImporter.m
//  MimicIIDataBrowser
//
//  Created by zli on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataImporter.h"
#import "parseCSV.h"
#import "Patient.h"

#import "MedEvent.h"
#import "IOEvent.h"
#import "LabEvent.h"
#import "ChartEvent.h"

#import "MedConcept.h"
#import "IOConcept.h"
#import "LabConcept.h"
#import "ChartConcept.h"

@interface DataImporter (hidden)
- (void)loadPatients;
- (void)loadMedEventsForPatient:(NSString *)_pid;
- (void)loadLabEventsForPatient:(NSString *)_pid;
- (void)loadIOEventsForPatient:(NSString *)_pid;
- (void)loadChartEventsForPatient:(NSString *)_pid;
- (Patient *)getPatientWithID:(NSString *)_pid;

- (MedConcept *)getMedConceptWithName:(NSString *)_name andRoute:(NSString *)_route;
- (LabConcept *)getLabConceptWithName:(NSString *)_name andSampleType:(NSString *)_sampleType;
- (IOConcept *)getIOConceptWithName:(NSString *)_name;
- (ChartConcept *)getChartConceptWithName:(NSString *)_name;

@end

@implementation DataImporter
@synthesize managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)_managedObjectContext
{
    self = [super init];
    if (self) {
        self.managedObjectContext = _managedObjectContext;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *inputPathURL = [[fileManager URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask] lastObject];
        inputPathURL = [inputPathURL URLByAppendingPathComponent:@"/June2ndMeeting"];
        inputPath = [inputPathURL path];
        
        [self prepareConceptsDictionaries];
        
        [self loadPatients];
    }
    
    return self;
}

- (void)dealloc
{
    [managedObjectContext release];
    [ioConcepts release];
    [labConcepts release];
    [chartConcepts release];
    [medConcepts release];
    
    [super dealloc];
}

- (void)prepareConceptsDictionaries
{
    @autoreleasepool {
        ioConcepts = [[NSMutableDictionary alloc] init];
        labConcepts = [[NSMutableDictionary alloc] init];
        chartConcepts = [[NSMutableDictionary alloc] init];
        medConcepts = [[NSMutableDictionary alloc] init];
        
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LabConcept" inManagedObjectContext:managedObjectContext];
            NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
            [request setEntity:entityDescription];
            
            NSError *error;
            NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
            for (LabConcept *lab in array) {
                NSString  *key = [NSString stringWithFormat:@"T:%@_S:%@", lab.mimiciiTerm, lab.sampleType];
                if (![labConcepts objectForKey:key]) {
                    [labConcepts setObject:lab forKey:key];
                }
            }
        }
        
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MedConcept" inManagedObjectContext:managedObjectContext];
            NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
            [request setEntity:entityDescription];
            
            NSError *error;
            NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
            for (MedConcept *med in array) {
                NSString  *key = [NSString stringWithFormat:@"T:%@_R:%@", med.mimiciiTerm, med.route];
                if (![medConcepts objectForKey:key]) {
                    [medConcepts setObject:med forKey:key];
                }
            }
        }
        
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IOConcept" inManagedObjectContext:managedObjectContext];
            NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
            [request setEntity:entityDescription];
            
            NSError *error;
            NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
            for (IOConcept *io in array) {
                NSString  *key = [NSString stringWithFormat:@"%@", io.mimiciiTerm];
                if (![ioConcepts objectForKey:key]) {
                    [ioConcepts setObject:io forKey:key];
                }
            }
        }
        
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChartConcept" inManagedObjectContext:managedObjectContext];
            NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
            [request setEntity:entityDescription];
            
            NSError *error;
            NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
            for (ChartConcept *chart in array) {
                NSString  *key = [NSString stringWithFormat:@"%@", chart.mimiciiTerm];
                if (![chartConcepts objectForKey:key]) {
                    [chartConcepts setObject:chart forKey:key];
                }
            }
        }
    }
    

    
}

- (void)loadPatients
{
    @autoreleasepool {
        NSError *error;
        NSArray *patientFolders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inputPath error:&error];
        for (NSString *pid in patientFolders) {
            NSString * fullPath = [inputPath stringByAppendingPathComponent:pid];
            BOOL isDir;
            if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] &&isDir) {
                //initiate the start and end timeinterval
                endTimeInterval = 0.0f;
                startTimeInterval = [[NSDate dateWithNaturalLanguageString:@"12/31/2099"] timeIntervalSince1970];
                
                Patient *newPatient = [NSEntityDescription insertNewObjectForEntityForName:@"Patient" inManagedObjectContext:managedObjectContext];
                newPatient.patientID = pid;
                [self loadMedEventsForPatient:pid];
                [self loadLabEventsForPatient:pid];
                [self loadIOEventsForPatient:pid];    
                [self loadChartEventsForPatient:pid];
                
                newPatient.eventStart = [NSDate dateWithTimeIntervalSince1970:startTimeInterval];
                newPatient.eventEnd = [NSDate dateWithTimeIntervalSince1970:endTimeInterval];
            }
            
        }
        
        [self loadPatientDemographics];
    }
    
}

- (void)loadPatientDemographics
{
    @autoreleasepool {
        NSString *patientDemographicPath = [inputPath stringByAppendingPathComponent:@"patientdemographics.csv"];
        CSVParser *parser = [CSVParser new];
        [parser openFile:patientDemographicPath];
        NSMutableArray *ptDemos = [parser parseFile];
        for (int i = 1; i < [ptDemos count]; i++) {
            NSArray *ptDemo = [ptDemos objectAtIndex:i];
            NSString *ptID = [ptDemo objectAtIndex:0];
            NSString *ptSex = [ptDemo objectAtIndex:1];
            NSString *ptDOB = [ptDemo objectAtIndex:2];
            
            Patient *thePatient = [self getPatientWithID:ptID];
            thePatient.patientDOB = ptDOB;
            thePatient.patientSex = ptSex;
        }
        
        [parser release];
        [self release];
    }
    
}

- (void)loadChartEventsForPatient:(NSString *)_pid
{
    @autoreleasepool {
        Patient *currentPatient = [self getPatientWithID:_pid];
        NSMutableString *filePath = [NSMutableString stringWithString:inputPath];
        [filePath appendFormat:@"/%@/chartevent-%@.txt", _pid, _pid];
        
        //    CSVParser *parser = [CSVParser new];
        //    [parser openFile:filePath];
        //    NSMutableArray *chartEvents = [parser parseFile];
        NSError *error;
        NSString *csvString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        NSArray *chartEvents = [csvString componentsSeparatedByString:@"\r"];
        for (int i = 1; i < [chartEvents count]-1; i++) {
            NSString *chartEventDataString = [chartEvents objectAtIndex:i];
            NSArray *chartEventData = [chartEventDataString componentsSeparatedByString:@"\t"];
            // NSLog(@"%@", chartEventData);
            NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"\""];
            
            NSString *chartLabel = [[chartEventData objectAtIndex:1] stringByTrimmingCharactersInSet:set];
            NSString *chartCategory = [[chartEventData objectAtIndex:2] stringByTrimmingCharactersInSet:set];
            NSString *timeString = [[chartEventData objectAtIndex:3] stringByTrimmingCharactersInSet:set];
            NSString *v1 = [[chartEventData objectAtIndex:4] stringByTrimmingCharactersInSet:set];
            NSString *v1n = [[chartEventData objectAtIndex:5] stringByTrimmingCharactersInSet:set];
            NSString *v1nu = [[chartEventData objectAtIndex:6] stringByTrimmingCharactersInSet:set];
            NSString *v2 = [[chartEventData objectAtIndex:7] stringByTrimmingCharactersInSet:set];
            NSString *v2n = [[chartEventData objectAtIndex:8] stringByTrimmingCharactersInSet:set];
            NSString *v2nu = [[chartEventData objectAtIndex:9] stringByTrimmingCharactersInSet:set];
            
            // NSLog(@"%@, %@, %@, %@, %@, %@, %@, %@, %@", chartLabel, chartCategory, timeString, v1, v1n, v1nu, v2, v2n, v2nu);
            NSDate *chartEventDate = [NSDate dateWithNaturalLanguageString:timeString];
            NSTimeInterval chartEventDateTI = [chartEventDate timeIntervalSince1970];
            if (chartEventDateTI > endTimeInterval) {
                endTimeInterval = chartEventDateTI;
            }
            if (chartEventDateTI < startTimeInterval) {
                startTimeInterval = chartEventDateTI;
            }
            
            ChartEvent *chartEvent = [NSEntityDescription insertNewObjectForEntityForName:@"ChartEvent" inManagedObjectContext:managedObjectContext];
            chartEvent.chartTime = chartEventDate;
            chartEvent.itemName = chartLabel;
            
            if ([chartCategory length] != 0) {
                chartEvent.category = chartCategory;
            }
            else
            {
                chartEvent.category = @"Unspecified";
            }
            
            if ([v1 length] != 0) {
                chartEvent.value1 = v1;
            }
            else if([v1n length] != 0){
                chartEvent.value1 = v1n;
                if ([v1nu length] != 0) {
                    chartEvent.value1unit = v1nu;
                }
            }
            
            if ([v2 length] != 0) {
                chartEvent.value2 = v2;
            }
            else if([v2n length] != 0){
                chartEvent.value2 = v2n;
                if ([v2nu length] != 0) {
                    chartEvent.value2unit = v2nu;
                }
            }
            
            chartEvent.patient = currentPatient;
            chartEvent.isSelected = [NSNumber numberWithBool:NO];
            
            ChartConcept * theChartConcept = [self getChartConceptWithName:chartLabel];
            chartEvent.concept = theChartConcept;
            [theChartConcept addPatientObject:currentPatient];
        }

    }
        
   // [parser release];
}

- (void)loadMedEventsForPatient:(NSString *)_pid
{
    @autoreleasepool {
        Patient *currentPatient = [self getPatientWithID:_pid];
        NSMutableString *filePath = [NSMutableString stringWithString:inputPath];
        [filePath appendFormat:@"/%@/medevent-%@.csv", _pid, _pid];
        
        CSVParser *parser = [CSVParser new];
        [parser openFile:filePath];
        NSMutableArray *medEvents = [parser parseFile];
        
        for (int i = 1; i < [medEvents count]; i++) {
            NSArray *medEventData = [medEvents objectAtIndex:i];
            NSString *label = [medEventData objectAtIndex:0];
            NSString *timeString = [medEventData objectAtIndex:1];
            NSString *dose = [medEventData objectAtIndex:2];
            NSString *doseUnit = [medEventData objectAtIndex:3];
            NSString *solVol = [medEventData objectAtIndex:4];
            NSString *solUnit = [medEventData objectAtIndex:5];
            NSString *route = [medEventData objectAtIndex:6];
            
            NSDate *medEventDate = [NSDate dateWithNaturalLanguageString:timeString];
            NSTimeInterval medEventDateTI = [medEventDate timeIntervalSince1970];
            if (medEventDateTI > endTimeInterval) {
                endTimeInterval = medEventDateTI;
            }
            if (medEventDateTI < startTimeInterval) {
                startTimeInterval = medEventDateTI;
            }
            
            
            
            MedEvent *medEvent = [NSEntityDescription insertNewObjectForEntityForName:@"MedEvent" inManagedObjectContext:managedObjectContext];
            medEvent.chartTime = medEventDate;
            medEvent.dose = dose;
            medEvent.doseUnit = doseUnit;
            medEvent.solutionVolume = solVol;
            medEvent.solutionUnit = solUnit;
            medEvent.route = route;
            medEvent.category = label;
            medEvent.patient = currentPatient;
            medEvent.isSelected = [NSNumber numberWithBool:NO];
            
            MedConcept *medConcept = [self getMedConceptWithName:label andRoute:route];
            medEvent.concept = medConcept;
            [medConcept addPatientObject:currentPatient];
        }
        
        [parser release];
    }
    
}

- (void)loadLabEventsForPatient:(NSString *)_pid
{
    @autoreleasepool {
        Patient *currentPatient = [self getPatientWithID:_pid];
        NSMutableString *filePath = [NSMutableString stringWithString:inputPath];
        [filePath appendFormat:@"/%@/labevent-%@.csv", _pid, _pid];
        
        CSVParser *parser = [CSVParser new];
        [parser openFile:filePath];
        NSMutableArray *labEvents = [parser parseFile];
        
        for (int i = 1; i < [labEvents count]; i++) {
            NSArray *labEventData = [labEvents objectAtIndex:i];
            //NSString *testName = [labEventData objectAtIndex:0];
            NSString *testName = [labEventData objectAtIndex:1];
            NSString *fluid = [labEventData objectAtIndex:2];
            NSString *category = [labEventData objectAtIndex:3];
            NSString *chartTime = [labEventData objectAtIndex:4];
            NSString *value = [labEventData objectAtIndex:5];
            NSString *valueUnit = [labEventData objectAtIndex:6];
            NSString *flag = [labEventData objectAtIndex:7];
            
            NSDate *labEventDate = [NSDate dateWithNaturalLanguageString:chartTime];
            NSTimeInterval labEventDateTI = [labEventDate timeIntervalSince1970];
            if (labEventDateTI > endTimeInterval) {
                endTimeInterval = labEventDateTI;
            }
            if (labEventDateTI < startTimeInterval) {
                startTimeInterval = labEventDateTI;
            }
            
            LabEvent *labEvent = [NSEntityDescription insertNewObjectForEntityForName:@"LabEvent" inManagedObjectContext:managedObjectContext];
            labEvent.category = category;
            labEvent.chartTime = labEventDate;
            labEvent.flag = flag;
            labEvent.patient = currentPatient;
            labEvent.sampleType = fluid;
            labEvent.testName = testName;
            labEvent.value = value;
            labEvent.valueUnit = valueUnit;
            labEvent.isSelected = [NSNumber numberWithBool:NO];
            
            LabConcept *labConcept = [self getLabConceptWithName:testName andSampleType:fluid];
            labEvent.concept = labConcept;
            [labConcept addPatientObject:currentPatient];
        }
        
        [parser release];

    }
    
}

- (void)loadIOEventsForPatient:(NSString *)_pid
{
    @autoreleasepool {
        Patient *currentPatient = [self getPatientWithID:_pid];
        NSMutableString *filePath = [NSMutableString stringWithString:inputPath];
        [filePath appendFormat:@"/%@/ioevent-%@.csv", _pid, _pid];
        
        CSVParser *parser = [CSVParser new];
        [parser openFile:filePath];
        NSMutableArray *ioEvents = [parser parseFile];
        
        for (int i = 1; i < [ioEvents count]; i++) {
            NSArray *ioEventData = [ioEvents objectAtIndex:i];
            //NSString *label = [medEventData objectAtIndex:0];
            NSString *label = [ioEventData objectAtIndex:1];
            NSString *category = [ioEventData objectAtIndex:2];
            NSString *chartTime = [ioEventData objectAtIndex:3];
            NSString *volume = [ioEventData objectAtIndex:4];
            NSString *volumeUnit = [ioEventData objectAtIndex:5];
            
            
            IOEvent *ioEvent = [NSEntityDescription insertNewObjectForEntityForName:@"IOEvent" inManagedObjectContext:managedObjectContext];
            if ([category length] == 0) {
#warning crappy code here....
                NSDate *ioEventDate = [NSDate dateWithNaturalLanguageString:volume];
                NSTimeInterval ioEventDateTI = [ioEventDate timeIntervalSince1970];
                if (ioEventDateTI > endTimeInterval) {
                    endTimeInterval = ioEventDateTI;
                }
                if (ioEventDateTI < startTimeInterval) {
                    startTimeInterval = ioEventDateTI;
                }
                
                ioEvent.category = @"Unspecified";
                ioEvent.chartTime = ioEventDate;
                ioEvent.label = label;
                ioEvent.volume = volumeUnit;
                ioEvent.volumeUnit = [ioEventData objectAtIndex:6];
            }
            else {
                NSDate *ioEventDate = [NSDate dateWithNaturalLanguageString:chartTime];
                NSTimeInterval ioEventDateTI = [ioEventDate timeIntervalSince1970];
                if (ioEventDateTI > endTimeInterval) {
                    endTimeInterval = ioEventDateTI;
                }
                if (ioEventDateTI < startTimeInterval) {
                    startTimeInterval = ioEventDateTI;
                }
                
                ioEvent.category = category;
                ioEvent.chartTime = ioEventDate;
                ioEvent.label = label;
                ioEvent.volume = volume;
                ioEvent.volumeUnit = volumeUnit;
            }
            ioEvent.patient = currentPatient;
            ioEvent.isSelected = [NSNumber numberWithBool:NO];
            
            IOConcept *ioConcept = [self getIOConceptWithName:label];
            ioEvent.concept = ioConcept;
            [ioConcept addPatientObject:currentPatient];
            
        }
        
        [parser release];

    }
    
}

- (Patient *)getPatientWithID:(NSString *)_pid
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Patient" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patientID == %@", _pid];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    
    Patient *result = [array objectAtIndex:0];
    
    return result;
}

- (MedConcept *)getMedConceptWithName:(NSString *)_name andRoute:(NSString *)_route
{
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MedConcept" inManagedObjectContext:managedObjectContext];
//    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mimiciiTerm == %@ && route == %@", _name, _route];
//    [request setPredicate:predicate];
//    
//    NSError *error;
//    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
//    
//    
//    MedConcept *result;
//    
//    if ([array count] > 0) {
//        result = [array objectAtIndex:0];
//    }
//    else {
//        result = [NSEntityDescription insertNewObjectForEntityForName:@"MedConcept" inManagedObjectContext:managedObjectContext];
//        result.mimiciiTerm = _name;
//        result.route = _route;
//    }
    NSString  *key = [NSString stringWithFormat:@"T:%@_R:%@", _name, _route];
    MedConcept *result = [medConcepts objectForKey:key];
    
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"MedConcept" inManagedObjectContext:managedObjectContext];
        result.mimiciiTerm = _name;
        result.route = _route;
        [medConcepts setObject:result forKey:key];
        
    }
    
    return result;

}

- (LabConcept *)getLabConceptWithName:(NSString *)_name andSampleType:(NSString *)_sampleType
{
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LabConcept" inManagedObjectContext:managedObjectContext];
//    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mimiciiTerm == %@ && sampleType == %@", _name, _sampleType];
//    [request setPredicate:predicate];
//    
//    NSError *error;
//    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
//    
//    
//    LabConcept *result;
//    
//    if ([array count] > 0) {
//        result = [array objectAtIndex:0];
//    }
//    else {
//        result = [NSEntityDescription insertNewObjectForEntityForName:@"LabConcept" inManagedObjectContext:managedObjectContext];
//        result.mimiciiTerm = _name;
//        result.sampleType = _sampleType;
//    }
    NSString  *key = [NSString stringWithFormat:@"T:%@_S:%@", _name, _sampleType];
    LabConcept *result = [labConcepts objectForKey:key];
    
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"LabConcept" inManagedObjectContext:managedObjectContext];
        result.mimiciiTerm = _name;
        result.sampleType = _sampleType;
        [labConcepts setObject:result forKey:key];

    }
    
    return result;
}

- (IOConcept *)getIOConceptWithName:(NSString *)_name
{
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"IOConcept" inManagedObjectContext:managedObjectContext];
//    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mimiciiTerm == %@", _name];
//    [request setPredicate:predicate];
//    
//    NSError *error;
//    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
//    
//    
//    IOConcept *result;
//    
//    if ([array count] > 0) {
//        result = [array objectAtIndex:0];
//    }
//    else {
//        result = [NSEntityDescription insertNewObjectForEntityForName:@"IOConcept" inManagedObjectContext:managedObjectContext];
//        result.mimiciiTerm = _name;
//    }
//    
//    return [ioConcepts objectForKey:_name];
    NSString  *key = [NSString stringWithFormat:@"%@", _name];
    IOConcept *result = [ioConcepts objectForKey:key];
    
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"IOConcept" inManagedObjectContext:managedObjectContext];
        result.mimiciiTerm = _name;
        [ioConcepts setObject:result forKey:key];        
    }
    
    return result;

}

- (ChartConcept *)getChartConceptWithName:(NSString *)_name
{
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChartConcept" inManagedObjectContext:managedObjectContext];
//    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
//    [request setEntity:entityDescription];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mimiciiTerm == %@", _name];
//    [request setPredicate:predicate];
//    
//    NSError *error;
//    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
//    
//    
//    ChartConcept *result;
//    
//    if ([array count] > 0) {
//        result = [array objectAtIndex:0];
//    }
//    else {
//        result = [NSEntityDescription insertNewObjectForEntityForName:@"ChartConcept" inManagedObjectContext:managedObjectContext];
//        result.mimiciiTerm = _name;
//    }
//    
//    return [chartConcepts objectForKey:_name];
    NSString  *key = [NSString stringWithFormat:@"%@", _name];
    ChartConcept *result = [chartConcepts objectForKey:key];
    
    if (!result) {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"ChartConcept" inManagedObjectContext:managedObjectContext];
        result.mimiciiTerm = _name;
        [chartConcepts setObject:result forKey:key];        
    }
    
    return result;
}
@end
