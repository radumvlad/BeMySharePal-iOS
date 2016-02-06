//
//  AppDelegate.h
//  BeMySharePal
//
//  Created by Radu on 01/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NEW_FILE_NOTIFICATION @"NEW_FILE_NOTIFICATION"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


- (NSArray *)divideData:(NSData *)buffData inCount:(int) numberOfDivisions;
- (NSData *)reconstructDataFrom:(NSData *)data1 and:(NSData *)data2;

@end

