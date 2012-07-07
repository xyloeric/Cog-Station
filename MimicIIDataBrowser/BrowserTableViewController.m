//
//  BrowseTableViewController.m
//  MimicIIDataBrowser
//
//  Created by Eric Li on 6/2/11.
//  Copyright 2011 UTH. All rights reserved.
//

#import "BrowserTableViewController.h"
#import "MainBrowserWindowController.h"


@implementation BrowserTableViewController
@synthesize managedObjectContext;
@synthesize mbwc;

@synthesize eventsNameArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [managedObjectContext release];
    
    [mbwc removeObserver:self forKeyPath:@"currentPatient"];
    [mbwc release];
    
    [eventsNameArray release];
    
    [super dealloc];
}

- (void)setMbwc:(MainBrowserWindowController *)_mbwc
{
    if (mbwc != _mbwc) {
        [mbwc release];
        mbwc = [_mbwc retain];
        [mbwc addObserver:self forKeyPath:@"currentPatient" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    }
}

- (IBAction)tableViewSelected:(id)sender
{
}

-(IBAction)clicked:(id)sender
{
}

- (void)refreshTableViewWithPatient:(Patient *)_patient
{
}

@end
