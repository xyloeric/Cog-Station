//
//  LabEvent.h
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright (c) 2011 UTHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LabConcept, Patient;

@interface LabEvent : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * sampleType;
@property (nonatomic, retain) NSString * flag;
@property (nonatomic, retain) NSString * valueUnit;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * testName;
@property (nonatomic, retain) NSDate * chartTime;
@property (nonatomic, retain) NSNumber * isSelected;
@property (nonatomic, retain) Patient *patient;
@property (nonatomic, retain) LabConcept *concept;

@end
