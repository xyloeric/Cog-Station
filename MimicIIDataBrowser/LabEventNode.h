//
//  LabEventNode.h
//  MimicIIDataBrowser
//
//  Created by zli on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Node.h"


@interface LabEventNode : Node {
@private
    NSArray *sampleTypes;
    NSArray *categories;
    NSArray *individualTestNames;
    
    NSString *currentSampleType;
    NSString *currentCategory;
}

@property (nonatomic, retain) NSArray *sampleTypes, *categories, *individualTestNames;
@property (nonatomic, retain) NSString *currentSampleType, *currentCategory;

- (NSArray *)childrenWithItem:(NSString *)_item;
- (NSInteger)childrenCountWithColNum:(NSInteger)_column;
- (NSInteger)childrenCountWithItem:(NSString *)_item;
- (BOOL) hasChildrenWithItem:(NSString *)_item;


@end
