//
//  ChartEventNode.h
//  MimicIIDataBrowser
//
//  Created by Eric on 6/14/11.
//  Copyright 2011 UT. All rights reserved.
//

#import "Node.h"


@interface ChartEventNode : Node {
    NSArray *ChartEventCategories;
    NSArray *individualChartEventItems;
    
    NSString *currentChartEventCategory;
}

@property (nonatomic, retain) NSArray *ChartEventCategories, *individualChartEventItems;
@property (nonatomic, retain) NSString *currentChartEventCategory;

- (NSArray *)childrenWithItem:(NSString *)_item;
- (NSInteger)childrenCountWithItem:(NSString *)_item;
- (BOOL) hasChildrenWithItem:(NSString *)_item;

@end
