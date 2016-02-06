//
//  AppDelegate.m
//  BeMySharePal
//
//  Created by Radu on 01/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import "AppDelegate.h"
#include "shamirSecretShare.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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


@end
