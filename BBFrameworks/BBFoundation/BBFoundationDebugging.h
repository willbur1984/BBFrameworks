//
//  BBFoundationDebugging.h
//  BBFrameworks
//
//  Created by William Towe on 4/10/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#ifndef __BB_FRAMEWORKS_FOUNDATION_DEBUGGING__
#define __BB_FRAMEWORKS_FOUNDATION_DEBUGGING__

#ifdef DEBUG

#define BBLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#else

#ifdef BB_DISABLE_RELEASE_LOGGING
#define BBLog(...)
#else
#define BBLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif

#endif

#define BBLogObject(objectToLog) BBLog(@"%@",objectToLog)
#define BBLogCGRect(rectToLog) BBLogObject(NSStringFromCGRect(rectToLog))
#define BBLogCGSize(sizeToLog) BBLogObject(NSStringFromCGSize(sizeToLog))
#define BBLogCGPoint(pointToLog) BBLogObject(NSStringFromCGPoint(pointToLog))
#define BBLogCGFloat(floatToLog) BBLog(@"%f",floatToLog)

#define BBIsEnvironmentVariableDefined(environmentVariable) [NSProcessInfo processInfo].environment[[NSString stringWithUTF8String:(#environmentVariable)]]

#endif
