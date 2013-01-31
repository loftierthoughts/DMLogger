//
//  DMLogger.h
//  A NSLog replacement with some nifty features
//
//  Created by Daniele Margutti (me@danielemargutti.com) on 1/31/13.
//	Web: http://www.danielemargutti.com
//  Copyright (c) 2013 danielemargutti.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - SETTINGS

/** Comment this line to disable DEBUG mode. Only messages when log level >= DMLogLevelInfo will be shown */
#define DMDEBUG

/** This is the default log level at startup */
#define DMDEBUG_DEFAULT_LEVEL				DMLogLevelTrace

/** Set your custom date format or NULL to avoid date print in your log.
	Default NSLog() date format is @"yyyy-MM-dd HH:mm:ss.SSS"
 */
#define DMDEBUG_DEFAULT_DATEFORMAT			NULL

/** If DMDEBUG_DEFAULT_DATEFORMAT != NULL you can also specify a locale for date format
	Default NSLog() locale is US POSIX @"en_US_POSIX"
*/
#define DMDEBUG_DEFAULT_DATELOCALEID		@"en_US_POSIX"

/** Comment it to disable file/line/method/thread print data in your logs */
//#define DMDEBUG_PRINT_CALLTRACE

/** Comment it to prevent NSLog() override to DMLogInfo() method */
#define DMDEBUG_OVERRIDE_NSLOG

#ifdef DMDEBUG_OVERRIDE_NSLOG
	#define NSLog(...) DMLogInfo(__VA_ARGS__);
#endif

#pragma mark - AVAILABLE LOG LEVELS

/** Available log levels */
typedef enum {
	DMLogLevelTrace,
	DMLogLevelDebug,
	DMLogLevelInfo,
	DMLogLevelWarning,
	DMLogLevelError,
	DMLogLevelFatal
} DMLogLevel;

#pragma mark - LOG FUNCTIONS

/** trace or debug call are available only when DEBUG is definied. otherwise it will be ignored (even if you set the right level code) */
#ifdef DMDEBUG
	#define DMLogTrace			_DMLog(DMLogLevelTrace, __FILE__, __LINE__, __PRETTY_FUNCTION__, NULL);
	#define DMLogDebug(args...)	_DMLog(DMLogLevelDebug, __FILE__, __LINE__, __PRETTY_FUNCTION__, args);
#else
	#define DMLogTrace
	#define DMLogDebug(x...)
#endif

#define DMLogInfo(args...)		_DMLog(DMLogLevelInfo,		__FILE__, __LINE__, __PRETTY_FUNCTION__, args);
#define DMLogWarning(args...)	_DMLog(DMLogLevelWarning,	__FILE__, __LINE__, __PRETTY_FUNCTION__, args);
#define DMLogError(args...)		_DMLog(DMLogLevelError,		__FILE__, __LINE__, __PRETTY_FUNCTION__, args);

/** Fatal error also abort application execution */
#define DMLogFatal(args...)		_DMLog(DMLogLevelFatal,		__FILE__, __LINE__, __PRETTY_FUNCTION__, args);

#pragma mark - GET/SET LOG LEVEL

/** The default log level is DMLogTrace.
	NOTE: If not running in [#define DEBUG] mode trace (DMLogLevelTrace) and debug (DMLogLevelDebug) messages will not ever be shown */
void DMSetLogLevel(DMLogLevel level);

/** Return the current log level */
DMLogLevel getLogLevel(void);

#pragma mark - INTERNAL METHODS

/** Internal methods */
void _DMLog(DMLogLevel level, const char *file, int lineNumber, const char *functionName, NSString *format,...);