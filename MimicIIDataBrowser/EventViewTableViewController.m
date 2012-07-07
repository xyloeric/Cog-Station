//
//  EventViewTableViewController.m
//  MimicIIDataBrowser
//
//  Created by Eric Li on 6/2/11.
//  Copyright 2011 UTH. All rights reserved.
//

#import "EventViewTableViewController.h"
#import "MainBrowserWindowController.h"
#import "Session.h"
#import "LogEvent.h"

@implementation EventViewTableViewController
@synthesize managedObjectContext;
@synthesize mbwc;
@synthesize patient;
@synthesize eventClass;
@synthesize eventIdentifier;
@synthesize events, allEvents;
@synthesize startDate, endDate;
@synthesize selectionCheckBox;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [managedObjectContext release];
    
    [mbwc removeObserver:self forKeyPath:@"currentPatient"];
    [mbwc release];
    [patient release];
    [eventClass release];
    [eventIdentifier release];
    [events release];
    [allEvents release];
    [super dealloc];
}

- (void)setEventIdentifier:(NSString *)_eventIdentifier
{
    if (![eventIdentifier isEqualToString:_eventIdentifier]) {
        [eventIdentifier release];
        eventIdentifier = [_eventIdentifier copy];
        if (eventIdentifier != nil) {
            [self refreshEventsArrayWithNewCSV:YES];
        }
    }
}

- (void)setMbwc:(MainBrowserWindowController *)_mbwc
{
    if (mbwc != _mbwc) {
        [mbwc removeObserver:self forKeyPath:@"currentPatient"];
        [mbwc release];
        mbwc = [_mbwc retain];
        [mbwc addObserver:self forKeyPath:@"currentPatient" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    }
}



- (void)refreshEventsArrayWithNewCSV:(BOOL)_newCSV
{
    @autoreleasepool {
        isSelected = NO;
        
        if (patient != nil && eventClass != nil) {
            NSError *error = nil;
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:eventClass inManagedObjectContext:managedObjectContext];
            NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
            [request setEntity:entityDescription];
            
            NSPredicate *predicate;
            
            NSEntityDescription *entityDescriptionAll = [NSEntityDescription entityForName:eventClass inManagedObjectContext:managedObjectContext];
            NSFetchRequest *requestAll = [[[NSFetchRequest alloc] init] autorelease];
            [requestAll setEntity:entityDescriptionAll];
            
            NSPredicate *predicateAll;
            
            NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"/"];
            //NSLog(@"%@", eventIdentifier);
            if ([eventIdentifier rangeOfCharacterFromSet:set].location != NSNotFound) {
                NSLog(@"This string contains illegal characters");
            }
            
            NSArray *eventIdentifierComponents = [eventIdentifier pathComponents];
            //NSLog(@"%@", eventIdentifierComponents);
            
            if ([eventIdentifierComponents count] > 1) {
                if ([eventClass isEqualToString:@"MedEvent"]) {
                    predicate = [NSPredicate predicateWithFormat:@"patient = %@ && route = %@ && category = %@ && chartTime >= %@ && chartTime <= %@", patient, [eventIdentifierComponents objectAtIndex:1],[eventIdentifierComponents objectAtIndex:2], startDate, endDate];
                    [request setPredicate:predicate];
                    
                    predicateAll = [NSPredicate predicateWithFormat:@"patient = %@ && route = %@ && category = %@", patient, [eventIdentifierComponents objectAtIndex:1],[eventIdentifierComponents objectAtIndex:2]];
                    [requestAll setPredicate:predicateAll];
                }
                else if ([eventClass isEqualToString:@"LabEvent"]) {
                    predicate = [NSPredicate predicateWithFormat:@"patient = %@ && sampleType = %@ && category = %@ && testName = %@ && chartTime >= %@ && chartTime <= %@", patient, [eventIdentifierComponents objectAtIndex:1],[eventIdentifierComponents objectAtIndex:2],[eventIdentifierComponents objectAtIndex:3], startDate, endDate];
                    [request setPredicate:predicate];
                    
                    predicateAll = [NSPredicate predicateWithFormat:@"patient = %@ && sampleType = %@ && category = %@ && testName = %@", patient, [eventIdentifierComponents objectAtIndex:1],[eventIdentifierComponents objectAtIndex:2],[eventIdentifierComponents objectAtIndex:3]];
                    [requestAll setPredicate:predicateAll];
                }
                else if ([eventClass isEqualToString:@"IOEvent"]) {
                    predicate = [NSPredicate predicateWithFormat:@"patient = %@ && label = %@ && chartTime >= %@ && chartTime <= %@", patient, [eventIdentifierComponents objectAtIndex:0], startDate, endDate];
                    [request setPredicate:predicate];
                    
                    predicateAll = [NSPredicate predicateWithFormat:@"patient = %@ && label = %@", patient, [eventIdentifierComponents objectAtIndex:0]];
                    [requestAll setPredicate:predicateAll];
                    
                }
                else if ([eventClass isEqualToString:@"ChartEvent"]) {
                    predicate = [NSPredicate predicateWithFormat:@"patient = %@ && itemName = %@ && chartTime >= %@ && chartTime <= %@", patient, [eventIdentifierComponents objectAtIndex:0], startDate, endDate];
                    [request setPredicate:predicate];
                    
                    predicateAll = [NSPredicate predicateWithFormat:@"patient = %@ && itemName = %@", patient, [eventIdentifierComponents objectAtIndex:0]];
                    [requestAll setPredicate:predicateAll];
                }

            }
            else
            {
                if ([eventClass isEqualToString:@"MedEvent"]) {
                    predicate = [NSPredicate predicateWithFormat:@"patient = %@ && category = %@ && chartTime >= %@ && chartTime <= %@", patient, [eventIdentifierComponents objectAtIndex:0], startDate, endDate];
                    [request setPredicate:predicate];
                    
                    predicateAll = [NSPredicate predicateWithFormat:@"patient = %@ && category = %@", patient, [eventIdentifierComponents objectAtIndex:0]];
                    [requestAll setPredicate:predicateAll];
                }
                else if ([eventClass isEqualToString:@"LabEvent"]) {
                    predicate = [NSPredicate predicateWithFormat:@"patient = %@ && testName = %@ && chartTime >= %@ && chartTime <= %@", patient, [eventIdentifierComponents objectAtIndex:0], startDate, endDate];
                    [request setPredicate:predicate];
                    
                    predicateAll = [NSPredicate predicateWithFormat:@"patient = %@ && testName = %@", patient, [eventIdentifierComponents objectAtIndex:0]];
                    [requestAll setPredicate:predicateAll];
                }
                else if ([eventClass isEqualToString:@"IOEvent"]) {
                    predicate = [NSPredicate predicateWithFormat:@"patient = %@ && label = %@ && chartTime >= %@ && chartTime <= %@", patient, [eventIdentifierComponents objectAtIndex:0], startDate, endDate];
                    [request setPredicate:predicate];
                    
                    predicateAll = [NSPredicate predicateWithFormat:@"patient = %@ && label = %@", patient, [eventIdentifierComponents objectAtIndex:0]];
                    [requestAll setPredicate:predicateAll];
                }
                else if ([eventClass isEqualToString:@"ChartEvent"]) {
                    predicate = [NSPredicate predicateWithFormat:@"patient = %@ && itemName = %@ && chartTime >= %@ && chartTime <= %@", patient, [eventIdentifierComponents objectAtIndex:0], startDate, endDate];
                    [request setPredicate:predicate];
                    
                    predicateAll = [NSPredicate predicateWithFormat:@"patient = %@ && itemName = %@", patient, [eventIdentifierComponents objectAtIndex:0]];
                    [requestAll setPredicate:predicateAll];
                }

            }
                        
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"chartTime" ascending:YES];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            [request setSortDescriptors:sortDescriptors];
            [requestAll setSortDescriptors:sortDescriptors];
            [sortDescriptors release];
            [sortDescriptor release];
            
            NSArray *result = [managedObjectContext executeFetchRequest:request error:&error];
            NSArray *resultAll = [managedObjectContext executeFetchRequest:requestAll error:&error];
            
            self.events = result;
            self.allEvents = resultAll;
            
            [self decideOverallSelectionCheckboxState:allEvents];
            // NSLog(@"%@", [events objectAtIndex:0]);
            
            [(NSTableView *)self.view reloadData];
        }
        
        if (_newCSV) {
//            NSURL *url = [[NSURL alloc] initWithString:@"http://www.apple.com"];
//            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
//            [[mbwc.webView mainFrame] loadRequest:request];
//            
//            [url release];
//            [request release];
            [self renderDataWithGraphRenderer:events];
        }
    }
}

- (void) decideOverallSelectionCheckboxState:(NSArray *)_events
{
    @autoreleasepool {
        if (selectionCheckBox.isEnabled == NO) {
            [selectionCheckBox setEnabled:YES];
        }
        
        NSError *error = nil;
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"LogEvent" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entityDescription];

        Session *currentSession = mbwc.currentSession;
        Patient *currentPatient = mbwc.currentPatient;
                
        NSString *lastComponent = [eventIdentifier lastPathComponent];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"session = %@ && session.patientSN = %@ && (path = %@ || path = %@)", currentSession, currentPatient.patientID, eventIdentifier, lastComponent];

        [request setPredicate:predicate];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventDate" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
        
        [sortDescriptors release];
        [sortDescriptor release];
        
        NSArray *result = [managedObjectContext executeFetchRequest:request error:&error];
        
        LogEvent *logEvent = [result lastObject];
        
        if (logEvent) {
            if ([logEvent.action isEqualToString:@"selected"]) {
                [selectionCheckBox setState:NSOnState];
                isSelected = YES;
            }
            else if ([logEvent.action isEqualToString:@"deselected"]) {
                [selectionCheckBox setState:NSOffState];
                isSelected = NO;
            }
        }
        else
        {
            [selectionCheckBox setState:NSOffState];
        }
        
        
//        NSUInteger _selectionCount = 0;
//        for (NSManagedObject *event in _events) {
//            if ([[event valueForKey:@"isSelected"] boolValue] == YES) {
//                _selectionCount ++;
//            }
//        }
//        
//        selectionCount = _selectionCount;
//        eventCount = [events count];
//        allEventCount = [allEvents count];
//        
//        if (selectionCount == allEventCount) {
//            [selectionCheckBox setState:NSOnState];
//        }
//        else if(selectionCount < allEventCount && selectionCount > 0){
//            [selectionCheckBox setState:NSMixedState];
//        }
//        else {
//            [selectionCheckBox setState:NSOffState];
//        }
    }
    
}

- (IBAction)checkboxClicked:(id)sender
{
    if ([sender state] == NSOffState) {
        [allEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setValue:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
        }];
        
        NSDictionary *eventDict = [NSDictionary dictionaryWithObjectsAndKeys:eventIdentifier, @"path", @"deselected", @"activity", [NSDate date], @"date", nil];
        [studyEventLogger logNewActivity:eventDict];
    }
    else {
        [allEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setValue:[NSNumber numberWithBool:YES] forKey:@"isSelected"];
        }];
        
         NSDictionary *eventDict = [NSDictionary dictionaryWithObjectsAndKeys:eventIdentifier, @"path", @"selected", @"activity", [NSDate date], @"date", nil];
        [studyEventLogger logNewActivity:eventDict];
    }
//    if (selectionCount >= eventCount && selectionCount != allEventCount) {
//        [allEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            [obj setValue:[NSNumber numberWithBool:YES] forKey:@"isSelected"];
//        }];
//    }
//    else if (selectionCount == allEventCount) {
//        [allEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            [obj setValue:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
//        }];
//    }
//    else if (selectionCount < eventCount) {
//        [events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            [obj setValue:[NSNumber numberWithBool:YES] forKey:@"isSelected"];
//        }];
//    }
//    else {
//        [allEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            [obj setValue:[NSNumber numberWithBool:YES] forKey:@"isSelected"];
//        }];
//    }
//    
    [self decideOverallSelectionCheckboxState:allEvents];
    [(NSTableView *)self.view reloadData];

}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [events count];
}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableColumn.identifier isEqualToString:@"1"]) {
        NSButtonCell *cell=[[NSButtonCell alloc] init];
        //    NSString *strDisplayPlaylistName;
        //    strDisplayPlaylistName=[playListNameArray objectAtIndex:row];
        //    [cell setTitle:strDisplayPlaylistName];
        [cell setAllowsMixedState:YES];
        [cell setButtonType:NSSwitchButton];
        [cell setTitle:@""];
        [cell setEnabled:NO];
        return cell;
    }
    return nil;
     
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn *)column row:(NSInteger)row {  
//    if ([column.identifier isEqualToString:@"1"]) {
//        [[events objectAtIndex:row] setValue:value forKey:@"isSelected"];
//        [self decideOverallSelectionCheckboxState:allEvents];
//    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
#warning very unoptimized code here. should check event class first and then check column
    if ([tableColumn.identifier isEqualToString:@"1"]) {
        BOOL value = isSelected;
        return [NSNumber numberWithInteger:(value ? NSOnState : NSOffState)];
    }
    if ([tableColumn.identifier isEqualToString:@"2"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        
        NSDate *date = [[events objectAtIndex:row] valueForKey:@"chartTime"];
        //  NSLog(@"%@", date);
        
        NSString *formattedDateString = [dateFormatter stringFromDate:date];
        [[tableColumn headerCell] setTitle:@"time"];
        return formattedDateString;
    }
    else if([tableColumn.identifier isEqualToString:@"3"]) {
        if ([eventClass isEqualToString:@"MedEvent"]) {
            [[tableColumn headerCell] setTitle:@"dose"];
            return [[events objectAtIndex:row] valueForKey:@"dose"];
        }
        else if([eventClass isEqualToString:@"LabEvent"]) {
            [[tableColumn headerCell] setTitle:@"value"];
            return [[events objectAtIndex:row] valueForKey:@"value"];
        }
        else if([eventClass isEqualToString:@"IOEvent"]) {
            [[tableColumn headerCell] setTitle:@"io volume"];
            return [[events objectAtIndex:row] valueForKey:@"volume"];
        }
        else if([eventClass isEqualToString:@"ChartEvent"]) {
            [[tableColumn headerCell] setTitle:@"value 1"];
            return [[events objectAtIndex:row] valueForKey:@"value1"];
        }
    }
    else if([tableColumn.identifier isEqualToString:@"4"]) {
        if ([eventClass isEqualToString:@"MedEvent"]) {
            [[tableColumn headerCell] setTitle:@"dose unit"];
            return [[events objectAtIndex:row] valueForKey:@"doseUnit"];
        }
        else if([eventClass isEqualToString:@"LabEvent"]) {
            [[tableColumn headerCell] setTitle:@"unit"];
            return [[events objectAtIndex:row] valueForKey:@"valueUnit"];
        }
        else if([eventClass isEqualToString:@"IOEvent"]) {
            [[tableColumn headerCell] setTitle:@"unit"];
            return [[events objectAtIndex:row] valueForKey:@"volumeUnit"];
        }
        else if([eventClass isEqualToString:@"ChartEvent"]) {
            [[tableColumn headerCell] setTitle:@"value1 unit"];
            return [[events objectAtIndex:row] valueForKey:@"value1unit"];
        }
    }
    else if([tableColumn.identifier isEqualToString:@"5"]) {
        if ([eventClass isEqualToString:@"MedEvent"]) {
            [[tableColumn headerCell] setTitle:@"route"];
            return [[events objectAtIndex:row] valueForKey:@"route"];
        }
        else if([eventClass isEqualToString:@"LabEvent"]) {
            [[tableColumn headerCell] setTitle:@"flag"];
            return [[events objectAtIndex:row] valueForKey:@"flag"];
        }
        else if([eventClass isEqualToString:@"IOEvent"]) {
            [[tableColumn headerCell] setTitle:@"item"];
            return [[events objectAtIndex:row] valueForKey:@"label"];
        }
        else if([eventClass isEqualToString:@"ChartEvent"]) {
            [[tableColumn headerCell] setTitle:@"value 2"];
            return [[events objectAtIndex:row] valueForKey:@"value2"];
        }
    }
    else if([tableColumn.identifier isEqualToString:@"6"]) {
        if ([eventClass isEqualToString:@"MedEvent"]) {
            [[tableColumn headerCell] setTitle:@"solution volume"];
            return [[events objectAtIndex:row] valueForKey:@"solutionVolume"];
        }
        else if([eventClass isEqualToString:@"LabEvent"]) {
            [[tableColumn headerCell] setTitle:@"sample type"];
            return [[events objectAtIndex:row] valueForKey:@"sampleType"];
        }
        else if([eventClass isEqualToString:@"IOEvent"]) {
            [[tableColumn headerCell] setTitle:@""];
            return @"";
        }
        else if([eventClass isEqualToString:@"ChartEvent"]) {
            [[tableColumn headerCell] setTitle:@"value2 unit"];
            return [[events objectAtIndex:row] valueForKey:@"value2unit"];
        }
    }
    else if([tableColumn.identifier isEqualToString:@"7"]) {
        if ([eventClass isEqualToString:@"MedEvent"]) {
            [[tableColumn headerCell] setTitle:@"solution volume unit"];
            return [[events objectAtIndex:row] valueForKey:@"solutionUnit"];
        }
        else if([eventClass isEqualToString:@"LabEvent"]) {
            [[tableColumn headerCell] setTitle:@"test category"];
            return [[events objectAtIndex:row] valueForKey:@"category"];
        }
        else if([eventClass isEqualToString:@"IOEvent"]) {
            [[tableColumn headerCell] setTitle:@""];
            return @"";
        }
        else if([eventClass isEqualToString:@"ChartEvent"]) {
            [[tableColumn headerCell] setTitle:@""];
            return @"";
        }
    }
    
    return @"";
}

- (void) renderDataWithGraphRenderer:(NSArray *)_array
{
    @autoreleasepool {
        if ([_array count] > 0) {
            NSMutableDictionary *renderSettingDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"400", @"width", @"400", @"height", nil];
            NSMutableString *csvString = [NSMutableString string];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            
            
            NSError *error = nil;
            
            if ([eventClass isEqualToString:@"MedEvent"]) {
                [renderSettingDict setObject:[[events objectAtIndex:0] valueForKey:@"doseUnit"] forKey:@"unit"];
                NSArray *names = [NSArray arrayWithObjects:@"MED", nil];
                [renderSettingDict setObject:names forKey:@"names"];
                for (int i = 0; i < [_array count] - 1; i++) {
                    NSManagedObject *event = [events objectAtIndex:i];
                    NSDate *date = [event valueForKey:@"chartTime"];            
                    NSString *formattedDateString = [dateFormatter stringFromDate:date];
                    NSString *dose = [event valueForKey:@"dose"];
                    
                    if ([dose length] > 0) {
                        [csvString appendFormat:@"%@,%@\n", formattedDateString, dose];
                        if (i == [_array count] - 1) {
                            [csvString appendFormat:@"%@,%@", formattedDateString, dose];
                        }
                    }
                    
                }
                
                NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MED.csv"];
                [csvString writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&error];
            }
            else if([eventClass isEqualToString:@"LabEvent"]) {
                [renderSettingDict setObject:[[events objectAtIndex:0] valueForKey:@"valueUnit"] forKey:@"unit"];
                NSArray *names = [NSArray arrayWithObjects:@"LAB", nil];
                [renderSettingDict setObject:names forKey:@"names"];
                for (int i = 0; i < [_array count]; i++) {
                    NSManagedObject *event = [events objectAtIndex:i];
                    NSDate *date = [event valueForKey:@"chartTime"];            
                    NSString *formattedDateString = [dateFormatter stringFromDate:date];
                    NSString *value = [event valueForKey:@"value"];
                    
                    if ([value length] > 0) {
                        
                        [csvString appendFormat:@"%@,%@\n", formattedDateString, value];
                        if (i == [_array count] - 1) {
                            [csvString appendFormat:@"%@,%@", formattedDateString, value];
                        }
                    }
                }
                
                NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LAB.csv"];
                [csvString writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&error];
            }
            else if([eventClass isEqualToString:@"IOEvent"]) {
                [renderSettingDict setObject:[[events objectAtIndex:0] valueForKey:@"volumeUnit"] forKey:@"unit"];
                NSArray *names = [NSArray arrayWithObjects:@"IO", nil];
                [renderSettingDict setObject:names forKey:@"names"];
                for (int i = 0; i < [_array count] - 1; i++) {
                    NSManagedObject *event = [events objectAtIndex:i];
                    NSDate *date = [event valueForKey:@"chartTime"];            
                    NSString *formattedDateString = [dateFormatter stringFromDate:date];
                    NSString *volume = [event valueForKey:@"volume"];
                    
                    if ([volume length] > 0) {
                        [csvString appendFormat:@"%@,%@\n", formattedDateString, volume];
                        if (i == [_array count] - 1) {
                            [csvString appendFormat:@"%@,%@", formattedDateString, volume];
                        }
                    }
                    
                }
                
                NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"IO.csv"];
                [csvString writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&error];
            }
            else if([eventClass isEqualToString:@"ChartEvent"]) {
                [renderSettingDict setObject:@"NULL" forKey:@"unit"];
                
                NSManagedObject *event = [events objectAtIndex:0];
                NSString *value1 = [event valueForKey:@"value1"];
                NSString *value2 = [event valueForKey:@"value2"];
                if ([value2 length] > 0) {
                    NSArray *names = [NSArray arrayWithObjects:@"MISC1", @"MISC2", nil];
                    [renderSettingDict setObject:names forKey:@"names"];
                    NSMutableString *csvString2 = [NSMutableString string];
                    for (int i = 0; i < [_array count] - 1; i++) {
                        NSManagedObject *event = [events objectAtIndex:i];
                        NSDate *date = [event valueForKey:@"chartTime"];            
                        NSString *formattedDateString = [dateFormatter stringFromDate:date];
                        value1 = [event valueForKey:@"value1"];
                        value2 = [event valueForKey:@"value2"];
                        
                        if ([value1 length] > 0) {
                            [csvString appendFormat:@"%@,%@\n", formattedDateString, value1];
                            if (i == [_array count] - 1) {
                                [csvString appendFormat:@"%@,%@", formattedDateString, value1];
                            }
                        }
                        if ([value2 length] > 0) {
                            [csvString2 appendFormat:@"%@,%@\n", formattedDateString, value2];
                            if (i == [_array count] - 1) {
                                [csvString2 appendFormat:@"%@,%@", formattedDateString, value2];
                            }
                            
                        }
                        
                    }
                    
                    NSString *path1 = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MISC1.csv"];
                    [csvString writeToFile:path1 atomically:NO encoding:NSUTF8StringEncoding error:&error];
                    NSString *path2 = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MISC2.csv"];
                    [csvString2 writeToFile:path2 atomically:NO encoding:NSUTF8StringEncoding error:&error];
                }
                else
                {
                    NSArray *names = [NSArray arrayWithObjects:@"MISC", nil];
                    [renderSettingDict setObject:names forKey:@"names"];
                    for (int i = 0; i < [_array count] - 1; i++) {
                        NSManagedObject *event = [events objectAtIndex:i];
                        NSDate *date = [event valueForKey:@"chartTime"];            
                        NSString *formattedDateString = [dateFormatter stringFromDate:date];
                        
                        value1 = [event valueForKey:@"value1"];
                        if ([value1 length] > 0) {
                            [csvString appendFormat:@"%@,%@\n", formattedDateString, value1];
                            
                            if (i == [_array count] - 1) {
                                [csvString appendFormat:@"%@,%@", formattedDateString, value1];
                            }
                        }
                        
                    }
                    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MISC.csv"];
                    [csvString writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&error];
                }
            }
            //NSLog(@"%@", renderSettingDict);
            [mbwc.hscrv renderDataDescriptors:renderSettingDict];
        } //events count > 0

    }
        
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentPatient"]) {
        Patient *newPatient = [change objectForKey:@"new"];
        self.patient = newPatient;
        self.eventClass = nil;
        self.eventIdentifier = nil;
    }
    else
    {
        
    }
    
}

@end
