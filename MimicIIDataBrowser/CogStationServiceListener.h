//
//  CogStationServiceListener.h
//  Cog Station
//
//  Created by zli on 10/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GCDAsyncSocket;
@class HTTPServer;

@interface CogStationServiceListener : NSObject
{
	dispatch_queue_t socketQueue;
	
	GCDAsyncSocket *listenSocket;
	NSMutableArray *connectedSockets;
	
	BOOL isRunning;
	
	IBOutlet id logView;
	IBOutlet id portField;
	IBOutlet id startStopButton;
    
    HTTPServer *httpServer;

}

- (IBAction)startStop:(id)sender;


@end
