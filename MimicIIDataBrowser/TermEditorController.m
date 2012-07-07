//
//  TermEditorController.m
//  Cog Station
//
//  Created by Zhe Li on 10/13/11.
//  Copyright 2011 UTHealth. All rights reserved.
//

#import "TermEditorController.h"
#import "IOConcept.h"
#import "MedConcept.h"
#import "LabConcept.h"
#import "ChartConcept.h"

@implementation TermEditorController
@synthesize conceptObject;
@synthesize containerPopover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil conceptObject:(NSManagedObject *)_conceptObject andConceptType:(NSUInteger)_conceptType
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.conceptObject = _conceptObject;
        conceptType = _conceptType;
    }
    
    return self;
}

- (void)dealloc
{   
    [conceptObject release];
    [super dealloc];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    switch (conceptType) {
        case kConceptTypeIO:
        {
            return 3;
        }
            break;
        case kConceptTypeMed:
        {
            return 4;
        }
            break;
        case kConceptTypeLab:
        {
            return 4;
        }
            break;
        case kConceptTypeChart:
        {
            return 3;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn *)column row:(NSInteger)row { 
    switch (conceptType) {
        case kConceptTypeIO:
        {
            if ([column.identifier isEqualToString:@"2"]) {
                switch (row) {
                    case 1:
                    {
                        [conceptObject setValue:value forKey:@"cui"];
                    }
                        break;
                    case 2:
                    {
                        [conceptObject setValue:value forKey:@"preferredTerm"];
                    }
                        break;
                        
                    default:
                        break;
                }
            }

        }
            break;
        case kConceptTypeMed:
        {
            if ([column.identifier isEqualToString:@"2"]) {
                switch (row) {
                    case 3:
                    {
                        [conceptObject setValue:value forKey:@"cui"];
                    }
                        break;
                    case 4:
                    {
                        [conceptObject setValue:value forKey:@"preferredTerm"];
                    }
                        break;
                        
                    default:
                        break;
                }
            }

        }
            break;
        case kConceptTypeLab:
        {
            if ([column.identifier isEqualToString:@"2"]) {
                switch (row) {
                    case 3:
                    {
                        [conceptObject setValue:value forKey:@"cui"];
                    }
                        break;
                    case 4:
                    {
                        [conceptObject setValue:value forKey:@"preferredTerm"];
                    }
                        break;
                        
                    default:
                        break;
                }
            }

        }
            break;
        case kConceptTypeChart:
        {
            if ([column.identifier isEqualToString:@"2"]) {
                switch (row) {
                    case 1:
                    {
                        [conceptObject setValue:value forKey:@"cui"];
                    }
                        break;
                    case 2:
                    {
                        [conceptObject setValue:value forKey:@"preferredTerm"];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
            break;
        default:
            break;
    }
    
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    switch (conceptType) {
        case kConceptTypeIO:
        {
            if ([tableColumn.identifier isEqualToString:@"1"]) {
                switch (row) {
                    case 0:
                    {
                        return @"Mimic II Term";
                    }
                        break;
                    case 1:
                    {
                        return @"CUI";
                    }
                        break;
                    case 2:
                    {
                        return @"Preferred Term";
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            else {
                switch (row) {
                    case 0:
                    {
                        return [conceptObject valueForKey:@"mimiciiTerm"];
                    }
                        break;
                    case 1:
                    {
                        return [conceptObject valueForKey:@"cui"];
                    }
                        break;
                    case 2:
                    {
                        return [conceptObject valueForKey:@"preferredTerm"];
                    }
                        break;
                        
                    default:
                        break;
                }
                
            }

        }
            break;
        case kConceptTypeMed:
        {
            if ([tableColumn.identifier isEqualToString:@"1"]) {
                switch (row) {
                    case 0:
                    {
                        return @"Mimic II Term";
                    }
                        break;
                    case 1:
                    {
                        return @"Route";
                    }
                        break;
                    case 2:
                    {
                        return @"CUI";
                    }
                        break;
                    case 3:
                    {
                        return @"Preferred Term";
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            else {
                switch (row) {
                    case 0:
                    {
                        return [conceptObject valueForKey:@"mimiciiTerm"];
                    }
                        break;
                    case 1:
                    {
                        return [conceptObject valueForKey:@"route"];
                    }
                        break;
                    case 2:
                    {
                        return [conceptObject valueForKey:@"cui"];
                    }
                        break;
                    case 3:
                    {
                        return [conceptObject valueForKey:@"preferredTerm"];
                    }
                        break;
                        
                    default:
                        break;
                }
                
            }

        }
            break;
        case kConceptTypeLab:
        {
            if ([tableColumn.identifier isEqualToString:@"1"]) {
                switch (row) {
                    case 0:
                    {
                        return @"Mimic II Term";
                    }
                        break;
                    case 1:
                    {
                        return @"Sample Type";
                    }
                        break;
                    case 2:
                    {
                        return @"CUI";
                    }
                        break;
                    case 3:
                    {
                        return @"Preferred Term";
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            else {
                switch (row) {
                    case 0:
                    {
                        return [conceptObject valueForKey:@"mimiciiTerm"];
                    }
                        break;
                    case 1:
                    {
                        return [conceptObject valueForKey:@"sampleType"];
                    }
                        break;
                    case 2:
                    {
                        return [conceptObject valueForKey:@"cui"];
                    }
                        break;
                    case 3:
                    {
                        return [conceptObject valueForKey:@"preferredTerm"];
                    }
                        break;
                        
                    default:
                        break;
                }
                
            }

        }
            break;
        case kConceptTypeChart:
        {
            if ([tableColumn.identifier isEqualToString:@"1"]) {
                switch (row) {
                    case 0:
                    {
                        return @"Mimic II Term";
                    }
                        break;
                    case 1:
                    {
                        return @"CUI";
                    }
                        break;
                    case 2:
                    {
                        return @"Preferred Term";
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            else {
                switch (row) {
                    case 0:
                    {
                        return [conceptObject valueForKey:@"mimiciiTerm"];
                    }
                        break;
                    case 1:
                    {
                        return [conceptObject valueForKey:@"cui"];
                    }
                        break;
                    case 2:
                    {
                        return [conceptObject valueForKey:@"preferredTerm"];
                    }
                        break;
                        
                    default:
                        break;
                }

            }
        }
            break;
        default:
            break;
    }
    
    return nil;
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableColumn.identifier isEqualToString:@"2"]) {
        switch (conceptType) {
            case kConceptTypeIO:
            {
                switch (row) {
                    case 1:
                        return YES;
                        break;
                    case 2:
                        return YES;
                        break;
                    default:
                        break;
                }

            }
                break;
            case kConceptTypeMed:
            {
                switch (row) {
                    case 3:
                        return YES;
                        break;
                    case 4:
                        return YES;
                        break;
                    default:
                        break;
                }

            }
                break;
            case kConceptTypeLab:
            {
                switch (row) {
                    case 3:
                        return YES;
                        break;
                    case 4:
                        return YES;
                        break;
                    default:
                        break;
                }
            }
                break;
            case kConceptTypeChart:
            {
                switch (row) {
                    case 1:
                        return YES;
                        break;
                    case 2:
                        return YES;
                        break;
                    default:
                        break;
                }

            }
                break;
            default:
                break;
        }
    }
    
    return NO;
}

- (IBAction)closePopover:(id)sender
{
    [containerPopover performClose:nil];
}

@end
