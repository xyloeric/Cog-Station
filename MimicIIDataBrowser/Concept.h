//
//  Concept.h
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright (c) 2011 UTHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Concept : NSManagedObject

@property (nonatomic, retain) NSString * cui;
@property (nonatomic, retain) NSString * mimiciiTerm;
@property (nonatomic, retain) NSString * preferredTerm;

@end
