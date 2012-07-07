//
//  MedEventNode.h
//  MimicIIDataBrowser
//
//  Created by zli on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Node.h"


@interface MedEventNode : Node {
    NSArray *routes;
    NSArray *individualMedNames;
    
    NSString *currentRoute;
}

@property (nonatomic, retain) NSArray *routes, *individualMedNames;
@property (nonatomic, retain) NSString *currentRoute;

- (NSArray *)childrenWithItem:(NSString *)_item;
- (NSInteger)childrenCountWithItem:(NSString *)_item;
- (BOOL) hasChildrenWithItem:(NSString *)_item;


@end
