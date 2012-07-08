#import "MyHTTPConnection.h"
#import "HTTPDataResponse.h"
#import "HTTPResponseTest.h"
#import "DDLog.h"
#import "MimicIIDataBrowserAppDelegate.h"
#import "Patient.h"

#import "MedConcept.h"
#import "LabConcept.h"
#import "IOConcept.h"
#import "ChartConcept.h"

#import "LabEvent.h"
#import "MedEvent.h"
#import "Patient.h"

#import "JSON.h"

// Log levels: off, error, warn, info, verbose
// Other flags: trace
//static const int httpLogLevel = HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface MyHTTPConnection () 
- (HTTPDataResponse *)getPatientList;
- (HTTPDataResponse *)getTermsForPatient:(NSString *)_pid;
@end

@implementation MyHTTPConnection

- (id)initWithAsyncSocket:(GCDAsyncSocket *)newSocket configuration:(HTTPConfig *)aConfig
{
    if ((self = [super initWithAsyncSocket:newSocket configuration:aConfig])) {
        managedObjectContext = [((MimicIIDataBrowserAppDelegate *)[[NSApplication sharedApplication] delegate]).managedObjectContext retain];
    }
    
    return self;
}

- (void) dealloc
{
    [managedObjectContext release];
    [super dealloc];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    NSString *filePath = [self filePathForURI:path];
	
	// Convert to relative path
	
	NSString *documentRoot = [config documentRoot];
	
	if (![filePath hasPrefix:documentRoot])
	{
		// Uh oh.
		// HTTPConnection's filePathForURI was supposed to take care of this for us.
		return nil;
	}
	
	NSString *relativePath = [filePath substringFromIndex:[documentRoot length]];
    NSLog(@"%@, %@", [relativePath pathComponents], path);
    
    if ([relativePath hasPrefix:@"/patient"] && ![relativePath isEqualToString:@"/patients"]) {
        if ([[relativePath pathComponents] count] == 3) {
            NSLog(@"%@", [relativePath lastPathComponent]);
            NSString *patientID = [relativePath lastPathComponent];
            HTTPDataResponse *result = [self getTermsJsonForPatient:patientID];
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                DDLogInfo(@"Client requested terms available for patient");
                DDLogInfo(@"%@", method);
            });
            
            
            return result;
        }
        else if ([[relativePath pathComponents] count] == 4) {
            NSString *term = [[relativePath pathComponents] objectAtIndex:3];
            NSString *patientID = [[relativePath pathComponents] objectAtIndex:2];
            
            HTTPDataResponse *result = [self getValueJsonForPatient:patientID andTerm:term];
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                DDLogInfo(@"Client requested terms available for patient");
                DDLogInfo(@"%@", method);
            });
            
            return result;
        }
        else if ([[relativePath pathComponents] count] == 5) {
            if ([[[relativePath pathComponents] objectAtIndex:4] isEqualToString:@"unit"]) {
                NSString *term = [[relativePath pathComponents] objectAtIndex:3];
                NSString *patientID = [[relativePath pathComponents] objectAtIndex:2];
                HTTPDataResponse *result = [self getUnitForPatient:patientID andTerm:term];
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    DDLogInfo(@"Client requested terms available for patient");
                    DDLogInfo(@"%@", method);
                });
                
                return result;
            }
            return nil;

        }
        else {
            return nil;
        }
        
        
        
    }
    else if ([relativePath isEqualToString:@"/patients"]) {
        HTTPDataResponse *result = [self getPatientList];
        return result;
    }
    else if ([relativePath isEqualToString:@"/unittest.html"])
	{
		DDLogInfo(@"%@[%p]: Serving up HTTPResponseTest (unit testing)", THIS_FILE, self);
		
		return [[[HTTPResponseTest alloc] initWithConnection:self] autorelease];
	}
	
	return [super httpResponseForMethod:method URI:path];
}

- (HTTPDataResponse *)getPatientList
{
    HTTPDataResponse *dataResponse;
    @autoreleasepool {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Patient" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        [fetchRequest setEntity:entityDescription];
        
        NSError *error;
        NSArray *array = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] retain];
        
        
        
        NSMutableString *patientList = [NSMutableString stringWithString:@"<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n<root>\n"];
        for (Patient *patient in array) {
            [patientList appendFormat:@"<patient>%@</patient>\n", patient.patientID];
        }
        [patientList appendString:@"</root>"];
        
        NSData *patientListData = [patientList dataUsingEncoding:NSUTF8StringEncoding];
        
        dataResponse = [[HTTPDataResponse alloc] initWithData:patientListData];
    }
    
    return [dataResponse autorelease];
}

- (HTTPDataResponse *)getTermsForPatient:(NSString *)_pid
{
    HTTPDataResponse *dataResponse;
    
    @autoreleasepool {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Patient" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        [fetchRequest setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patientID == %@", _pid];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([array count] <= 0) {
            NSString *errorString = [NSString stringWithFormat:@"Patient %@ does not exist", _pid];
            NSData *errorData = [errorString dataUsingEncoding:NSUTF8StringEncoding];
            return [[HTTPDataResponse alloc] initWithData:errorData];
        }
        Patient *resultPatient = [array objectAtIndex:0];
        
        NSArray *medConcepts = [resultPatient.medConcepts allObjects];
        NSCountedSet *medConceptWithCount = [NSCountedSet setWithArray:[medConcepts valueForKey:@"preferredTerm"]];
        NSMutableSet *uniqueMedPreferredTerms = [NSMutableSet set];
        for (id pTerm in medConceptWithCount)
            if ([medConceptWithCount countForObject:pTerm] == 1)
                [uniqueMedPreferredTerms addObject:pTerm];
        NSPredicate *findUniqueMedPreferredTerm = [NSPredicate predicateWithFormat:@"preferredTerm IN %@", uniqueMedPreferredTerms];
        NSArray *uniqueMedConcepts = [medConcepts filteredArrayUsingPredicate:findUniqueMedPreferredTerm];
        
        NSArray *labConcepts = [resultPatient.labConcepts allObjects];
        NSCountedSet *labConceptWithCount = [NSCountedSet setWithArray:[labConcepts valueForKey:@"preferredTerm"]];
        NSMutableSet *uniqueLabPreferredTerms = [NSMutableSet set];
        for (id pTerm in labConceptWithCount)
            if ([labConceptWithCount countForObject:pTerm] == 1)
                [uniqueLabPreferredTerms addObject:pTerm];
        NSPredicate *findUniqueLabPreferredTerm = [NSPredicate predicateWithFormat:@"preferredTerm IN %@", uniqueLabPreferredTerms];
        NSArray *uniqueLabConcepts = [labConcepts filteredArrayUsingPredicate:findUniqueLabPreferredTerm];
        
        NSArray *chartConcepts = [resultPatient.chartConcepts allObjects];
        NSCountedSet *chartConceptWithCount = [NSCountedSet setWithArray:[chartConcepts valueForKey:@"preferredTerm"]];
        NSMutableSet *uniqueChartPreferredTerms = [NSMutableSet set];
        for (id pTerm in chartConceptWithCount)
            if ([chartConceptWithCount countForObject:pTerm] == 1)
                [uniqueChartPreferredTerms addObject:pTerm];
        NSPredicate *findUniqueChartPreferredTerm = [NSPredicate predicateWithFormat:@"preferredTerm IN %@", uniqueChartPreferredTerms];
        NSArray *uniqueChartConcepts = [chartConcepts filteredArrayUsingPredicate:findUniqueChartPreferredTerm];
        
        NSArray *ioConcepts = [resultPatient.ioConcepts allObjects];
        NSCountedSet *ioConceptWithCount = [NSCountedSet setWithArray:[ioConcepts valueForKey:@"preferredTerm"]];
        NSMutableSet *uniqueIOPreferredTerms = [NSMutableSet set];
        for (id pTerm in ioConceptWithCount)
            if ([ioConceptWithCount countForObject:pTerm] == 1)
                [uniqueIOPreferredTerms addObject:pTerm];
        NSPredicate *findUniqueIOPreferredTerm = [NSPredicate predicateWithFormat:@"preferredTerm IN %@", uniqueIOPreferredTerms];
        NSArray *uniqueIOConcepts = [ioConcepts filteredArrayUsingPredicate:findUniqueIOPreferredTerm];        
        
        NSMutableString *conceptList = [NSMutableString stringWithString:@"<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n<root>\n"];
        
        [conceptList appendString:@"<medConcepts>\n"];
        for (MedConcept *medConcept in uniqueMedConcepts) {
            if ([medConcept.preferredTerm length] != 0) {
                NSMutableString *term = [[medConcept.preferredTerm mutableCopy] autorelease];
                [term replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [term length])];
                [term replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [term length])];
                [conceptList appendFormat:@"<concept>%@</concept>", term];
            }
           
        }
        [conceptList appendString:@"</medConcepts>\n"];
        
        [conceptList appendString:@"<labConcepts>\n"];
        for (LabConcept *labConcept in uniqueLabConcepts) {
            if ([labConcept.preferredTerm length] != 0) {
                NSMutableString *term = [[labConcept.preferredTerm mutableCopy] autorelease];
                [term replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [term length])];
                [term replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [term length])];
                [conceptList appendFormat:@"<concept>%@</concept>", term];
            }
            
        }
        [conceptList appendString:@"</labConcepts>\n"];
        
        [conceptList appendString:@"<chartConcepts>\n"];
        for (ChartConcept *chartConcept in uniqueChartConcepts) {
            if ([chartConcept.preferredTerm length] != 0) {
                NSMutableString *term = [[chartConcept.preferredTerm mutableCopy] autorelease];
                [term replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [term length])];
                [term replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [term length])];
                [conceptList appendFormat:@"<concept>%@</concept>", term];
            }
            
        }
        [conceptList appendString:@"</chartConcepts>\n"];
        
        [conceptList appendString:@"<ioConcepts>\n"];
        for (IOConcept *ioConcept in uniqueIOConcepts) {
            if ([ioConcept.preferredTerm length] != 0) {
                NSMutableString *term = [[ioConcept.preferredTerm mutableCopy] autorelease];
                [term replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [term length])];
                [term replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [term length])];
                [conceptList appendFormat:@"<concept>%@</concept>", term];
            }
            
        }
        [conceptList appendString:@"</ioConcepts>\n"];
        
        [conceptList appendString:@"</root>"];
        
        
        NSData *conceptListData = [conceptList dataUsingEncoding:NSUTF8StringEncoding];
        
        dataResponse = [[HTTPDataResponse alloc] initWithData:conceptListData];
    }
    
    return [dataResponse autorelease];

}

- (HTTPDataResponse *)getTermsJsonForPatient:(NSString *)_pid
{
    HTTPDataResponse *dataResponse;
    @autoreleasepool {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Patient" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        [fetchRequest setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patientID == %@", _pid];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([array count] <= 0) {
            NSString *errorString = [NSString stringWithFormat:@"Patient %@ does not exist", _pid];
            NSData *errorData = [errorString dataUsingEncoding:NSUTF8StringEncoding];
            return [[HTTPDataResponse alloc] initWithData:errorData];
        }
        Patient *resultPatient = [array objectAtIndex:0];
        
        NSArray *medConcepts = [resultPatient.medConcepts allObjects];
        NSCountedSet *medConceptWithCount = [NSCountedSet setWithArray:[medConcepts valueForKey:@"mimiciiTerm"]];
        NSMutableSet *uniqueMedPreferredTerms = [NSMutableSet set];
        for (id pTerm in medConceptWithCount)
            if ([medConceptWithCount countForObject:pTerm] == 1)
                [uniqueMedPreferredTerms addObject:pTerm];
        NSPredicate *findUniqueMedPreferredTerm = [NSPredicate predicateWithFormat:@"mimiciiTerm IN %@", uniqueMedPreferredTerms];
        NSArray *uniqueMedConcepts = [medConcepts filteredArrayUsingPredicate:findUniqueMedPreferredTerm];
        NSMutableArray *convertedMedConcepts = [NSMutableArray array];
        for (MedConcept *mc in uniqueMedConcepts) {
            [convertedMedConcepts addObject:[self dictionaryFromMedConcept:mc]];
        }
                
        NSArray *labConcepts = [resultPatient.labConcepts allObjects];
        NSCountedSet *labConceptWithCount = [NSCountedSet setWithArray:[labConcepts valueForKey:@"mimiciiTerm"]];
        NSMutableSet *uniqueLabPreferredTerms = [NSMutableSet set];
        for (id pTerm in labConceptWithCount)
            if ([labConceptWithCount countForObject:pTerm] == 1)
                [uniqueLabPreferredTerms addObject:pTerm];
        NSPredicate *findUniqueLabPreferredTerm = [NSPredicate predicateWithFormat:@"mimiciiTerm IN %@", uniqueLabPreferredTerms];
        NSArray *uniqueLabConcepts = [labConcepts filteredArrayUsingPredicate:findUniqueLabPreferredTerm];
        NSMutableArray *convertedLabConcepts = [NSMutableArray array];
        for (LabConcept *lc in uniqueLabConcepts) {
            [convertedLabConcepts addObject:[self dictionaryFromLabConcept:lc]];
        }
        
        [convertedLabConcepts sortUsingSelector:@selector(compare:)];
        [convertedMedConcepts sortUsingSelector:@selector(compare:)];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:convertedMedConcepts, @"meds", convertedLabConcepts, @"labs", nil];
        
        NSData *conceptListData = [[dict JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
        
        dataResponse = [[HTTPDataResponse alloc] initWithData:conceptListData];
    }
    
    return dataResponse;
    
}

- (id)dictionaryFromMedConcept:(MedConcept *)med
{
//    NSMutableDictionary *result = [NSMutableDictionary dictionary];
//    [result setValue:med.mimiciiTerm forKey:@"mimiciiTerm"];
    return med.mimiciiTerm;
}

- (id)dictionaryFromLabConcept:(LabConcept *)lab
{
//    NSMutableDictionary *result = [NSMutableDictionary dictionary];
//    [result setValue:lab.mimiciiTerm forKey:@"mimiciiTerm"];
    return lab.mimiciiTerm;
}

- (HTTPDataResponse *)getValueJsonForPatient:(NSString *)_pid andTerm:(NSString *)mm2T
{
    HTTPDataResponse *dataResponse;
    @autoreleasepool {
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Patient" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        [fetchRequest setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patientID == %@", _pid];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([array count] <= 0) {
            NSString *errorString = [NSString stringWithFormat:@"Patient %@ does not exist", _pid];
            NSData *errorData = [errorString dataUsingEncoding:NSUTF8StringEncoding];
            return [[HTTPDataResponse alloc] initWithData:errorData];
        }
        Patient *resultPatient = [array objectAtIndex:0];
        
        NSArray *medConcepts = [resultPatient.medConcepts allObjects];
        NSArray *labConcepts = [resultPatient.labConcepts allObjects];
        
        predicate = [NSPredicate predicateWithFormat:@"mimiciiTerm = %@", mm2T];
        labConcepts = [labConcepts filteredArrayUsingPredicate:predicate];
        
        medConcepts = [medConcepts filteredArrayUsingPredicate:predicate];
        
        LabConcept *labConcept = nil;
        MedConcept *medConcept = nil;
        
        
        if ([labConcepts count] > 0) {
            labConcept = [labConcepts objectAtIndex:0];
        }
        
        if ([medConcepts count] > 0) {
            medConcept = [medConcepts objectAtIndex:0];
        }
       
        if (labConcept == nil && medConcept == nil) {
            NSString *errorString = [NSString stringWithFormat:@"Concept %@ does not exist", mm2T];
            NSData *errorData = [errorString dataUsingEncoding:NSUTF8StringEncoding];
            return [[HTTPDataResponse alloc] initWithData:errorData]; 
        }
        
        if (labConcept != nil) {
            NSArray *labEvents = [labConcept.hasLabEvents allObjects];
            predicate = [NSPredicate predicateWithFormat:@"chartTime >= %@ && chartTime <= %@", resultPatient.eventStart, resultPatient.eventEnd];
            labEvents = [labEvents filteredArrayUsingPredicate:predicate];
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"chartTime" ascending:TRUE];
            labEvents = [labEvents sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            [sortDescriptor release];
            
            NSMutableArray *result = [NSMutableArray array];
            for (LabEvent *le in labEvents) {
                [result addObject:[self arrayFromLabEvent:le]];
            }
            
            NSData *labEventsData = [[result JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
            
            dataResponse = [[HTTPDataResponse alloc] initWithData:labEventsData];
        }
        
        if (medConcept != nil) {
            NSArray *medEvents = [medConcept.hasMedEvents allObjects];
            predicate = [NSPredicate predicateWithFormat:@"chartTime >= %@ && chartTime <= %@", resultPatient.eventStart, resultPatient.eventEnd];
            medEvents = [medEvents filteredArrayUsingPredicate:predicate];
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"chartTime" ascending:TRUE];
            medEvents = [medEvents sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            [sortDescriptor release];
            
            NSMutableArray *result = [NSMutableArray array];
            for (MedEvent *me in medEvents) {
                [result addObject:[self arrayFromMedEvent:me]];
            }
            
            NSData *medEventsData = [[result JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
            
            dataResponse = [[HTTPDataResponse alloc] initWithData:medEventsData];
        }

    }
    return dataResponse;
}

- (HTTPDataResponse *)getUnitForPatient:(NSString *)_pid andTerm:(NSString *)mm2T
{
    HTTPDataResponse *dataResponse;
    @autoreleasepool {
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Patient" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        [fetchRequest setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patientID == %@", _pid];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([array count] <= 0) {
            NSString *errorString = [NSString stringWithFormat:@"Patient %@ does not exist", _pid];
            NSData *errorData = [errorString dataUsingEncoding:NSUTF8StringEncoding];
            return [[HTTPDataResponse alloc] initWithData:errorData];
        }
        Patient *resultPatient = [array objectAtIndex:0];
        
        NSArray *medConcepts = [resultPatient.medConcepts allObjects];
        NSArray *labConcepts = [resultPatient.labConcepts allObjects];
        
        predicate = [NSPredicate predicateWithFormat:@"mimiciiTerm = %@", mm2T];
        labConcepts = [labConcepts filteredArrayUsingPredicate:predicate];
        
        medConcepts = [medConcepts filteredArrayUsingPredicate:predicate];
        
        LabConcept *labConcept = nil;
        MedConcept *medConcept = nil;
        
        
        if ([labConcepts count] > 0) {
            labConcept = [labConcepts objectAtIndex:0];
        }
        
        if ([medConcepts count] > 0) {
            medConcept = [medConcepts objectAtIndex:0];
        }
        
        if (labConcept == nil && medConcept == nil) {
            NSString *errorString = [NSString stringWithFormat:@"Concept %@ does not exist", mm2T];
            NSData *errorData = [errorString dataUsingEncoding:NSUTF8StringEncoding];
            return [[HTTPDataResponse alloc] initWithData:errorData]; 
        }
        
        if (labConcept != nil) {
            LabEvent *labEvent = [labConcept.hasLabEvents anyObject];
                        
            NSData *labEventsData = [labEvent.valueUnit dataUsingEncoding:NSUTF8StringEncoding];
            
            dataResponse = [[HTTPDataResponse alloc] initWithData:labEventsData];
        }
        
        if (medConcept != nil) {
            MedEvent *medEvent = [medConcept.hasMedEvents anyObject];
                       
            NSData *medEventsData = [medEvent.doseUnit dataUsingEncoding:NSUTF8StringEncoding];
            
            dataResponse = [[HTTPDataResponse alloc] initWithData:medEventsData];
        }
        
    }
    return dataResponse;
}


- (NSArray *)arrayFromLabEvent:(LabEvent *)le
{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
//    NSString *dateString = [dateFormatter stringFromDate:le.chartTime];
//    [dateFormatter release];
    
    NSTimeInterval date = [le.chartTime timeIntervalSince1970] * 1000;
    
    return [NSArray arrayWithObjects:[NSNumber numberWithLong:date], [NSNumber numberWithFloat:[le.value floatValue]], nil];
}

- (NSArray *)arrayFromMedEvent:(MedEvent *)me
{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
//    NSString *dateString = [dateFormatter stringFromDate:me.chartTime];
//    [dateFormatter release];
//
//    return [NSArray arrayWithObjects:dateString, me.dose, nil];
    NSTimeInterval date = [me.chartTime timeIntervalSince1970] * 1000;
    
    return [NSArray arrayWithObjects:[NSNumber numberWithLong:date], [NSNumber numberWithFloat:[me.value floatValue]], nil];

}

@end
