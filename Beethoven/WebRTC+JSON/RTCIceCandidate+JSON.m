/*
 * libjingle
 * Copyright 2014, Google Inc.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "RTCIceCandidate+JSON.h"

static NSString const *kRTCIceCandidateTypeKey = @"type";
static NSString const *kRTCIceCandidateTypeValue = @"candidate";
static NSString const *kRTCIceCandidateMidKey = @"id";
static NSString const *kRTCIceCandidateMLineIndexKey = @"label";
static NSString const *kRTCIceCandidateSdpKey = @"candidate";

@implementation RTCIceCandidate (JSON)

+ (RTCIceCandidate *)candidateFromJSONDictionary:(NSDictionary *)dictionary {
  NSString *mid = dictionary[kRTCIceCandidateMidKey];
  NSString *sdp = dictionary[kRTCIceCandidateSdpKey];
  NSNumber *num = dictionary[kRTCIceCandidateMLineIndexKey];
  NSInteger mLineIndex = [num integerValue];
  return [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:mLineIndex sdpMid:mid];
}

- (NSData *)JSONData {
  NSDictionary *json = @{
    kRTCIceCandidateTypeKey : kRTCIceCandidateTypeValue,
    kRTCIceCandidateMLineIndexKey : @(self.sdpMLineIndex),
    kRTCIceCandidateMidKey : self.sdpMid,
    kRTCIceCandidateSdpKey : self.sdp
  };
  NSError *error = nil;
  NSData *data =
      [NSJSONSerialization dataWithJSONObject:json
                                      options:NSJSONWritingPrettyPrinted
                                        error:&error];
  if (error) {
    NSLog(@"Error serializing JSON: %@", error);
    return nil;
  }
  return data;
}

@end
