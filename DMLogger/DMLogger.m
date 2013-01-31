//
//  DMLogger.h
//  A NSLog replacement with some nifty features
//
//  Created by Daniele Margutti (me@danielemargutti.com) on 1/31/13.
//	Web: http://www.danielemargutti.com
//  Copyright (c) 2013 danielemargutti.com. All rights reserved.
//

#import "DMLogger.h"


#ifdef DMDEBUG
	// If we have definied the DEBUG build mode our default log level is DMLogLevelTrace
	static DMLogLevel _DMCurrentLogLevel = DMLogLevelTrace;
#else
	// If we have not defined DEBUG build we want to ignore at least log levels below DMLogLevelInfo
	static DMLogLevel _DMCurrentLogLevel = DMLogLevelInfo;
#endif

/** We have assigned a name to print for our log messages */
static char *_DMLogLevelNames[] = { "TRACE","DEBUG","INFO","WARNING","ERROR","FATAL" };

void DMSetLogLevel(DMLogLevel level) {
	#ifndef DMDEBUG
		if (level < DMLogLevelInfo)
			// ignore set log level when below DMLogLevelInfo without DEBUG define
			_DMCurrentLogLevel = DMLogLevelInfo;
	#endif
		_DMCurrentLogLevel = level;
}

DMLogLevel getLogLevel(void) {
	return DMLogLevelInfo;
}

static NSDateFormatter* _DMLogDateFormatter = nil;

void _DMLog(DMLogLevel level, const char *file, int lineNumber, const char *functionName, NSString *format, ...) {
	// if this message's level is lower than accepted level we want to simply ignore it
	if (level < _DMCurrentLogLevel) return;
	
	// format our string
	NSString *body = nil;
	if (format) {
		va_list ap;
		va_start(ap, format);
		if (![format hasSuffix:@"\n"]) {
			format = [format stringByAppendingString:@"\n"];
		}
		body = [[NSString alloc] initWithFormat:format arguments:ap];
		va_end(ap);
	} else
		body = @"\n"; // a simple return
	
	// Setup date formatter at the first time if required
	if (_DMLogDateFormatter == nil && DMDEBUG_DEFAULT_DATEFORMAT != NULL) {
		_DMLogDateFormatter = [[NSDateFormatter alloc] init];
		[_DMLogDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
		[_DMLogDateFormatter setDateFormat:DMDEBUG_DEFAULT_DATEFORMAT];
	}
	
	// If set we want to print the current log timestamp in user's prefereed format
	NSString *nowString = (DMDEBUG_DEFAULT_DATEFORMAT != NULL ?
						   [_DMLogDateFormatter stringFromDate:[NSDate date]] :
						   @"");

	const char *nowCString = (DMDEBUG_DEFAULT_DATEFORMAT == NULL ? nil : [nowString cStringUsingEncoding:NSUTF8StringEncoding]);

#ifdef DMDEBUG_PRINT_CALLTRACE
	// get the current thread name (nil is returned if we are on the main thread)
	const char *threadName = [[[NSThread currentThread] name] UTF8String];
	NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
	
	if (threadName) // Method is called on another thread, we would print it's name
		fprintf(stderr,"%s%s[%s] %s/%s (%s:%d) %s",
				nowCString,
				(nowCString != nil ? " " : ""),
				_DMLogLevelNames[level],
				threadName,
				functionName,
				[fileName UTF8String],
				lineNumber,
				[body UTF8String]);
	else // Method is called into the main thread
		fprintf(stderr,"%s%s[%s] %p/%s (%s:%d) %s",
				nowCString,
				(nowCString != nil ? " " : ""),
				_DMLogLevelNames[level],
				[NSThread currentThread],
				functionName,
				[fileName UTF8String],
				lineNumber,
				[body UTF8String]);
#else
	fprintf(stderr,"%s%s[%s] %s",
			[nowString cStringUsingEncoding:NSUTF8StringEncoding],
			(nowCString != nil ? " " : ""),
			_DMLogLevelNames[level],
			[body UTF8String]);
#endif

	if (DMLogLevelFatal == level) {
		abort();
	}
}