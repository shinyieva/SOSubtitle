//
//  SOAsyncTestHelper.h
//  SOSubtitle
//
//  Created by so30 on 22/01/15.
//  Copyright (c) 2015 Sergio Ortega. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SO_RUNLOOP_INTERVAL 0.05
#define SO_TIMEOUT_INTERVAL 1.0
#define SO_RUNLOOP_COUNT SO_TIMEOUT_INTERVAL / SO_RUNLOOP_INTERVAL

#define SO_CAT(x, y) x ## y
#define SO_TOKCAT(x, y) SO_CAT(x, y)
#define __runLoopCount SO_TOKCAT(__runLoopCount,__LINE__)

#define SOAssertEventually(a1, format...) \
NSUInteger __runLoopCount = 0; \
while (!(a1) && __runLoopCount < SO_RUNLOOP_COUNT) { \
NSDate* date = [NSDate dateWithTimeIntervalSinceNow:SO_RUNLOOP_INTERVAL]; \
[NSRunLoop.currentRunLoop runUntilDate:date]; \
__runLoopCount++; \
} \
if (__runLoopCount >= SO_RUNLOOP_COUNT) { \
XCTFail(format); \
}

