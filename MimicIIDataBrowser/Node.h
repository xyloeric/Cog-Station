//
//  Node.h
//  MimicIIDataBrowser
//
//  Created by zli on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Patient.h"

@interface Node : NSObject {
    NSManagedObjectContext *managedObjectContext;
    Patient *patient;
    
    NSString *displayName;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Patient *patient;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)_managedObjectContext andPatient:(Patient *)_patient;
- (void) initializeNode;
- (BOOL) object1:(id)obj1 isEqualToString:(NSString *)_string;

@end
