//
//  SearchWindowController.h
//  MimicIIDataBrowser
//
//  Created by zli on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainBrowserWindowController.h"

@interface SearchWindowController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource>  {
@private
    
    NSSearchField *searchField;
    NSTableView *labTableView;
    NSTableView *medTableView;
    NSTableView *ioTableView;
    NSTableView *miscTableView;
    
    NSArray *labResultArray;
    NSArray *medResultArray;
    NSArray *ioResultArray;
    NSArray *miscResultArray;
    
    NSMutableArray			*allKeywords;
	NSMutableArray			*builtInKeywords;
    BOOL					completePosting;
    BOOL					commandHandling;
    
    NSManagedObjectContext *managedObjectContext;
    MainBrowserWindowController *mbwc;
    
}
@property (assign) IBOutlet NSSearchField *searchField;
@property (assign) IBOutlet NSTableView *labTableView;
@property (assign) IBOutlet NSTableView *medTableView;
@property (assign) IBOutlet NSTableView *ioTableView;
@property (assign) IBOutlet NSTableView *miscTableView;


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) MainBrowserWindowController *mbwc;

@property (nonatomic, retain) NSArray *labResultArray, *medResultArray, *ioResultArray, *miscResultArray;

-(id)initWithWindowNibName:(NSString *)windowNibName andManagedObjectContext:(NSManagedObjectContext *)_managedObjectContext andMBWC:(MainBrowserWindowController *)_mbwc;

@end
