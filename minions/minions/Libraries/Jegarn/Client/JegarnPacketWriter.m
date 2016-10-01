//
// Created by Yao Guai on 16/9/30.
// Copyright (c) 2016 minions.jegarn.com. All rights reserved.
//

#import "JegarnPacketWriter.h"
#import "JegarnSecurityPolicy.h"
#import "JegarnLog.h"

@interface JegarnPacketWriter()
@property (strong, nonatomic) NSMutableData *buffer;
@property (nonatomic) BOOL enableWrite;
@end
@implementation JegarnPacketWriter {
@private
    NSOutputStream *_stream;
}
@synthesize stream = _stream;

- (void)stream:(NSStream*)sender handleEvent:(NSStreamEvent)eventCode {
    DDLogVerbose(@"[JegarnPacketWriter] NSStreamEvent %d", eventCode);

    if (eventCode & NSStreamEventHasSpaceAvailable) {
        if (self.enableSsl) {
            if (![self applySSLSecurityPolicy:sender withEvent:eventCode]) {
                DDLogVerbose(@"[JegarnPacketWriter] NSStreamEventHasSpaceAvailable error %@", sender.streamError);
                self.enableWrite = NO;
            } else {
                self.enableWrite = YES;
            }
        } else {
            self.enableWrite = YES;
        }
    }
    if (eventCode &  NSStreamEventEndEncountered) {}
    if (eventCode & NSStreamEventErrorOccurred) {}
}

- (BOOL)send:(NSData *)data {
    @synchronized(self) {
        if(!self.enableWrite){
            return NO;
        }

        if (data) {
            [self.buffer appendData:data];
        }

        if (self.buffer.length) {
            DDLogVerbose(@"[JegarnPacketWriter] buffer to write (%lu)=%@...",
                    (unsigned long)self.buffer.length,
                    [self.buffer subdataWithRange:NSMakeRange(0, MIN(256, self.buffer.length))]);

            NSInteger n = [self.stream write:self.buffer.bytes maxLength:self.buffer.length];
            if (n == -1) {
                DDLogVerbose(@"[JegarnPacketWriter] streamError: %@", self.stream.streamError);
                return NO;
            } else {
                if (n < self.buffer.length) {
                    DDLogVerbose(@"[JegarnPacketWriter] buffer partially written: %ld", (long) n);
                }
                [self.buffer replaceBytesInRange:NSMakeRange(0, n) withBytes:NULL length:0];
            }
        }
        return YES;
    }
}

@end