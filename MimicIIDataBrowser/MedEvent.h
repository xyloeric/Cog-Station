//
//  MedEvent.h
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright (c) 2011 UTHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MedConcept, Patient;

@interface MedEvent : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * doseUnit;
@property (nonatomic, retain) NSString * dose;
@property (nonatomic, retain) NSString * solutionVolume;
@property (nonatomic, retain) NSString * solutionUnit;
@property (nonatomic, retain) NSDate * chartTime;
@property (nonatomic, retain) NSString * route;
@property (nonatomic, retain) NSNumber * isSelected;
@property (nonatomic, retain) Patient *patient;
@property (nonatomic, retain) MedConcept *concept;

@end
