//
//  IOTableViewController.h
//  MimicIIDataBrowser
//
//  Created by Eric Li on 6/2/11.
//  Copyright 2011 UTH. All rights reserved.
//
#import <Cocoa/Cocoa.h>

#import "BrowserTableViewController.h"
#import "IOEventNode.h"

@interface IOTableViewController : BrowserTableViewController <NSPopoverDelegate> {
    IOEventNode *ien;
    
    NSString *previousPath;
    
    NSPopover *termEditorPopover;

}

@property (nonatomic, copy) NSString *previousPath;
@property (nonatomic, retain) IOEventNode *ien;
@property (nonatomic, retain) NSPopover *termEditorPopover;

- (void) handleDoubleClick:(id)sender;
- (IOConcept *)getIOConceptWithName:(NSString *)_name;

- (void)showPopupDataRendererFromRect:(NSRect)_rect withConcept:(IOConcept *)_concept;

@end
