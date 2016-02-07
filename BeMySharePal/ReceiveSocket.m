//
//  ReceiveSocket.m
//  BeMySharePal
//
//  Created by Radu on 07/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import "ReceiveSocket.h"

@implementation ReceiveSocket



- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"r socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"r socket:%p didReadData:withTag:%ld", sock, tag);
    
    
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert title" message:httpResponse preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"r socketDidDisconnect:%p withError: %@", sock, err);



}


@end
