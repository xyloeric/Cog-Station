//
//  TermBrowserController.h
//  Cog Station
//
//  Created by Zhe Li on 10/14/11.
//  Copyright 2011 UTHealth. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface TermBrowserController : NSObject <NSTableViewDelegate, NSTableViewDataSource>
{
    NSManagedObjectContext *managedObjectContext;
    NSArray *conceptArray;
    
    IBOutlet NSTableView *tableView;
    IBOutlet NSTextField *conceptCount;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *conceptArray;

- (void) setUpContent;
- (IBAction)refresh:(id)sender;

@end
