//
//  ChartEvent.h
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright (c) 2011 UTHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChartConcept, Patient;

@interface ChartEvent : NSManagedObject

@property (nonatomic, retain) NSString * value1;
@property (nonatomic, retain) NSString * value2unit;
@property (nonatomic, retain) NSString * value2;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSString * value1unit;
@property (nonatomic, retain) NSDate * chartTime;
@property (nonatomic, retain) NSNumber * isSelected;
@property (nonatomic, retain) Patient *patient;
@property (nonatomic, retain) ChartConcept *concept;

@end
