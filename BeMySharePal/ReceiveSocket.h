//
//  ReceiveSocket.h
//  BeMySharePal
//
//  Created by Radu on 07/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface ReceiveSocket : NSObject<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;

@end
