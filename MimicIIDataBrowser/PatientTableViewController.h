//
//  PatientTableViewController.h
//  MimicIIDataBrowser
//
//  Created by zli on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainBrowserWindowController;

@interface PatientTableViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>{

    
    NSTableView *patientBrowserTable;
    
    NSManagedObjectContext *managedObjectContext;
    
    MainBrowserWindowController *mbwc;
    
    NSArray *patientArray;
}
@property (nonatomic, retain)  NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) MainBrowserWindowController *mbwc;
@property (assign) IBOutlet NSTableView *patientBrowserTable;
@property (nonatomic, retain) NSArray *patientArray;

- (void)testQuery;
- (IBAction)tableViewSelected:(id)sender;

@end
