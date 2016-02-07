//
//  ReceiveSocket.h
//  BeMySharePal
//
//  Created by Radu on 07/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#define INCOMING_SOCKET_DISCONNECT @"INCOMING_SOCKET_DISCONNECT"

#import "commands.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface IncomingSocket : NSObject<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;

@end
