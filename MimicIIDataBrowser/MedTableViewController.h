//
//  MedTableViewController.h
//  MimicIIDataBrowser
//
//  Created by zli on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>

#import "BrowserTableViewController.h"
#import "MedEventNode.h"

@interface MedTableViewController : BrowserTableViewController <NSPopoverDelegate> {
    MedEventNode *men;
    
    NSPopover *termEditorPopover;

}
@property (nonatomic, retain) MedEventNode *men;
@property (nonatomic, retain) NSPopover *termEditorPopover;

- (void) handleDoubleClick:(id)sender;
- (MedConcept *)getMedConceptWithName:(NSString *)_name andRoute:(NSString *)_route;
- (void)showPopupDataRendererFromRect:(NSRect)_rect withConcept:(MedConcept *)_concept;

@end
