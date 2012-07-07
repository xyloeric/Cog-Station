//
//  LogEvent.h
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright (c) 2011 UTHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

@interface LogEvent : NSManagedObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSNumber * audioTimeValue;
@property (nonatomic, retain) NSDate * eventDate;
@property (nonatomic, retain) NSNumber * audioScale;
@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) Session *session;

@end
