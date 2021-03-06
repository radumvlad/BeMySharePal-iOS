//
//  AppDelegate.h
//  BeMySharePal
//
//  Created by Radu on 01/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//


#define PORT 1234

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#import <UIKit/UIKit.h>
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>
#import "IncomingSocket.h"
#import "FriendSocket.h"


#define NEW_FILE_NOTIFICATION @"NEW_FILE_NOTIFICATION"

@interface AppDelegate : UIResponder <UIApplicationDelegate, GCDAsyncSocketDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) GCDAsyncSocket *serverSocket;
@property (strong, nonatomic) NSMutableArray *incomingParteners;

@property (strong, nonatomic) NSMutableArray *friends;

- (NSArray *)divideData:(NSData *)buffData inCount:(int) numberOfDivisions;
- (NSData *)reconstructDataFrom:(NSData *)data1 and:(NSData *)data2;

- (NSString *)getIPAddress:(BOOL)preferIPv4;
- (void)saveFriends;

@end

