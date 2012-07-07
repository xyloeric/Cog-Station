//
//  ChartEventTableViewController.h
//  MimicIIDataBrowser
//
//  Created by Eric on 6/16/11.
//  Copyright 2011 UT. All rights reserved.
//

#import "BrowserTableViewController.h"
#import "ChartEventNode.h" 

@interface ChartEventTableViewController : BrowserTableViewController <NSPopoverDelegate> {
    ChartEventNode *cen;
    
    NSString *previousPath;
    
    NSPopover *termEditorPopover;
}
@property (nonatomic, retain) ChartEventNode *cen;
@property (nonatomic, retain) NSString *previousPath;
@property (nonatomic, retain) NSPopover *termEditorPopover;

- (void) handleDoubleClick:(id)sender;
- (ChartConcept *)getChartConceptWithName:(NSString *)_name;
- (void)showPopupDataRendererFromRect:(NSRect)_rect withConcept:(ChartConcept *)_concept;

@end
