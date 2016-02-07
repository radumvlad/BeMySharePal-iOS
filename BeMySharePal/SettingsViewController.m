//
//  SettingsViewController.m
//  BeMySharePal
//
//  Created by Radu on 02/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)connectAction:(id)sender {
    
    [self connect];
}

- (IBAction)readData:(id)sender {
    

}


- (IBAction)writeData:(id)sender {

    
//    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//
//    
//    NSString *requestStr = [NSString stringWithFormat:@"GET / HTTP/1.1\r\nHost: %@\r\n\r\n", HOST];
//    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
//    
//    [appdelegate.receivedSocket writeData:requestData withTimeout:-1 tag:0];
//    [appdelegate.serverSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:5 tag:0];
}

- (void)connect {
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];

    NSError *error = nil;
    NSLog(@"Connecting to \"%@\" on port %d...", HOST, PORT);
    
    self.label.text = @"Connecting...";
    
    if (![self.clientSocket connectToHost:HOST onPort:PORT withTimeout:5.0 error:&error]) {
        
        NSLog(@"Error connecting: %@", error);
    }
    
}

#pragma mark Socket Delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    self.label.text = @"Connected";
    
    NSLog(@"didConnectToHost localHost %@ port %hu host %@, port %hu", [sock localHost], [sock localPort], [sock connectedHost], [sock connectedPort]);
    
    
    
    
    
    NSString *requestStr = [NSString stringWithFormat:@"GET / HTTP/1.1\r\nHost: %@\r\n\r\n", HOST];
    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.clientSocket writeData:requestData withTimeout:-1 tag:1];
//    [self.clientSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:5 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    

    
//    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *requestStr = [NSString stringWithFormat:@"GET / HTTP/1.1\r\nHost: %@\r\n\r\n", HOST];
    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.clientSocket writeData:requestData withTimeout:-1 tag:0];
    
    
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert title" message:httpResponse preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
    //    self.label.text = @"Disconnected";
}



@end
