//
//  PlayerWindowController.h
//  Cog Station
//
//  Created by Zhe Li on 10/2/11.
//  Copyright (c) 2011 UT. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Session.h"
#import <AVFoundation/AVFoundation.h>
#import "LogEvent.h"

@interface PlayerWindowController : NSWindowController <NSWindowDelegate>
{
    Session *reviewingSession;
    NSArrayController *arrayController;
    NSArray *logEventArray;
    
    IBOutlet NSButton *playButton;

    AVPlayer *player;
    
    LogEvent *selectedEvent;
    NSIndexSet *selectedEvents;
    CMTime startTime;
    
    id playerObserver;
    IBOutlet NSSlider *timeSlider;
    NSNumber * playerCurrentTime;
    
    IBOutlet NSTableView *eventTableView;
    
}

@property (nonatomic, retain) Session *reviewingSession;
@property (nonatomic, retain) IBOutlet NSArrayController *arrayController;
@property (nonatomic, retain) NSArray *logEventArray;
@property (assign) LogEvent *selectedEvent;
@property (nonatomic, assign) NSIndexSet *selectedEvents;
@property (nonatomic, retain) id playerObserver;
@property (nonatomic, retain) AVPlayer *player;

@property (nonatomic, retain) NSNumber * playerCurrentTime;

- (id)initWithWindowNibName:(NSString *)windowNibName andSession:(Session *)_session;
- (IBAction)play:(id)sender;
- (IBAction)sliderDrag:(id)sender;
- (void)syncUI;
- (void)playerItemDidReachEnd:(NSNotification *)notification;

- (IBAction)tableViewSelected:(id)sender;

@end
