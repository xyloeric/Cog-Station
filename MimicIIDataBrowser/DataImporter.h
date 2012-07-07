//
//  DataImporter.h
//  MimicIIDataBrowser
//
//  Created by zli on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DataImporter : NSObject {
@private
    NSManagedObjectContext *managedObjectContext;
    
    NSString *inputPath;
    
    NSTimeInterval startTimeInterval;
    NSTimeInterval endTimeInterval;
    
    NSMutableDictionary *labConcepts;
    NSMutableDictionary *medConcepts;
    NSMutableDictionary *chartConcepts;
    NSMutableDictionary *ioConcepts;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)_managedObjectContext;

- (void)prepareConceptsDictionaries;

- (void)loadPatientDemographics;
@end
