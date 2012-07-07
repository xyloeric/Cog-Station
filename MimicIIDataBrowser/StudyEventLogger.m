//
//  StudyEventLogger.m
//  MimicIIDataBrowser
//
//  Created by zli on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StudyEventLogger.h"
#import "Session.h"
#import "LogEvent.h"
#import "Patient.h"
#import "MainBrowserWindowController.h"

@implementation StudyEventLogger
@synthesize audioDevices;
@synthesize session;
@synthesize audioLevelMeter;
@synthesize audioLevelTimer;
@synthesize observers;
@synthesize audioFileOutput;
@synthesize audioDeviceInput;
@synthesize audioDataOutput;

@synthesize currentRecordingTime;
@synthesize currentRecordingName;

@synthesize currentSession;
@synthesize managedObjectContext;

@synthesize mbwc;

- (void) dealloc
{
    [audioDevices release];
    [session release];
    [audioFileOutput release];
    [audioDataOutput release];
    [audioDeviceInput release];
    [currentRecordingName release];
    [super dealloc];
}

- (void)awakeFromNib
{
    NSLog(@"awake");
    session = [[AVCaptureSession alloc] init];
    
    // Capture Notification Observers
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    id runtimeErrorObserver = [notificationCenter addObserverForName:AVCaptureSessionRuntimeErrorNotification
                                                              object:session
                                                               queue:[NSOperationQueue mainQueue]
                                                          usingBlock:^(NSNotification *note) {
                                                              dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                              });
                                                          }];
    id didStartRunningObserver = [notificationCenter addObserverForName:AVCaptureSessionDidStartRunningNotification
                                                                 object:session
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 NSLog(@"did start running");
                                                             }];
    id didStopRunningObserver = [notificationCenter addObserverForName:AVCaptureSessionDidStopRunningNotification
                                                                object:session
                                                                 queue:[NSOperationQueue mainQueue]
                                                            usingBlock:^(NSNotification *note) {
                                                                NSLog(@"did stop running");
                                                            }];
    id deviceWasConnectedObserver = [notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification
                                                                    object:nil
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:^(NSNotification *note) {
                                                                    [self refreshDevices];
                                                                }];
    id deviceWasDisconnectedObserver = [notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification
                                                                       object:nil
                                                                        queue:[NSOperationQueue mainQueue]
                                                                   usingBlock:^(NSNotification *note) {
                                                                       [self refreshDevices];
                                                                   }];
    observers = [[NSArray alloc] initWithObjects:runtimeErrorObserver, didStartRunningObserver, didStopRunningObserver, deviceWasConnectedObserver, deviceWasDisconnectedObserver, nil];
    
    audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioDataOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    [session addOutput:audioDataOutput];
    
    [[self session] startRunning];

    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (audioDevice) {
        [self setSelectedAudioDevice:audioDevice];
    }
    
    [self refreshDevices];
        
    [self setAudioLevelTimer:[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateAudioLevels:) userInfo:nil repeats:YES]];
    
    [super awakeFromNib];
}

- (void)refreshDevices
{
    @try {
        [self setAudioDevices:[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio]];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
	[[self session] beginConfiguration];
	
	if (![[self audioDevices] containsObject:[self selectedAudioDevice]])
		[self setSelectedAudioDevice:nil];
	
	[[self session] commitConfiguration];
}

- (NSArray *)availableSessionPresets
{
	NSArray *allSessionPresets = [NSArray arrayWithObjects:
								  AVCaptureSessionPresetLow,
								  AVCaptureSessionPresetMedium,
								  AVCaptureSessionPresetHigh,
								  AVCaptureSessionPreset320x240,
								  AVCaptureSessionPreset352x288,
								  AVCaptureSessionPreset640x480,
								  AVCaptureSessionPreset960x540,
								  AVCaptureSessionPreset1280x720,
								  AVCaptureSessionPresetPhoto,
								  nil];
	
	NSMutableArray *availableSessionPresets = [NSMutableArray arrayWithCapacity:9];
	for (NSString *sessionPreset in allSessionPresets) {
		if ([[self session] canSetSessionPreset:sessionPreset])
			[availableSessionPresets addObject:sessionPreset];
	}
	
	return availableSessionPresets;
}

- (BOOL)hasRecordingDevice
{
	return (audioDeviceInput != nil);
}

- (BOOL)isRecording
{
	return isRecording;
}

- (void)setIsRecording:(BOOL)_isRecording
{
    @autoreleasepool {
        
        if (_isRecording) {
            
            NSError *error = nil;
            // Record to a temporary file, which the user will relocate when recording is finished
            char *tempNameBytes = tempnam([NSHomeDirectory() fileSystemRepresentation], "AVRecorder_");
            NSString *tempName = [[[NSString alloc] initWithBytesNoCopy:tempNameBytes length:strlen(tempNameBytes) encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
            NSLog(@"%@", tempName);
            
            Session *newSession = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:managedObjectContext];
            self.currentSession = newSession;
            
            currentSession.flag = [[NSDate date] description];
            currentSession.participant = @"Participant";
            currentSession.audioFileName = [NSString stringWithFormat:@"%@.m4a",tempName];
            currentSession.patientSN = mbwc.currentPatient.patientID;
            [mbwc.currentSessionObjects addObject:newSession];
            mbwc.currentSession = newSession;
            
            //		[[self audioFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:[tempName stringByAppendingPathExtension:@"m4a"]]
            //											recordingDelegate:self];
            
            audioAssetWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:[tempName stringByAppendingPathExtension:@"m4a"]] fileType:AVFileTypeAppleM4A error:&error];
            NSParameterAssert(audioAssetWriter);
            
            AudioChannelLayout acl;
            bzero( &acl, sizeof(acl));
            acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
            
            NSDictionary *audioWriterSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithUnsignedInt:kAudioFormatMPEG4AAC], AVFormatIDKey, 
                                                [NSNumber numberWithInt:64000], AVEncoderBitRateKey, 
                                                [NSNumber numberWithInt:44100], AVSampleRateKey,
                                                [NSData dataWithBytes:&acl length:sizeof(acl)], AVChannelLayoutKey,
                                                [NSNumber numberWithUnsignedInt:2], AVNumberOfChannelsKey, nil];
            
            audioAssetWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioWriterSetting];
            audioAssetWriterInput.expectsMediaDataInRealTime = YES;
            
            [audioAssetWriter addInput:audioAssetWriterInput];
            
            NSParameterAssert(audioAssetWriterInput);
            
            isRecording = YES;            
            //            BOOL success = [audioAssetWriter startWriting];
            
            //            if (success) {
            //                [audioAssetWriter startSessionAtSourceTime:kCMTimeZero];
            //                isRecording = YES;
            //            }
            //            else {
            //                error = audioAssetWriter.error;
            //                NSLog(@"%@", error);
            //            }
            
        } else {
            BOOL success = [audioAssetWriter finishWriting];
            if (!success) {
                NSError *error = audioAssetWriter.error;
                NSLog(@"%@", error);
            }
            [audioAssetWriter release];
            isRecording = NO;
            self.currentSession = nil;
        }
        
        
    }
	
}

- (AVCaptureDevice *)selectedAudioDevice
{
	return [audioDeviceInput device];
}

- (void)setSelectedAudioDevice:(AVCaptureDevice *)selectedAudioDevice
{
	[[self session] beginConfiguration];
	
	if ([self audioDeviceInput]) {
		// Remove the old device input from the session
		[session removeInput:[self audioDeviceInput]];
		[self setAudioDeviceInput:nil];
	}
	
	if (selectedAudioDevice) {
		NSError *error = nil;
		
		// Create a device input for the device and add it to the session
		AVCaptureDeviceInput *newAudioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:selectedAudioDevice error:&error];
		if (newAudioDeviceInput == nil) {
			dispatch_async(dispatch_get_main_queue(), ^(void) {

			});
		} else {
			if (![selectedAudioDevice supportsAVCaptureSessionPreset:[session sessionPreset]])
				[[self session] setSessionPreset:AVCaptureSessionPresetHigh];
			
			[[self session] addInput:newAudioDeviceInput];
			[self setAudioDeviceInput:newAudioDeviceInput];
		}
	}
	
	[[self session] commitConfiguration];
}

#pragma mark UI updating
- (void)updateAudioLevels:(NSTimer *)timer
{
	NSInteger channelCount = 0;
	float decibels = 0.f;
	
	// Sum all of the average power levels and divide by the number of channels
	for (AVCaptureConnection *connection in [[self audioDataOutput] connections]) {
		for (AVCaptureAudioChannel *audioChannel in [connection audioChannels]) {
			decibels += [audioChannel averagePowerLevel];
			channelCount += 1;
		}
	}
	
	decibels /= channelCount;
	
	[[self audioLevelMeter] setFloatValue:(pow(10.f, 0.05f * decibels) * 20.0f)];
}

#pragma mark Delegate methods

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
	NSLog(@"Did start recording to %@", [fileURL description]);
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didPauseRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
	NSLog(@"Did pause recording to %@", [fileURL description]);
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didResumeRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
	NSLog(@"Did resume recording to %@", [fileURL description]);
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput willFinishRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections dueToError:(NSError *)error
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
	});
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)recordError
{
	if (recordError != nil && [[[recordError userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey] boolValue] == NO) {
		[[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
		dispatch_async(dispatch_get_main_queue(), ^(void) {
		});
	} else {
		// Move the recorded temporary file to a user-specified location
    
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
//    currentRecordingTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
//    if (self.isRecording) {
//        BOOL success = [audioAssetWriterInput appendSampleBuffer:sampleBuffer];
//        if (!success) {
//            NSLog(@"%@", audioAssetWriter.error);
//        }
//       // NSLog(@"%lld", currentRecordingTime.value/currentRecordingTime.timescale);
//    }
    if( !CMSampleBufferDataIsReady(sampleBuffer) )
    {
        NSLog( @"sample buffer is not ready. Skipping sample" );
        return;
    }
    
    
    if( isRecording == YES )
    {
        lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        if( audioAssetWriter.status != AVAssetWriterStatusWriting  && audioAssetWriter.status != AVAssetWriterStatusFailed)
        {
            [audioAssetWriter startWriting];
            [audioAssetWriter startSessionAtSourceTime:lastSampleTime];
            currentSession.startTimeValue = [NSNumber numberWithLongLong:lastSampleTime.value];
            currentSession.startTimeScale = [NSNumber numberWithInt:lastSampleTime.timescale];
            
        }
        
        if (audioAssetWriter.status == AVAssetWriterStatusFailed) {
            NSLog(@"%@", audioAssetWriter.error);
        }
        
        if( captureOutput == audioDataOutput )
            [self newAudioSample:sampleBuffer];
        
        /*
         // If I add audio to the video, then the output file gets corrupted and it cannot be reproduced
         else
         [self newAudioSample:sampleBuffer];
         */
    }
}

-(void) newAudioSample:(CMSampleBufferRef)sampleBuffer

{     
    if( isRecording )
    {
        if( ![audioAssetWriterInput appendSampleBuffer:sampleBuffer] )
            NSLog(@"Unable to write to audio input");
        
    }
}

- (NSURL *)logStorageURL {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *appURL = [libraryURL URLByAppendingPathComponent:@"MimicIIDataBrowser"];
    NSLog(@"%@", appURL);
    return [appURL URLByAppendingPathComponent:@"Logs"];
}

- (void)logNewActivity:(NSDictionary *)_activity
{
    if (currentSession) {
        NSManagedObjectContext *context = currentSession.managedObjectContext;

        NSLog(@"%@", _activity);
        LogEvent *newLogEvent = [NSEntityDescription insertNewObjectForEntityForName:@"LogEvent" inManagedObjectContext:context];
        newLogEvent.path = [_activity objectForKey:@"path"];
        newLogEvent.eventDate = [_activity objectForKey:@"date"];
        newLogEvent.action = [_activity objectForKey:@"activity"];
        newLogEvent.audioTimeValue = [NSNumber numberWithLongLong:lastSampleTime.value];
        newLogEvent.audioScale = [NSNumber numberWithLong:lastSampleTime.timescale];
        newLogEvent.session = currentSession;
        NSLog(@"%@", newLogEvent);
    }
}

@end
