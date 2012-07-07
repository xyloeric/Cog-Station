//
//  BrowseTableViewController.h
//  MimicIIDataBrowser
//
//  Created by Eric Li on 6/2/11.
//  Copyright 2011 UTH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainBrowserWindowController;
@class Patient;

@interface BrowserTableViewController : NSViewController <NSBrowserDelegate> {

    NSManagedObjectContext *managedObjectContext;
    MainBrowserWindowController *mbwc;
    
    NSArray *eventsNameArray;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) MainBrowserWindowController *mbwc;

@property (nonatomic, retain) NSArray *eventsNameArray;

- (IBAction)tableViewSelected:(id)sender;
- (IBAction)clicked:(id)sender;
- (void)refreshTableViewWithPatient:(Patient *)_patient;
@end
