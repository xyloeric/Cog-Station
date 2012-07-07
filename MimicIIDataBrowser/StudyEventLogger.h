//
//  StudyEventLogger.h
//  MimicIIDataBrowser
//
//  Created by zli on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
@class Session;
@class MainBrowserWindowController;
@interface StudyEventLogger : NSObject <AVCaptureFileOutputDelegate, AVCaptureFileOutputRecordingDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
{
    NSLevelIndicator			*audioLevelMeter;    

    AVCaptureSession			*session;
    AVCaptureDeviceInput		*audioDeviceInput;
    
    AVCaptureAudioFileOutput    *audioFileOutput;
    AVCaptureAudioDataOutput    *audioDataOutput;
    AVAssetWriter               *audioAssetWriter;
    AVAssetWriterInput          *audioAssetWriterInput;
    
    NSArray                     *audioDevices;

    NSTimer						*audioLevelTimer;
    
    NSArray						*observers;
    
    CMTime                      currentRecordingTime;
    CMTime                      lastSampleTime;
    
    NSString                    *currentRecordingName;
    
    BOOL                        isRecording;
    
    NSManagedObjectContext      *managedObjectContext;
    Session                     *currentSession;
    
    MainBrowserWindowController *mbwc;

}
@property (assign) AVCaptureDevice *selectedAudioDevice;
@property (retain) NSArray *audioDevices;

#pragma mark Recording
@property (retain) AVCaptureSession *session;
@property (readonly) NSArray *availableSessionPresets;
@property (readonly) BOOL hasRecordingDevice;
@property (assign) BOOL isRecording;

@property (assign) IBOutlet NSLevelIndicator *audioLevelMeter;

@property (retain) AVCaptureDeviceInput *audioDeviceInput;
@property (assign) NSTimer *audioLevelTimer;
@property (retain) NSArray *observers;

@property (retain) AVCaptureAudioFileOutput *audioFileOutput;
@property (retain) AVCaptureAudioDataOutput *audioDataOutput;

@property (readonly) CMTime currentRecordingTime;
@property (readonly) NSString *currentRecordingName;
@property (assign) Session *currentSession;
@property (assign) NSManagedObjectContext *managedObjectContext;

@property (assign) MainBrowserWindowController *mbwc;

- (void)refreshDevices;
- (void) newAudioSample:(CMSampleBufferRef)sampleBuffer;
- (NSURL *)logStorageURL;

- (void)logNewActivity:(NSDictionary *)_activity;

@end
