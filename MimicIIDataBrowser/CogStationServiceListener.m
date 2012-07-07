//
//  CogStationServiceListener.m
//  Cog Station
//
//  Created by zli on 10/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CogStationServiceListener.h"
#import "GCDAsyncSocket.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "HTTPServer.h"
#import "MyHTTPConnection.h"

#define WELCOME_MSG  0
#define ECHO_MSG     1
#define WARNING_MSG  2

#define READ_TIMEOUT 15.0
#define READ_TIMEOUT_EXTENSION 10.0

#define LISTENING_PORT 9527
#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

@interface CogStationServiceListener (PrivateAPI)

- (void)logError:(NSString *)msg;
- (void)logInfo:(NSString *)msg;
- (void)logMessage:(NSString *)msg;

@end

@implementation CogStationServiceListener

- (id)init
{
	if((self = [super init]))
	{
		// Setup our logging framework.
		// Logging isn't used in this file, but can optionally be enabled in GCDAsyncSocket.
		[DDLog addLogger:[DDTTYLogger sharedInstance]];
		
		// Setup our server socket (GCDAsyncSocket).
		// The socket will invoke our delegate methods using the usual delegate paradigm.
		// However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
		// 
		// Now we can setup these delegate dispatch queues however we want.
		// Here are a few examples:
		// 
		// - A different delegate queue for each client connection.
		// - Simply use the main dispatch queue, so the delegate methods are invoked on the main thread.
		// - Add each client connection to the same dispatch queue.
		// 
		// The best approach for your application will depend upon convenience, requirements and performance.
		// 
		// For this simple example, we're just going to share the same dispatch queue amongst all client connections.
		
		socketQueue = dispatch_queue_create("SocketQueue", NULL);
		listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
		
		// Setup an array to store all accepted client connections
		connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
		
		isRunning = NO;
	}
	return self;
}

- (void)dealloc
{
    [listenSocket release];
    [connectedSockets release];
    dispatch_release(socketQueue);
    
    [super dealloc];
}

- (void)awakeFromNib
{
    // Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	// Initalize our http server
	httpServer = [[HTTPServer alloc] init];
	
	// Tell server to use our custom MyHTTPConnection class.
	[httpServer setConnectionClass:[MyHTTPConnection class]];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	[httpServer setType:@"_http._tcp."];
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [httpServer setPort:9527];
	
	// Serve files from our embedded Web folder
	NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
	//DDLogVerbose(@"Setting document root: %@", webPath);
    [self logInfo:FORMAT(@"Setting document root: %@", webPath)];
	
	[httpServer setDocumentRoot:webPath];
	
	// Start the server (and check for problems)
	
//	NSError *error;
//	BOOL success = [httpServer start:&error];
//	
//	if(!success)
//	{
//		DDLogError(@"Error starting HTTP Server: %@", error);
//	}
    
    isRunning = NO;
}

- (void)scrollToBottom
{
	NSScrollView *scrollView = [logView enclosingScrollView];
	NSPoint newScrollOrigin;
	
	if ([[scrollView documentView] isFlipped])
		newScrollOrigin = NSMakePoint(0.0F, NSMaxY([[scrollView documentView] frame]));
	else
		newScrollOrigin = NSMakePoint(0.0F, 0.0F);
	
	[[scrollView documentView] scrollPoint:newScrollOrigin];
}


- (void)logError:(NSString *)msg
{
    @autoreleasepool {
        NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
        [attributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
        
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
        [as autorelease];
        
        [[logView textStorage] appendAttributedString:as];
        [self scrollToBottom];
    }
	
}

- (void)logInfo:(NSString *)msg
{
    @autoreleasepool {
        NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
        [attributes setObject:[NSColor purpleColor] forKey:NSForegroundColorAttributeName];
        
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
        [as autorelease];
        
        [[logView textStorage] appendAttributedString:as];
        [self scrollToBottom];
    }
	
}

- (void)logMessage:(NSString *)msg
{
    @autoreleasepool {
        NSString *paragraph = [NSString stringWithFormat:@"%@\n", msg];
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:1];
        [attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
        
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:paragraph attributes:attributes];
        [as autorelease];
        
        [[logView textStorage] appendAttributedString:as];
        [self scrollToBottom];
    }
	
}

- (IBAction)startStop:(id)sender
{
    if (!isRunning) {
        NSError *error;
        BOOL success = [httpServer start:&error];
        
        if(!success)
        {
            [self logError:FORMAT(@"Error starting HTTP Server: %@", error)];
        }
        
        [self logInfo:FORMAT(@"Server started on port %hu", [httpServer listeningPort])];
        isRunning = YES;
        
        [sender setTitle:@"Stop Server"];
    }
    
    else {
        [httpServer stop];
        
        [self logInfo:@"Stopped Server"];
        isRunning = NO;
        
        [sender setTitle:@"Start Server"];
    }
}



@end
