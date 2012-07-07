//
//  PlayerWindowController.m
//  Cog Station
//
//  Created by Zhe Li on 10/2/11.
//  Copyright (c) 2011 UT. All rights reserved.
//

#import "PlayerWindowController.h"

@implementation PlayerWindowController
@synthesize reviewingSession;
@synthesize arrayController;
@synthesize logEventArray;
@synthesize selectedEvent;
@synthesize selectedEvents;
@synthesize playerObserver;
@synthesize player;

@synthesize playerCurrentTime;

- (id)initWithWindowNibName:(NSString *)windowNibName andSession:(Session *)_session
{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        self.reviewingSession = _session;
        startTime = CMTimeMake([_session.startTimeValue longLongValue], [_session.startTimeScale intValue]);

        self.logEventArray = [reviewingSession.logEvents allObjects];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventDate" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        self.logEventArray = [logEventArray sortedArrayUsingDescriptors:sortDescriptors];
        [sortDescriptors release];
        [sortDescriptor release];

        [self showWindow:nil];
        
    }
    
    return self;
}

- (void) dealloc
{
    [reviewingSession release];
    [arrayController release];
    [logEventArray release];
    [player release];
    [playerObserver release];
    [playerCurrentTime release];
    
    [super dealloc];
}

- (void)setPlayerCurrentTime:(NSNumber *)_playerCurrentTime
{
    if (playerCurrentTime != _playerCurrentTime) {
        [playerCurrentTime release];
        playerCurrentTime = [_playerCurrentTime retain];
        
        //[player seekToTime:CMTimeMakeWithSeconds([playerCurrentTime floatValue], 96000)];
        //NSLog(@"%@", playerCurrentTime);
    }
}

- (IBAction)sliderDrag:(id)sender
{
    double seekToSecond = [((NSSlider *)sender) doubleValue];
    [player seekToTime:CMTimeMakeWithSeconds(seekToSecond, 96000)];
}

- (void) awakeFromNib
{   
    [playButton setImage:[NSImage imageNamed:@"playButton.png"]]; 
    [playButton setImagePosition:NSImageOnly];
    AVAsset *avAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:reviewingSession.audioFileName]];
    Float64 durationSeconds = CMTimeGetSeconds([avAsset duration]);

    timeSlider.minValue = 0.0f;
    timeSlider.maxValue = durationSeconds;
    
    
    AVPlayerItem *avPlayerItem = [AVPlayerItem playerItemWithAsset:avAsset];
    player = [[AVPlayer alloc] initWithPlayerItem:avPlayerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    [((NSView *)self.window.contentView).layer addSublayer:playerLayer];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playerItemDidReachEnd:)
     name:AVPlayerItemDidPlayToEndTimeNotification
     object:player.currentItem];
    
//    CMTime firstThird = CMTimeMakeWithSeconds(durationSeconds/3.0, 1);
//    CMTime secondThird = CMTimeMakeWithSeconds(durationSeconds*2.0/3.0, 1);
//    NSArray *times = [NSArray arrayWithObjects:[NSValue valueWithCMTime:firstThird], [NSValue valueWithCMTime:secondThird], nil];
    
    self.playerObserver = [player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time){
        // Passing NULL for the queue specifies the main queue.
        self.playerCurrentTime = [NSNumber numberWithFloat:CMTimeGetSeconds([self.player currentTime])];
    }];
    
    [eventTableView reloadData];
    //[self syncUI];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
    [self release];
}

- (void) setSelectedEvents:(NSIndexSet *)_selectedEvents
{
    if (selectedEvents != _selectedEvents) {
        selectedEvents = _selectedEvents;
        selectedEvent = [[arrayController arrangedObjects] objectAtIndex:[selectedEvents firstIndex]];
        
        CMTime originalTime = CMTimeMake([selectedEvent.audioTimeValue longLongValue], [selectedEvent.audioScale intValue]);
        CMTime realTime = CMTimeSubtract(originalTime, startTime);
//        NSLog(@"%lld, %i", player.currentTime.value, player.currentTime.timescale);
//        NSLog(@"%lld, %i", realTime.value, realTime.timescale);
//        NSLog(@"%@, %@", selectedEvent.audioTimeValue, selectedEvent.audioScale);
        [player seekToTime:realTime];
    }
}

- (void)syncUI {
    if ((player.currentItem != nil) &&
        ([player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
        playButton.enabled = YES;
    }
    else {
        playButton.enabled = NO;
    }
}

- (IBAction)play:(id)sender
{
    if ([sender state] == NSOnState) {
        [player play];
        [sender setState:NSOnState];
    }
    else {
        [player pause];
        [sender setState:NSOffState];
    }
     
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [player seekToTime:kCMTimeZero];
    [playButton setState:NSOffState];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [logEventArray count];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn *)column row:(NSInteger)row { 

}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    LogEvent *_theLogEvent = [logEventArray objectAtIndex:row];
    
    if ([tableColumn.identifier isEqualToString:@"1"]) {
        NSDate *_eventDate = _theLogEvent.eventDate;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
                                          
        NSString *formattedDate = [dateFormatter stringFromDate:_eventDate];
        [dateFormatter release];
        return formattedDate;
    }
    else if ([tableColumn.identifier isEqualToString:@"2"]) {
        return _theLogEvent.path;
    }
    else if ([tableColumn.identifier isEqualToString:@"3"]) {
        return _theLogEvent.action;
    }
    
    return nil;
}

-(void)tableView:(NSTableView *)tableView sortDescriptorsDidChange: (NSArray *)oldDescriptors 
{       
    NSArray *newDescriptors = [tableView sortDescriptors];
    self.logEventArray = [logEventArray sortedArrayUsingDescriptors:newDescriptors]; 
    //"results" is my NSMutableArray which is set to be the data source for the NSTableView object.
    [tableView reloadData]; 
}

- (IBAction)tableViewSelected:(id)sender
{
    NSInteger row = [sender selectedRow];
    
    if (row < [logEventArray count] && row >= 0) {
        self.selectedEvent = [logEventArray objectAtIndex:row];
        CMTime originalTime = CMTimeMake([selectedEvent.audioTimeValue longLongValue], [selectedEvent.audioScale intValue]);
        CMTime realTime = CMTimeSubtract(originalTime, startTime);
        [player seekToTime:realTime];
    }
    else {
        [eventTableView deselectAll:nil];
    }
    
}

@end
