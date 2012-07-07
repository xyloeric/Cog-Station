//
//  HighStockCSVRenderView.m
//  HighChartTest
//
//  Created by Zhe Li on 8/16/11.
//  Copyright 2011 UT. All rights reserved.
//

#import "HighStockCSVRenderView.h"

@implementation HighStockCSVRenderView
@synthesize templateString;
@synthesize currentSettingDict;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        NSError *error = nil;
        self.templateString = [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"template" ofType:@"htm"] encoding:NSUTF8StringEncoding error:&error];
    }
    
    return self;
}

- (void)dealloc
{
    [currentSettingDict release];
    [templateString release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    NSLog(@"%@", templateString);
}

- (void) resizeWithOldSuperviewSize:(NSSize)oldSize
{
    NSLog(@"called");
    self.frame = NSMakeRect(17.0f, 7.0f, [self superview].frame.size.width - 20.0f, [self superview].frame.size.height - 10.0f);
    if (currentSettingDict) {
        [self renderDataDescriptors:currentSettingDict];
    }
}

- (void)renderDataDescriptors:(NSDictionary *)_descriptorDict
{
    @autoreleasepool {        
        
        NSError *error = nil;
        self.currentSettingDict = _descriptorDict;
        self.templateString = [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"template" ofType:@"htm"] encoding:NSUTF8StringEncoding error:&error];
        
        NSArray *nameArray = [_descriptorDict objectForKey:@"names"];
        NSMutableString *namesString = [[NSMutableString alloc] init];
        for (int i = 0; i < [nameArray count]-1; i++) {
            [namesString appendFormat:@"'%@',", [nameArray objectAtIndex:i]];
        }
        [namesString appendFormat:@"'%@'", [nameArray lastObject]];
        
        NSString *unitString = [NSString stringWithFormat:@"'%@'", [_descriptorDict objectForKey:@"unit"]];
        
        NSString *widthString = [NSString stringWithFormat:@"%f", self.frame.size.width-20];
        
        NSString *heightString = [NSString stringWithFormat:@"%f", self.frame.size.height-20];
        
        NSLog(@"%@, %@", widthString, heightString);
        
        [templateString replaceOccurrencesOfString:@"%names%" withString:namesString options:NSCaseInsensitiveSearch range:NSMakeRange(0, [templateString length])];
        
        [templateString replaceOccurrencesOfString:@"%unit%" withString:unitString options:NSCaseInsensitiveSearch range:NSMakeRange(0, [templateString length])];
        
        [templateString replaceOccurrencesOfString:@"%width%" withString:widthString options:NSCaseInsensitiveSearch range:NSMakeRange(0, [templateString length])];
        
        [templateString replaceOccurrencesOfString:@"%height%" withString:heightString options:NSCaseInsensitiveSearch range:NSMakeRange(0, [templateString length])];
        
        NSString *path = [[NSBundle mainBundle] resourcePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
                
        [[self mainFrame] loadHTMLString:templateString baseURL:baseURL];
    }
    
}

@end
