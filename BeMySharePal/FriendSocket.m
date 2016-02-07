//
//  FriendSocket.m
//  BeMySharePal
//
//  Created by Radu on 07/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import "FriendSocket.h"

@implementation FriendSocket


#pragma mark Socket Delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    NSLog(@"didConnectToHost localHost %@ port %hu host %@, port %hu", [sock localHost], [sock localPort], [sock connectedHost], [sock connectedPort]);
    
    if (self.connectCallback) {
        self.connectCallback();
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    
   
    NSError *error = nil;
    NSDictionary *myDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) {
        NSLog(@"Smt went wrong %@", error);
        return;
    }
    
    if ([myDictionary[@"command"] isEqualToString:COMMAND_HELLO]) {
        
        
    }
    else if ([myDictionary[@"command"] isEqualToString:COMMAND_SEND_REQ_FILE]) {
        
        NSLog(@"received file with data %@ with name %@", myDictionary[@"file"], myDictionary[@"filename"]);
        [[NSNotificationCenter defaultCenter] postNotificationName: REQUESTED_FILE_RECEIVED object:myDictionary];
        
    }
    else if ([myDictionary[@"command"] isEqualToString:COMMAND_SEND_FILE_ARRAY]) {
        
        NSDictionary *dict = @{@"files" : myDictionary[@"files"],
                               @"friend" : self};
        
        [[NSNotificationCenter defaultCenter] postNotificationName: NEW_NETWORK_FILES object:dict];
    }
    
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
    //    self.label.text = @"Disconnected";
}


@end
