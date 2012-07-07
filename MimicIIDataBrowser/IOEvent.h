//
//  IOEvent.h
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright (c) 2011 UTHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IOConcept, Patient;

@interface IOEvent : NSManagedObject

@property (nonatomic, retain) NSString * volume;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * volumeUnit;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSDate * chartTime;
@property (nonatomic, retain) NSNumber * isSelected;
@property (nonatomic, retain) Patient *patient;
@property (nonatomic, retain) IOConcept *concept;

@end
