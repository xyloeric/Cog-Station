//
//  IOEventNode.h
//  MimicIIDataBrowser
//
//  Created by zli on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Node.h"


@interface IOEventNode : Node {
    NSArray *IOCategories;
    NSArray *individualIOItems;
    
    NSString *currentIOCategory;
    
}

@property (nonatomic, retain) NSArray *IOCategories, *individualIOItems;
@property (nonatomic, retain) NSString *currentIOCategory;

- (NSArray *)childrenWithItem:(NSString *)_item;
- (NSInteger)childrenCountWithItem:(NSString *)_item;
- (BOOL) hasChildrenWithItem:(NSString *)_item;

@end
