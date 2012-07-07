//
//  Session.h
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright (c) 2011 UTHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogEvent;

@interface Session : NSManagedObject

@property (nonatomic, retain) NSString * audioFileName;
@property (nonatomic, retain) NSNumber * startTimeValue;
@property (nonatomic, retain) NSNumber * startTimeScale;
@property (nonatomic, retain) NSString * participant;
@property (nonatomic, retain) NSString * flag;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * patientSN;
@property (nonatomic, retain) NSSet *logEvents;
@end

@interface Session (CoreDataGeneratedAccessors)

- (void)addLogEventsObject:(LogEvent *)value;
- (void)removeLogEventsObject:(LogEvent *)value;
- (void)addLogEvents:(NSSet *)values;
- (void)removeLogEvents:(NSSet *)values;

@end
