//
//  FriendSocket.h
//  BeMySharePal
//
//  Created by Radu on 07/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//


#define NEW_NETWORK_FILES @"NEW_NETWORK_FILES"
#define REQUESTED_FILE_RECEIVED @"REQUESTED_FILE_RECEIVED"

typedef enum __attribute__((packed)){
    FriendStateUndefined = 0,
    FriendStateConnected = 1,
    FriendStateDisconnected = 2,
    FriendStateError = 3,
} FriendStateEnum;

typedef void (^FriendDidConnectBlock)();

#import "commands.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface FriendSocket : NSObject<GCDAsyncSocketDelegate>

@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) GCDAsyncSocket *socket;

@property (nonatomic, strong) FriendDidConnectBlock connectCallback;
@property (nonatomic, strong) FriendDidConnectBlock disconnectCallback;

@property (nonatomic) FriendStateEnum lastState;

@end
