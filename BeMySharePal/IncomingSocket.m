//
//  ReceiveSocket.m
//  BeMySharePal
//
//  Created by Radu on 07/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import "IncomingSocket.h"

@implementation IncomingSocket

#pragma mark Socket Delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    NSLog(@"r didConnectToHost localHost %@ port %hu host %@, port %hu", [sock localHost], [sock localPort], [sock connectedHost], [sock connectedPort]);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"r socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {

    NSError *error = nil;
    NSDictionary *myDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error) {
        NSLog(@"Smt went wrong %@", error);
        return;
    }
    
    if ([myDictionary[@"command"] isEqualToString:COMMAND_HELLO]) {
        
    }
    else if ([myDictionary[@"command"] isEqualToString:COMMAND_SEND_FILE]) {
        
        NSLog(@"received file with data %@ with name %@", myDictionary[@"file"], myDictionary[@"filename"]);
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:myDictionary[@"file"] options:0];
        
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *networkFolder = [documentsDirectory stringByAppendingPathComponent:@"/Network"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:networkFolder]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:networkFolder withIntermediateDirectories:NO attributes:nil error:&error];
        }
        
        NSString *filePath = [networkFolder stringByAppendingPathComponent:myDictionary[@"filename"]];
        [decodedData writeToFile:filePath atomically:YES];
    }
    else if ([myDictionary[@"command"] isEqualToString:COMMAND_REQ_FILE]) {
                
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *inboxDirectory = [NSString stringWithFormat:@"%@/Network", documentsDirectory];
        
        NSURL *pathURL = [NSURL fileURLWithPath:[inboxDirectory stringByAppendingPathComponent:myDictionary[@"filename"]]];
        NSData *dataFile = [NSData dataWithContentsOfURL:pathURL];
        NSString *base64Encoded = [dataFile base64EncodedStringWithOptions:0];
        
        
        NSDictionary *bodyDict = @{@"command": COMMAND_SEND_REQ_FILE,
                                   @"file": base64Encoded,
                                   @"filename" : myDictionary[@"filename"]};
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:&error];
        if (error != nil) {
            NSLog(@"Error @parse %@", error);
            return;
        }
        
        [self.socket writeData:jsonData withTimeout:20 tag:0];
        
    }
    else if ([myDictionary[@"command"] isEqualToString:COMMAND_REQ_FILE_ARRAY]) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        
        
        NSString *inboxDirectory = [NSString stringWithFormat:@"%@/Network", documentsDirectory];
        NSArray *networkFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inboxDirectory
                                                                                       error:NULL].mutableCopy;
        
        if (networkFiles == nil || (id)networkFiles == [NSNull null]) {
            networkFiles = @[];
        }
        
        NSError *error;
        NSDictionary *bodyDict = @{@"command": COMMAND_SEND_FILE_ARRAY,
                                   @"files": networkFiles};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:&error];
        if (error != nil) {
            NSLog(@"Error @parse %@", error);
            return;
        }
        
        [self.socket writeData:jsonData withTimeout:5 tag:0];
    }

}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"r socketDidDisconnect:%p withError: %@", sock, err);
    
    [[NSNotificationCenter defaultCenter] postNotificationName: INCOMING_SOCKET_DISCONNECT object:self];
    self.socket = nil;
}


@end
