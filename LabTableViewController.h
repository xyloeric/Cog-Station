//
//  LabTableViewController.h
//  MimicIIDataBrowser
//
//  Created by Eric Li on 6/2/11.
//  Copyright 2011 UTH. All rights reserved.
//
#import <Cocoa/Cocoa.h>

#import "BrowserTableViewController.h"
#import "LabEventNode.h"

@interface LabTableViewController : BrowserTableViewController <NSPopoverDelegate> {
    LabEventNode *len;
    
    NSPopover *termEditorPopover;

}

@property (nonatomic, retain) LabEventNode *len;
@property (nonatomic, retain) NSPopover *termEditorPopover;

- (void) handleDoubleClick:(id)sender;
- (LabConcept *)getLabConceptWithName:(NSString *)_name andSampleType:(NSString *)_sampleType;
- (void)showPopupDataRendererFromRect:(NSRect)_rect withConcept:(LabConcept *)_concept;

@end
