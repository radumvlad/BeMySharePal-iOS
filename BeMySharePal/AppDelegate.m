//
//  AppDelegate.m
//  BeMySharePal
//
//  Created by Radu on 01/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import "AppDelegate.h"
#include "shamirSecretShare.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[[Crashlytics class]]];
    
    [self createFolder:@"Network/"];
    [self createFolder:@"Local/"];
    [self getFriends];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(incomingSocketDidDisconnect:)
                                                 name:INCOMING_SOCKET_DISCONNECT object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    NSLog(@"applicationWillResignActive");
    
    self.serverSocket = nil;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [self refreshServer];
    self.incomingParteners = [NSMutableArray new];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    
    if ([url isFileURL]) {
        
        NSLog(@"New file arrived via %@", sourceApplication);
        
        [[NSNotificationCenter defaultCenter] postNotificationName: NEW_FILE_NOTIFICATION object:nil];
    }

    return YES;
}

#pragma mark helper method to create folder

- (void)createFolder:(NSString *)folderName {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *inboxFolder = [documentsDirectory stringByAppendingPathComponent:folderName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:inboxFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:inboxFolder withIntermediateDirectories:NO attributes:nil error:&error];
    }
}

#pragma mark Server Socket and its Delegate

- (void)refreshServer {
    
    self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    if (![self.serverSocket acceptOnPort:PORT error:&error]) {
        
        NSLog(@"I goofed: %@", error);
    }
    
    NSLog(@"Started server with host %@", [self getIPAddress:YES]);
}

- (void)incomingSocketDidDisconnect:(NSNotification *)notification {
    
    [self.incomingParteners removeObject:notification.object];
}

- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"didAcceptNewSocket");
    
    IncomingSocket *receivedSocket = [IncomingSocket new];    
    receivedSocket.socket = newSocket;
    receivedSocket.socket.delegate = receivedSocket;
    
    [self.incomingParteners addObject:receivedSocket];
    [receivedSocket.socket readDataWithTimeout:20 tag:0];
}

#pragma mark Shamir's Secret Share

- (NSArray *)divideData:(NSData *)buffData inCount:(int) numberOfDivisions {
    
    NSMutableArray *result = [NSMutableArray new];
    char *secret = (char *)[buffData bytes];
    
    char **shares;
    shares = split_secret(secret, 2 , numberOfDivisions);
    
    
    for (int i = 0; i < numberOfDivisions; i++) {
        
        char *shareI = shares[i];
        [result addObject:[NSData dataWithBytes:shareI length:strlen(shareI)]];
    }
    
    return result;
}

- (NSData *)reconstructDataFrom:(NSData *)data1 and:(NSData *)data2 {
    
    char *share1 = (char *)[data1 bytes];
    char *share2 = (char *)[data2 bytes];
    
    char *result = get_secret(share1, share2);
    
    return [NSData dataWithBytes:result length:strlen(result)];
}

#pragma mark Local IP helpers

- (NSString *)getIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

- (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    
    return [addresses count] ? addresses : nil;
}

#pragma mark Friends usage models

- (void)saveFriends {
    
    NSMutableArray *friendsDataArray = [NSMutableArray new];
    
    for(int i = 0; i < [self.friends count]; i++) {
        FriendSocket *friend = self.friends[i];
        NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:friend];
        [friendsDataArray addObject:archive];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:friendsDataArray forKey:@"friendsArray"];
    [defaults synchronize];
}

- (void)getFriends {
    
    self.friends = [NSMutableArray new];
    
    NSMutableArray *friendsDataArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"friendsArray"];

    for (NSData *archive in friendsDataArray) {
        FriendSocket *newSocket = (FriendSocket *)[NSKeyedUnarchiver unarchiveObjectWithData:archive];
        newSocket.socket = [[GCDAsyncSocket alloc] initWithDelegate:newSocket delegateQueue:dispatch_get_main_queue()];
        [self.friends addObject:newSocket];
    }
}

@end
