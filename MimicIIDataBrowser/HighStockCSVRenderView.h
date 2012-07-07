//
//  HighStockCSVRenderView.h
//  HighChartTest
//
//  Created by Zhe Li on 8/16/11.
//  Copyright 2011 UT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface HighStockCSVRenderView : WebView
{
    NSMutableString * templateString;
    NSDictionary * currentSettingDict;
}

@property (nonatomic, retain) NSMutableString * templateString;
@property (nonatomic, retain) NSDictionary * currentSettingDict;

- (void)renderDataDescriptors:(NSDictionary *)_descriptorDict;

@end
